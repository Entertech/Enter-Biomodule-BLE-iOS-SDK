Pod::Spec.new do |s|
    s.name             = 'EnterBioModuleBLEUI'
    s.version          = '1.2.5'
    s.summary          = 'EnterBioModuleBLE 通信库UI'
    s.description      = <<-DESC
  EnterBioModuleBLE 通信库UI库
                         DESC
  
    s.homepage         = 'https://github.com/EnterTech'
    s.author           = { 'Like' => 'ke.liful@gmail.com' }
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.source           = { :git => 'https://github.com/Entertech/Enter-Biomodule-BLE-iOS-SDK.git', :tag => s.version.to_s }
  
    s.ios.deployment_target = '11.0'
    s.swift_version = '5'
    s.source_files = 'UI/EnterBioModuleBLEUI/**/*.swift'
    s.resources = "UI/EnterBioModuleBLEUI/**/*.{xcassets,gif}"
    s.dependency 'EnterBioModuleBLE', '1.2.5'
    s.dependency 'SnapKit'
 
  
  end
  