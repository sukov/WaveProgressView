//
//  WaveProgressView.swift
//  WaveProgressView
//
//  Created by Admin on 12/18/17.
//  Copyright © 2017 Gorjan Sukov. All rights reserved.
//

import UIKit

public protocol WaveProgressViewDelegate: class {
    func waveProgressView(waveProgressView: WaveProgressView, didUpdate value: Float)
    func waveProgressViewWillStartAnimating(waveProgressView: WaveProgressView)
    func waveProgressViewDidFinishAnimating(waveProgressView: WaveProgressView)
}

public extension WaveProgressViewDelegate {
    func waveProgressView(waveProgressView: WaveProgressView, didUpdate value: Float) { }
    func waveProgressViewWillStartAnimating(waveProgressView: WaveProgressView) { }
    func waveProgressViewDidFinishAnimating(waveProgressView: WaveProgressView) { }
}

public class WaveProgressView: UIProgressView {
    public enum AnimationType {
        case linear
        case easeIn
        case easeOut
        case easeInOut
    }
    
    public weak var delegate: WaveProgressViewDelegate?
    public var kCounterRate: Float = 2.0
    
    fileprivate var start: Float = 0.0
    fileprivate var end: Float = 0.0
    fileprivate var timer: Timer?
    fileprivate var lastUpdate: TimeInterval!
    fileprivate var currentProgress: Float = 0.0
    fileprivate var duration: Float!
    fileprivate var animationType: AnimationType!
    fileprivate var currentValue: Float {
        if (currentProgress >= duration) {
            return end
        }
        let percent = Float(currentProgress / duration)
        let update = updateCounter(t: percent)
        return start + (update * (end - start))
    }
    
    convenience public init() {
        self.init(frame: .zero)
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        startWaveAnimation()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(frame: .zero)
        startWaveAnimation()
    }
    
    public func setProgress(_ progress: Float, duration: Float , animationType: AnimationType) {
        // Set values
        self.start = self.progress
        self.end = progress
        self.duration = duration
        self.animationType = animationType
        self.currentProgress = 0.0
        self.lastUpdate = Date.timeIntervalSinceReferenceDate
        
        // Invalidate and nullify timer
        killTimer()
        
        // Handle no animation
        if duration == 0.0 {
            self.progress = end
            return
        }
        
        delegate?.waveProgressViewWillStartAnimating(waveProgressView: self)
        
        // Create timer
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateValue), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .commonModes)
    }

    @objc fileprivate func updateValue() {
        // Update the progress
        let now = NSDate.timeIntervalSinceReferenceDate
        currentProgress = currentProgress + Float(now - lastUpdate)
        lastUpdate = now
        
        // End when timer is up
        if (currentProgress >= duration) {
            killTimer()
            currentProgress = duration
            delegate?.waveProgressViewDidFinishAnimating(waveProgressView: self)
        }

        progress = currentValue
        delegate?.waveProgressView(waveProgressView: self, didUpdate: progress)
    }
    
    @objc fileprivate func killTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc fileprivate func updateCounter(t: Float) -> Float {
        switch animationType {
        case .linear:
            return t
        case .easeIn:
            return powf(t, kCounterRate)
        case .easeOut:
            return 1.0 - powf((1.0 - t), kCounterRate)
        case .easeInOut:
            var t = t
            var sign = 1.0;
            let r = Int(kCounterRate)
            if (r % 2 == 0) {
                sign = -1.0
            }
            t *= 2;
            if (t < 1) {
                return 0.5 * powf(t, kCounterRate)
            } else {
                return Float(sign * 0.5) * (powf(t-2, kCounterRate) + Float(sign * 2))
            }
        default: return t
        }
    }
    
    //MARK: WaveAnimation
    
    fileprivate var displaylink: CADisplayLink?
    /**
     * Line width used for the proeminent wave
     *
     * Default: 3.0f
     */
    public var primaryWaveLineWidth: CGFloat = 3.0
    
    /**
     * The amplitude that is used when the incoming amplitude is near zero.
     * Setting a value greater 0 provides a more vivid visualization.
     *
     * Default: 0.01
     */
    public var idleAmplitude: CGFloat = 0.01
    
    /**
     * The frequency of the sinus wave. The higher the value, the more sinus wave peaks you will have.
     *
     * Default: 1.5
     */
    public var frequency: CGFloat = 1.2
    
    /**
     * The current amplitude
     */
    public var amplitude: CGFloat = 0.3
    
    /**
     * The lines are joined stepwise, the more dense you draw, the more CPU power is used.
     *
     * Default: 5
     */
    public var density: CGFloat = 5.0
    
    /**
     * The phase shift that will be applied with each level setting
     * Change this to modify the animation speed or direction
     *
     * Default: -0.15
     */
    public var phaseShift: CGFloat = -0.10
    public var phase: CGFloat = 0
    
    
    public func startWaveAnimation() {
        displaylink = CADisplayLink(target: self, selector: #selector(updateMeters))
        displaylink?.add(to: RunLoop.main, forMode: .commonModes)
    }
    
    public func stopWaveAnimation() {
        displaylink?.remove(from: .current, forMode: .commonModes)
        displaylink?.invalidate()
        displaylink = nil
    }
    
    /**
     * With phase shifts, the animation will prevail.
     */
    @objc fileprivate func updateMeters() {
        phase += phaseShift
        setNeedsDisplay()
    }
    
    override public func draw(_ rect: CGRect) {
        // Get current Context.
        let context = UIGraphicsGetCurrentContext()
        
        // Clear everything in the bounds drawed in the last phase,
        // otherwise, drawing will overlap on each other.
        context?.clear(bounds)
        
        backgroundColor?.set()
        
        context?.fill(rect)
        context?.setLineWidth(CGFloat(primaryWaveLineWidth))
        
        let halfWidth = bounds.width / 2.0
        let height: CGFloat = bounds.height
        let halfHeight = height / 2.0
        
        let maxAmplitude = max(halfWidth / 10 - 4.0, CGFloat(2.0 * primaryWaveLineWidth)) // 4 corresponds to twice the stroke width
        let progressTintColor = self.progressTintColor ?? .blue
        progressTintColor.withAlphaComponent(progressTintColor.cgColor.alpha).set()
        
        var y: CGFloat = 0
        while  y < (height + density) {
            // We use a parable to scale the sinus wave, that has its peak in the middle of the view.
            let scaling = -pow(1 / halfHeight * (y - halfHeight), 2) + 1
            
            let x = scaling * maxAmplitude * amplitude * sin(CGFloat(2.0 * Double.pi) * (y / height) * frequency + phase) + bounds.width * CGFloat(progress)
            if (y == 0) {
                context?.move(to: CGPoint(x: x, y: y))
            } else {
                context?.addLine(to: CGPoint(x: x, y: y))
            }
            
            y += density
        }
        context?.addLine(to: CGPoint(x: 0, y: height))
        context?.addLine(to: CGPoint(x: 0, y: 0))
        context?.closePath()
        context?.fillPath()
        context?.strokePath()
    }
}
