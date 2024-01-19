#
# Be sure to run `pod lib lint Sentinel.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Sentinel'
  s.version          = '1.1.3'
  s.summary          = 'Developer\'s toolbox for debugging applications'

  s.description      = <<-DESC
  Sentinel is a simple library which gives developers a possibility to configure one entry point for every debug tool.
  The idea of Sentinel is to give ability to developers to configure screen with multiple debug tools which are available via some event (e.g. shake, notification).
                       DESC

  s.homepage         = 'https://github.com/infinum/ios-sentinel'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Infinum' => 'ios@infinum.com', 'Vlaho Poluta' => 'vlaho.poluta@infinum.com', 'Nikola Majcen' => 'nikola.majcen@infinum.com' }
  s.source           = { :git => 'https://github.com/infinum/ios-sentinel.git', :tag => s.version.to_s }

  s.requires_arc = true
  s.platform = :ios
  s.swift_version = '5.0'
  s.ios.deployment_target = '11.0'
  s.resource_bundles = {
      'Sentinel' => ['Sentinel/Assets/**/*'],
    }
  s.resources = 'Sentinel/Assets/**/*.{pdf}'
  s.default_subspec = 'Default'
  
  s.subspec 'Core' do |sp|
    sp.source_files = 'Sentinel/Classes/Core/**/*'
    sp.frameworks = 'UIKit'
  end
  
  s.subspec 'UserDefaults' do |sp|
    sp.source_files = 'Sentinel/Classes/UserDefaults/**/*'
    sp.dependency 'Sentinel/Core'
  end

  s.subspec 'EmailSender' do |sp|
    sp.source_files = 'Sentinel/Classes/EmailSender/**/*'
    sp.dependency 'Sentinel/Core'
  end

  s.subspec 'CustomLocation' do |sp|
    sp.source_files = 'Sentinel/Classes/CustomLocation/**/*'
    sp.dependency 'Sentinel/Core'
  end
  
  s.subspec 'TextEditing' do |sp|
    sp.source_files = 'Sentinel/Classes/TextEditing/**/*'
    sp.dependency 'Sentinel/Core'
  end
  
  s.subspec 'Loggie' do |sp|
    sp.source_files = 'Sentinel/Classes/Loggie/**/*'
    sp.dependency 'Sentinel/Core'
    sp.dependency 'Loggie'
  end
  
  s.subspec 'Collar' do |sp|
    sp.source_files = 'Sentinel/Classes/Collar/**/*'
    sp.dependency 'Sentinel/Core'
    sp.dependency 'Collar'
  end
  
  s.subspec 'Default' do |sp|
    sp.dependency 'Sentinel/Core'
    sp.dependency 'Sentinel/UserDefaults'
    sp.dependency 'Sentinel/CustomLocation'
    sp.dependency 'Sentinel/TextEditing'
  end
  
end
