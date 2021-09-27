Pod::Spec.new do |s|
  s.name             = 'EnterBioModuleBLE'
  s.version          = '2.0.6'
  s.summary          = 'EnterBioModuleBLE 通信库'
  s.description      = <<-DESC
EnterBioModuleBLE 通信库
                       DESC

  s.homepage         = 'https://github.com/EnterTech'
  s.author           = { 'Like' => 'ke.liful@gmail.com' }
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.source           = { :git => 'https://github.com/Entertech/Enter-Biomodule-BLE-iOS-SDK.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'EnterBioModuleBLESDK/EnterBioModuleBLE/**/*.swift'
  s.dependency 'PromiseKit'
  s.dependency 'RxBluetoothKit'
  s.dependency 'FixedDFUService', '~> 4.7.2'
end
