Pod::Spec.new do |s|
  s.name             = 'EnterBioModuleBLE'
  s.version          = '1.1.2'
  s.summary          = 'EnterBioModuleBLE 通信库'
  s.description      = <<-DESC
EnterBioModuleBLE 通信库
                       DESC

  s.homepage         = 'https://github.com/EnterTech'
  s.author           = { 'halo_yd' => 'haloqiubei@gmail.com' }
  s.license          = 'LICENSE'
  s.source           = { :git => 'git@github.com:Entertech/Enter-Biomodule-BLE-iOS-SDK.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'EnterBioModuleBLE/**/*.swift'
  s.dependency 'PromiseKit'
  s.dependency 'RxBluetoothKit'

end
