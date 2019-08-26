source 'https://github.com/CocoaPods/Specs.git'
source 'git@github.com:EnterTech/PodSpecs.git'

platform :ios, '9.0'
use_frameworks!

target 'BLETool' do

    pod 'BlocksKit', '~> 2.2'
    pod 'Then'
    pod 'iOSDFULibrary', :git => "git@github.com:qiubei/IOS-Pods-DFU-Library.git" , :branch => "master"
    pod 'SnapKit', '~> 4.0'
    pod 'SVProgressHUD', '~> 2.2'
    pod 'RxCocoa', '~> 4.0'
    pod 'SwiftyTimer', '~> 2.0'
    pod 'Files', '~> 2.0.0'
    pod 'PromiseKit', '~> 6.10.0'
end

target 'EnterBioModuleBLE' do
#   pod 'iOSDFULibrary', :git => "git@github.com:qiubei/IOS-Pods-DFU-Library.git" , :branch => "master"
    pod 'RxSwift', '~> 4.5'
    pod 'RxBluetoothKit', '~> 5.0.2'
    pod 'PromiseKit', '~> 6.10.0'
end


post_install do |installer|
    installer.pods_project.targets.each do |target|
        if ['iOSDFULibrary'].include? "#{target}"
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.0'
            end
        end
    end
#    installer.pods_project.targets.each do |target|
#        if ['SnapKit'].include? "#{target}"
#            target.build_configurations.each do |config|
#                config.build_settings['SWIFT_VERSION'] = '4.0'
#            end
#        end
#    end
    installer.pods_project.targets.each do |target|
        if ['RxBluetoothKit'].include? "#{target}"
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.0'
            end
        end
    end
end

