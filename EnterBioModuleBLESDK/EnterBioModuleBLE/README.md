# SDK 说明

- [SDK 说明](#sdk-%e8%af%b4%e6%98%8e)
  - [接入环境](接入环境)
  - [快速接入](#%e5%bf%ab%e9%80%9f%e6%8e%a5%e5%85%a5)
    - [蓝牙连接](#%e8%93%9d%e7%89%99%e8%bf%9e%e6%8e%a5)
    - [脑电服务订阅](#%e8%84%91%e7%94%b5%e6%9c%8d%e5%8a%a1%e8%ae%a2%e9%98%85)
    - [心率数据订阅](#%e5%bf%83%e7%8e%87%e6%95%b0%e6%8d%ae%e8%ae%a2%e9%98%85)
  - [API说明](#api%e8%af%b4%e6%98%8e)
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

请参见[EnterrBioModuleBLE API说明](../../APIDocuments/)

## Demo

请参见[EnterBioModuleBLEDemo](../EnterBioModuleBLEDemo/)
