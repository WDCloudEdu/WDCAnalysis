#
# Be sure to run `pod lib lint WDCAnalysis.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WDCAnalysis'
  s.version          = '1.0.1'
  s.summary          = '伟东云统计框架'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
伟东云统计框架。支持页面统计、自定义事件统计、崩溃统计
                       DESC

  s.homepage         = 'https://github.com/WDCloudEdu/WDCAnalysis'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'xiongwei' => 'xiongwei@wdcloud.cc' }
  s.source           = { :git => 'https://github.com/WDCloudEdu/WDCAnalysis.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'WDCAnalysis/Classes/**/WDCAnalysisSDK.h'
  s.vendored_frameworks = 'WDCAnalysis/Products/WDCAnalysis.framework'
  
  # s.resource_bundles = {
  #   'WDCAnalysis' => ['WDCAnalysis/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'AFNetworking/Reachability'
  s.dependency 'WDCSqlite'
end
