#
# Be sure to run `pod lib lint BevaBaseKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BevaBaseKit'
  s.version          = '0.2.0'
  s.summary          = '贝瓦基础开发库'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = '这是贝瓦的基础开发库'

  s.homepage         = 'https://github.com/kevin930119/BevaBaseKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'kevin' => '673729631@qq.com' }
  s.source           = { :git => 'https://github.com/kevin930119/BevaBaseKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  
  s.frameworks = 'UIKit', 'AdSupport', 'AVFoundation'
  s.dependency 'Masonry'
  s.dependency 'SDWebImage'

  s.source_files = 'BevaBaseKit/Classes/**/*'
  
   s.resource_bundles = {
     'BevaBaseKit' => ['BevaBaseKit/Resources/*.plist']
   }

   s.public_header_files = 'BevaBaseKit/Classes/**/*.h'
end
