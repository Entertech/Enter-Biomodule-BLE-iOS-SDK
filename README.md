# Enter Biomodule BLE SDK

# 目录

* [SDK 说明](#SDK-说明)
    * [结构说明](#结构说明)
    * [安装集成](#安装集成)
        * [CocoaPods](#CocoaPods)
        * [Carthage](#Carthage)
        * [集成提示](#集成提示)
    * [整合接口BLEManager](#整合接口BLEManager)
        * [蓝牙连接](#蓝牙连接)
        * [脑电服务订阅](#脑电服务订阅)
        * [心率数据订阅](#心率数据订阅)
    * [API说明](#API说明)

# SDK 说明
## 介绍

本 SDK 包含回车生物电采集模块的蓝牙连接和生物电采集控制。通过此 SDK 可以在 iOS app 里快速实现和我们的采集模块连接，并控制其进行数据的采集和停止等指令。`EnterBioModuleBLEUI`提供了蓝牙连接的UI和通过蓝牙升级固件的UI

## 结构说明

> 运行 Demo 需要 `pod install` 和 `carthage bootstrap`
 
工程有两部分组成：Demo + SDK framework 源码。 
如图：

![Project Structure](img/structure.png)

## 安装集成

集成我们的 SDK 有以下方式：

### CocoaPods

1. add the following to your `Podfile`

~~~swift
pod 'EnterBioModuleBLE', :git=> "git@github.com:Entertech/Enter-Biomodule-BLE-iOS-SDK.git"
pod 'EnterBioModuleBLEUI' #(根据需求添加)
~~~

2. Integrate your dependencies using frameworks: add use_frameworks! to your `Podfile`.
3. Run `pod install`

### Carthage

1. add the following to your `Cartfile`

~~~ruby
github "EnterTech/Enter-Biomodule-BLE-iOS-SDK" "master"
~~~

2. Run `carthage update --platform iOS`

### 集成提示

> 因为`EnterBioModuleBLEUI`库依赖一个私有库, 在引用时请添加

```swift
target yourTarget do
    pod 'iOSDFULibrary', :git => "git@github.com:Entertech/IOS-Pods-DFU-Library.git" , :branch => "master"
end
```

## 快速接入

> 为了能够简单快捷的调用以上硬件连接接口和服务接口，将接口做了整合

### 蓝牙连接

~~~swift
// 扫描周围设备3秒，取信号最强的一个进行连接, 同时将开启电量服务
let manager = BLEManager()
manager.scanAndConnect { completed in
    // your code
}
~~~

~~~swift 
// 断开链接
manager.disconnect()
~~~

实现订阅协议 BLEStateDelegate, 获取连接状态，获取电量
~~~swift 
manager.delegate = self

/// 数据连接的代理方法
func bleConnectionStateChanged(state: BLEConnectionState, bleManager: BLEManager) {}

/// 电量获取的代理方法
func bleBatteryReceived(battery: Battery, bleManager: BLEManager) {}
~~~


### 脑电服务订阅

~~~swift 
// 订阅脑电数据，并打开脱落检测
manager.startEEG()
~~~

~~~swift 
// 关闭脑电数据订阅
manager.stopEEG()
~~~

实现订阅协议 BLEBioModuleDataSource, 获取EEG数据
~~~swift 
// 实现代理
manager.dataSource = self

/// eeg数据获取的代理方法
func bleBrainwaveDataReceived(data: Data, bleManager: BLEManager){}
~~~

### 心率数据订阅

~~~swift
// 开启脑电数据订阅
manager.startHeartRate()
~~~

~~~swift
// 关闭脑电数据订阅
manager.stopHeartRate()
~~~

实现订阅协议 BLEBioModuleDataSource, 获取心率数据

~~~swift
// 实现代理
manager.dataSource = self

/// 心率获取的代理方法
func bleHeartRateDataReceived(data: Data, bleManager: BLEManager){}
~~~

### 蓝牙连接UI

| 参数              | 类型    | 默认值  | 说明                                                       |
| ----------------- | ------- | ------- | ---------------------------------------------------------- |
| cornerRadius      | CGFloat | 8       | 控件圆角                                                   |
| mainColor         | UIColor | #0064FF | 主色调                                                     |
| isConnectByMac    | Bool    | false   | true时, 第一次连接设备会记录mac地址,后续连接会判断是否匹配 |
| firmwareVersion   | String  | "0.0.1" | 如果您拥有新固件,连接后会判断新固件版本是否比当前当高      |
| firmwareURL       | URL     | nil     | 放入沙盒的固件位置                                         |
| firmwareUpdateLog | String  | ""      | 更新内容说明                                               |

~~~swift
let connection = BLEConnectViewController(bleManager: manager)
// let connection = BLEConnectViewController(bleManagers: [manager1, manager2]] //多个设备时使用
connection.cornerRadius = 6
connection.mainColor = UIColor(red: 0, green: 100.0/255.0, blue: 1, alpha: 1)
connection.isConnectByMac = true // mac地址连接

/********如果有固件文件需要升级*******************/
// connection.firmwareVersion  = "2.2.2"
// connection.firmwareURL = Bundle.main.url(forResource: "1.2.1", withExtension: "zip")
// connection.firmwareUpdateLog = "1.请在此输入日志信息。\n2.更新内容1。\n3.更新内容2。"
self.present(connection, animated: true, completion: nil)
~~~

## API说明
请参见[EnterrBioModuleBLE API说明](APIDocuments/API.md)