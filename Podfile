source 'https://github.com/CocoaPods/Specs.git'
source 'git@github.com:EnterTech/PodSpecs.git'

platform :ios, '9.0'
use_frameworks!

target 'BLETool' do
    pod 'Then'
    pod 'iOSDFULibrary', :git => "git@github.com:Entertech/IOS-Pods-DFU-Library.git" , :branch => "master"
    pod 'SnapKit'
    pod 'SVProgressHUD', '~> 2.2'
    pod 'RxCocoa', :git => "git@github.com:ReactiveX/RxSwift.git", :branch  => "master"
    pod 'RxSwift', :git => "git@github.com:ReactiveX/RxSwift.git", :branch  => "master"
    pod 'SwiftyTimer', '~> 2.0'
    pod 'Files', '~> 2.2.1'
    pod 'PromiseKit'
end

target 'EnterBioModuleBLE' do
#    pod 'iOSDFULibrary', :git => "git@github.com:Entertech/IOS-Pods-DFU-Library.git" , :branch => "master"
    pod 'RxSwift', :git => "git@github.com:ReactiveX/RxSwift.git", :branch  => "master"
    pod 'RxBluetoothKit', '~> 5.3.0'
    pod 'PromiseKit'
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
#    installer.pods_project.targets.each do |target|
#        if ['RxBluetoothKit'].include? "#{target}"
#            target.build_configurations.each do |config|
#                config.build_settings['SWIFT_VERSION'] = '4.0'
#            end
#        end
#    end
end

