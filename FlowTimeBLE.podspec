Pod::Spec.new do |s|
  s.name             = 'FlowTimeBLE'
  s.version          = '1.0.0'
  s.summary          = 'FlowTime BLE 通信库'
  s.description      = <<-DESC
FlowTime BLE 通信库
                       DESC

  s.homepage         = 'https://github.com/EnterTech'
  s.author           = { 'halo_yd' => 'haloqiubei@gmail.com' }
  s.license          = 'LICENSE'
  s.source           = { :git => 'git@github.com:EnterTech/FlowTimeBLESDK_iOS.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'FlowTimeBLE/**/*.swift'
  s.dependency 'PromiseKit'
  s.dependency 'RxBluetoothKit'
  s.dependency 'iOSDFULibrary'

end
