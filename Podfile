source 'https://cdn.cocoapods.org/'

platform :ios, '13.0'
use_frameworks!

target 'EnterBioModuleBLEDemo' do
    pod 'Then'
    pod 'iOSDFULibrary', '4.13.0'
    pod 'SnapKit'
    pod 'SVProgressHUD', '~> 2.2'
    pod 'RxCocoa', '~> 6.0'
    pod 'RxSwift', '~> 6.0'
    pod 'SwiftyTimer', '~> 2.0'
    pod 'Files', '~> 2.2.1'
    pod 'PromiseKit', '~> 8.0'
end

target 'EnterBioModuleBLE' do
    pod 'iOSDFULibrary', '4.13.0'
    pod 'RxSwift', '~> 6.0'
    pod 'PromiseKit', '~> 8.0'
end

target 'EnterBioModuleBLEUI' do
    pod 'SnapKit'
end

target 'BluetoothConnectingUIDemo' do
    pod 'SnapKit'
    pod 'RxSwift', '~> 6.0'
    pod 'PromiseKit', '~> 8.0'
end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      end
    end
  end
end
