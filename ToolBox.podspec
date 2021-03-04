#
# Be sure to run `pod lib lint ToolBox.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ToolBox'
  s.version          = '1.0.0'
  s.summary          = 'Developer\'s toolbox for debugging applications'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/infinum/ios-toolbox'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Infinum' => 'ios@infinum.hr', 'Vlaho Poluta' => 'vlaho.poluta@infinum.hr' }
  s.source           = { :git => 'https://github.com/infinum/ios-toolbox.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.requires_arc = true
  s.platform = :ios
  s.ios.deployment_target = '10.0'


  s.default_subspec = 'Default'
  
  s.subspec 'Core' do |sp|
    sp.source_files = 'ToolBox/Classes/Core/**/*'
    sp.frameworks = 'UIKit'
  end
  
  s.subspec 'UserDefaults' do |sp|
    sp.source_files = 'ToolBox/Classes/UserDefaults/**/*'
    sp.dependency 'ToolBox/Core'
  end

  s.subspec 'CustomLocation' do |sp|
    sp.source_files = 'ToolBox/Classes/CustomLocation/**/*'
    sp.dependency 'ToolBox/Core'
  end
  
  s.subspec 'CustomInfo' do |sp|
    sp.source_files = 'ToolBox/Classes/CustomInfo/**/*'
    sp.dependency 'ToolBox/Core'
  end
  
  s.subspec 'GeneralInfo' do |sp|
    sp.source_files = 'ToolBox/Classes/GeneralInfo/**/*'
    sp.dependency 'ToolBox/CustomInfo'
  end
  
  s.subspec 'TextEditing' do |sp|
    sp.source_files = 'ToolBox/Classes/TextEditing/**/*'
    sp.dependency 'ToolBox/Core'
  end

  s.subspec 'OptionSwitch' do |sp|
    sp.source_files = 'ToolBox/Classes/OptionSwitch/**/*'
    sp.dependency 'ToolBox/Core'
  end

  s.subspec 'PerformanceInfo' do |sp|
    sp.source_files = 'ToolBox/Classes/PerformanceInfo/**/*'
    sp.dependency 'ToolBox/Core'
  end
  
  s.subspec 'Loggie' do |sp|
    sp.source_files = 'ToolBox/Classes/Loggie/**/*'
    sp.dependency 'ToolBox/Core'
    sp.dependency 'Loggie', '~> 2.2'
  end
  
  s.subspec 'Bugsnatch' do |sp|
    sp.source_files = 'ToolBox/Classes/Bugsnatch/**/*'
    sp.dependency 'ToolBox/Core'
    sp.dependency 'Bugsnatch/Core', '~> 1.0'
  end
  
#  This won't work untill AnalyticsCollector is added to main cocapods repo
  s.subspec 'AnalyticsCollector' do |sp|
    sp.source_files = 'ToolBox/Classes/AnalyticsCollector/**/*'
    sp.dependency 'ToolBox/Core'
#    pod 'AnalyticsCollector', :git => 'https://github.com/infinum/ios-analytics-collector'
  end
  
  s.subspec 'Default' do |sp|
    sp.dependency 'ToolBox/Core'
    sp.dependency 'ToolBox/UserDefaults'
    sp.dependency 'ToolBox/CustomLocation'
    sp.dependency 'ToolBox/CustomInfo'
    sp.dependency 'ToolBox/GeneralInfo'
    sp.dependency 'ToolBox/TextEditing'
    sp.dependency 'ToolBox/OptionSwitch'
    sp.dependency 'ToolBox/PerformanceInfo'
  end
  
end
