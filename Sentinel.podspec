#
# Be sure to run `pod lib lint Sentinel.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Sentinel'
  s.version          = '0.9.0'
  s.summary          = 'Developer\'s toolbox for debugging applications'

  s.description      = <<-DESC
  Sentinel is a simple library which gives developers a possibility to configure one entry point for every debug tool.
  The idea of Sentinel is to give ability to developers to configure screen with multiple debug tools which are available via some event (e.g. shake, notification).
                       DESC

  s.homepage         = 'https://github.com/infinum/ios-toolbox'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Infinum' => 'ios@infinum.com', 'Vlaho Poluta' => 'vlaho.poluta@infinum.com', 'Nikola Majcen' => 'nikola.majcen@infinum.com' }
  s.source           = { :git => 'https://github.com/infinum/ios-toolbox.git', :tag => s.version.to_s }

  s.requires_arc = true
  s.platform = :ios
  s.swift_version = '5.0'
  s.ios.deployment_target = '10.0'

  s.default_subspec = 'Default'
  
  s.subspec 'Core' do |sp|
    sp.source_files = 'Sentinel/Classes/Core/**/*'
    sp.frameworks = 'UIKit'
  end
  
  s.subspec 'UserDefaults' do |sp|
    sp.source_files = 'Sentinel/Classes/UserDefaults/**/*'
    sp.dependency 'Sentinel/Core'
  end

  s.subspec 'CustomLocation' do |sp|
    sp.source_files = 'Sentinel/Classes/CustomLocation/**/*'
    sp.dependency 'Sentinel/Core'
  end
  
  s.subspec 'CustomInfo' do |sp|
    sp.source_files = 'Sentinel/Classes/CustomInfo/**/*'
    sp.dependency 'Sentinel/Core'
  end
  
  s.subspec 'GeneralInfo' do |sp|
    sp.source_files = 'Sentinel/Classes/GeneralInfo/**/*'
    sp.dependency 'Sentinel/CustomInfo'
  end
  
  s.subspec 'TextEditing' do |sp|
    sp.source_files = 'Sentinel/Classes/TextEditing/**/*'
    sp.dependency 'Sentinel/Core'
  end

  s.subspec 'OptionSwitch' do |sp|
    sp.source_files = 'Sentinel/Classes/OptionSwitch/**/*'
    sp.dependency 'Sentinel/Core'
  end

  s.subspec 'PerformanceInfo' do |sp|
    sp.source_files = 'Sentinel/Classes/PerformanceInfo/**/*'
    sp.dependency 'Sentinel/Core'
  end
  
  s.subspec 'Loggie' do |sp|
    sp.source_files = 'Sentinel/Classes/Loggie/**/*'
    sp.dependency 'Sentinel/Core'
    sp.dependency 'Loggie', '~> 2.2'
  end
  
  s.subspec 'Bugsnatch' do |sp|
    sp.source_files = 'Sentinel/Classes/Bugsnatch/**/*'
    sp.dependency 'Sentinel/Core'
    sp.dependency 'Bugsnatch/Core', '~> 1.0'
  end
  
#  This won't work untill AnalyticsCollector is added to main cocapods repo
  s.subspec 'AnalyticsCollector' do |sp|
    sp.source_files = 'Sentinel/Classes/AnalyticsCollector/**/*'
    sp.dependency 'Sentinel/Core'
#    pod 'AnalyticsCollector', :git => 'https://github.com/infinum/ios-analytics-collector'
  end
  
  s.subspec 'Default' do |sp|
    sp.dependency 'Sentinel/Core'
    sp.dependency 'Sentinel/UserDefaults'
    sp.dependency 'Sentinel/CustomLocation'
    sp.dependency 'Sentinel/CustomInfo'
    sp.dependency 'Sentinel/GeneralInfo'
    sp.dependency 'Sentinel/TextEditing'
    sp.dependency 'Sentinel/OptionSwitch'
    sp.dependency 'Sentinel/PerformanceInfo'
  end
  
end