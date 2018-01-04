//
//  ViewController.swift
//  Example
//
//  Created by Admin on 12/18/17.
//  Copyright © 2017 Gorjan Sukov. All rights reserved.
//

import UIKit
import WaveProgressView

class ViewController: UIViewController {
    fileprivate var waveProgressView: WaveProgressView!
    fileprivate var slider: UISlider!
    fileprivate var animatedLabel: UILabel!
    fileprivate var animatedSwitch: UISwitch!
    fileprivate var button: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }

    func setupViews() {
        view.backgroundColor = .white
        
        waveProgressView = WaveProgressView()
        waveProgressView.progress = 0.1
        waveProgressView.layer.cornerRadius = 20
        waveProgressView.layer.masksToBounds = true
        waveProgressView.clipsToBounds = true
        waveProgressView.progressTintColor = .blue
        waveProgressView.backgroundColor = .gray
        view.addSubview(waveProgressView)
        
        make(waveProgressView, layoutAttributes: [.top], equalToView: view, equalToAttributes: [.top], offset: 100)
        make(waveProgressView, layoutAttributes: [.left], equalToView: view, equalToAttributes: [.left], offset: 30)
        make(waveProgressView, layoutAttributes: [.right], equalToView: view, equalToAttributes: [.right], offset: -30)
        make(waveProgressView, layoutAttributes: [.height], equalToView: nil, equalToAttributes: [.notAnAttribute], offset: 50)
        let constraint = NSLayoutConstraint(item: waveProgressView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
        view.addConstraint(constraint)
        
        slider = UISlider(frame: CGRect(x: 30, y: 200, width: view.frame.width - 60, height: 20))
        slider.value = 0.1
        view.addSubview(slider)
        
        animatedLabel = UILabel(frame: CGRect(x: 30, y: 255, width: 100, height: 20))
        animatedLabel.text = "Animated"
        view.addSubview(animatedLabel)
        
        animatedSwitch = UISwitch(frame: CGRect(x: 110, y: 250, width: 20, height: 20))
        animatedSwitch.isOn = true
        view.addSubview(animatedSwitch)
        
        button = UIButton(frame: CGRect(x: 30, y: 300, width: 120, height: 44))
        button.setTitle("Update value", for: .normal)
        button.backgroundColor = .blue
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        view.addSubview(button)
    }
    
    @objc fileprivate func buttonTapped() {
        waveProgressView.setProgress(slider.value,
                                     duration: animatedSwitch.isOn ? 1.0 : 0.0,
                                     animationType: .easeInOut)
    }
    
    @discardableResult fileprivate func make(_ view: UIView,
                                             layoutAttributes: [NSLayoutAttribute],
                                             equalToView: UIView?,
                                             equalToAttributes: [NSLayoutAttribute],
                                             offset: CGFloat,
                                             addConstraintToView: UIView? = nil,
                                             multiply: CGFloat = 1,
                                             divide: CGFloat = 1) -> [NSLayoutConstraint] {
        view.translatesAutoresizingMaskIntoConstraints = false
        var layoutConstraints:[NSLayoutConstraint] = []
        for i in 0..<layoutAttributes.count {
            let constraint = NSLayoutConstraint(item: view, attribute: layoutAttributes[i], relatedBy: .equal, toItem: equalToView, attribute: equalToAttributes[i], multiplier: multiply / divide, constant: offset)
            layoutConstraints.append(constraint)
            addConstraintToView != nil ? addConstraintToView?.addConstraint(constraint) : equalToView?.addConstraint(constraint)
        }
        return layoutConstraints
    }
}

