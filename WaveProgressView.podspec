#
# Be sure to run `pod lib lint WebViewController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WaveProgressView'
  s.version          = '1.0.0'
  s.summary          = 'Water wave progress bar'
  s.homepage         = 'https://github.com/sukov/WaveProgressView'
  s.screenshots      = 'https://raw.githubusercontent.com/sukov/WaveProgressView/master/Screenshots/waveProgressView.gif'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'sukov' => 'gorjan5@hotmail.com' }
  s.source           = { :git => 'https://github.com/sukov/WaveProgressView.git', :tag => s.version.to_s }


  s.platform              = :ios, '9.0'
  s.ios.deployment_target = '9.0'

  s.source_files = 'Source/**/*.{h,swift}'
  # s.resources             = 'Source/Resources/*.xcassets'
  s.frameworks            = 'UIKit', 'Foundation'

  # s.resource_bundles = {
  #   'WebViewController' => ['WebViewController/Assets/*.png']
  # }

end
