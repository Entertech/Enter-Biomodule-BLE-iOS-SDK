# SDK 说明

[English Readme](/README_EN.md)

- [SDK 说明](#sdk-说明)
  - [接入环境](#接入环境)
  - [快速接入](#快速接入)
    - [蓝牙连接](#蓝牙连接)
    - [脑电服务订阅](#脑电服务订阅)
    - [心率数据订阅](#心率数据订阅)
  - [API说明](#api说明)
  - [Demo](#demo)

## 接入环境

- Xcode 11
- Swift 5.0

## 快速接入

> 为了能够简单快捷的调用以上硬件连接接口和服务接口，将接口做了整合。

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

实现订阅协议 BLEStateDelegate, 获取连接状态，获取电量。
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

实现订阅协议 BLEBioModuleDataSource, 获取EEG数据。
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

实现订阅协议 BLEBioModuleDataSource, 获取心率数据。

~~~swift
// 实现代理
manager.dataSource = self

/// 心率获取的代理方法
func bleHeartRateDataReceived(data: Data, bleManager: BLEManager){}
~~~

## API说明

请参见[EnterrBioModuleBLE API说明](../../APIDocuments/API.md)

## Demo

本sdk请参见[EnterBioModuleBLEDemo](../EnterBioModuleBLEDemo/)

[心流](https://github.com/Entertech/Enter-AffectiveCloud-Demo-iOS.git)  这个演示应用集成了基础蓝牙功能、蓝牙设备管理界面、情感云SDK、以及自定义的数据展示控件，较好的展示了脑波及心率数据从 硬件中采集到上传情感云实时分析最后产生分析报表及数据展示的整个过程。
