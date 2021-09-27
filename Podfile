source 'https://cdn.cocoapods.org/'

platform :ios, '11.0'
use_frameworks!

target 'EnterBioModuleBLEDemo' do
    pod 'Then'
    pod 'FixedDFUService', '~> 4.11'
    pod 'SnapKit'
    pod 'SVProgressHUD', '~> 2.2'
    pod 'RxCocoa', '6.0'
    pod 'RxSwift', '6.0'
    pod 'SwiftyTimer', '~> 2.0'
    pod 'Files', '~> 2.2.1'
    pod 'PromiseKit'
end

target 'EnterBioModuleBLE' do
    pod 'FixedDFUService', '~> 4.11'
    pod 'RxSwift', '6.0'
    pod 'RxBluetoothKit', :git => 'https://github.com/i-mobility/RxBluetoothKit.git', :tag => '7.0.2'
    pod 'PromiseKit'
end

target 'EnterBioModuleBLEUI' do
    pod 'SnapKit'
end

target 'BluetoothConnectingUIDemo' do
    pod 'SnapKit'
    pod 'RxSwift', '6.0'
    pod 'RxBluetoothKit', :git => 'https://github.com/i-mobility/RxBluetoothKit.git', :tag => '7.0.2'
    pod 'PromiseKit'
end


#post_install do |installer|
#    installer.pods_project.targets.each do |target|
#        if ['iOSDFULibrary'].include? "#{target}"
#            target.build_configurations.each do |config|
#                config.build_settings['SWIFT_VERSION'] = '4.0'
#            end
#        end
#    end
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
#end

