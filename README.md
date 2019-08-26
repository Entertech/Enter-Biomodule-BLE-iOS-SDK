# Enter Biomodule BLE SDK

# 目录

* [SDK 说明](#SDK-说明)
    * [结构说明](#结构说明)
    * [安装集成](#安装集成)
        * [CocoaPods](#CocoaPods)
        * [Carthage](#Carthage)
* [SDK API 说明](#SDK-API-说明)
    * [设备相关 API](#设备相关-API)
        * [设备扫描](#设备扫描)
        * [设备链接](#设备链接)
    * [服务相关](#服务相关)
        * [单个普通服务](#单个普通服务)
        * [获取脑波数据](#获取脑波数据)
        * [获取心率数据](#获取心率数据)
        * [同时获取心率和脑电数据](#同时获取心率和脑电数据)
        * [佩戴检测](#佩戴检测)
        * [DFU 服务](#DFU-服务)
    * [整合接口BLEManager](#整合接口BLEManager)
        * [蓝牙连接](#蓝牙连接)
        * [脑电服务订阅](#脑电服务订阅)
        * [心率数据订阅](#心率数据订阅)

# SDK 说明
## 介绍

本 SDK 包含回车生物电采集模块的蓝牙连接和生物电采集控制。通过此 SDK 可以在 iOS app 里快速实现和我们的采集模块连接，并控制其进行数据的采集和停止等指令。

## 结构说明

> 运行 Demo 需要 `pod install` 和 `carthage bootstrap`
 
工程有两部分组成：Demo + SDK framework 源码。 
如图：

![Project Structure](https://github.com/EnterTech/FlowTimeBLESDK_iOS/blob/master/img/structure.png)


## 安装集成

集成我们的 SDK 有以下方式：

### CocoaPods 

1. add the following to your `Podfile`

~~~swift
pod 'EnterBioModuleBLE', :git=> "git@github.com:Entertech/Enter-Biomodule-BLE-iOS-SDK.git"
~~~

2. Integrate your dependencies using frameworks: add use_frameworks! to your `Podfile`.
3. Run `pod install`

### Carthage

1. add the following to your `Cartfile`

~~~ruby
github "EnterTech/Enter-Biomodule-BLE-iOS-SDK" "master"
~~~

2. Run `carthage update --platform iOS`

# SDK API 说明

## 设备相关 API

### 设备扫描

**接口说明**

扫描周围的蓝牙设备。

**实例代码**

~~~swift
// scanner 是 Scanner 对象实例
scanner.scan().observeOn(MainScheduler.asyncInstance)
             .subscribe(onNext: { (peripheral) in
                // peripheral 是你扫描的设备对象
            }).disposed(by: disposeBag)
~~~

**停止扫描**

~~~swift 
sanner.stop()
~~~

### 设备连接

**接口说明**

连接指定的 Peripheral 对象。

**代码实例**

~~~swift
// 根据指定的 Peripheral 对象创建连接器。一般是 scan() 出来的 peripheral。
let connector = Connector(peripheral: peripheral)
firstly {
        connector.tryConnect()
        }.done {
            // connect successed
            // 可通过 connector 获取设备的所支持的所有服务。connector.allServices
        }.catch { (error) in
            // connect failed
    }
~~~

**断开连接**

~~~swift
connector.cancel()
~~~


> 蓝牙服务说明
> 服务一般有三类应用：单个普通服务、服务的组合以及 DFU 服务。

## 服务相关

### 单个普通服务

普通服务包括有 `电池信息服务` 和 `设备信息服务`。

**说明**

这类服务直接通过服务的特性（Characteristic）的属性（property）如：read 或 notify 可获取硬件返回的信息。

e.g. `电池信息服务`
**示例代码**

~~~swift
// self.service 是上面 connector 连接成功之后获取的 allServices 之一
if let service = self.service as? BatteryService {
    service.read(characteristic: .battery).done { data in
        // there is only one byte in data.
        // read batery from data.copiedBytes[0]
    }.catch { _ in
        // Failed to read value!
    }
}
~~~

**参数说明**

|参数|类型|说明|
| :---: | :----: |:----:|
|.battery| 枚举类型 | 对应服务特性的 UUID |

>服务组合
>有些功能需要多个服务组合起来才能满足需求。

### 获取脑波数据

**说明**

脑波数据心率数据需要 `Command 服务` 和 `eeg 服务` 组合起来使用。`脑电(eeg)服务` 负责监听硬件的返回数据，通过 `Command 服务` 向硬件发送 `0x01` 指令，告诉硬件开始发送采集的脑电数据（注意：*要想获取脑波数据一定要开启佩戴检测监听*）。发送 `0x02` 停止采集。

**示例代码**

~~~swift
// I. 开启 eeg 佩戴检测（必须要开，否者会收不到脑波数据）
self.eegService.notify(characteristic: .contact)
            .subscribe (onNext: {
            print("wear contact data is \($0.first!)")
        })
        
// II. 开启 eeg 监听
// eegService 可通过连接成功之后的 Connector 实例对象获得。
self.eegService.notify(characteristic: Characteristic.EEG.data)
    .subscribe(onNext: { [weak self] data in 
         // data 就是脑电数据包，去除包头的 2 个字节剩下的就是脑电数据。
        var received = data
        received.removeFirst(2)
       // do something. e.g. cache data
        }, onError: { _ in
            // Failed to listen brainwave data.
    })
    
// III. 向硬件发送采集指令: 1. instruction = 0x01 开始采集 2. instructio = 0x02 停止采集
// commandService 可通过连接成功之后的 Connector 实例对象获得。 
commandService.write(data: Data(bytes: [instruction]), to: .send).done {
        // successed to send command
        // do something
    }.catch { _ in
    // Failed to send 'xxx' command!")
}
~~~

**参数说明**

|参数|类型|说明|
| :---: | :----: |:----:|
|.data| 枚举类型 | 对应服务特性的 UUID |
|.send| 枚举类型 | 对应服务特性的 UUID |

### 获取心率数据

**说明**

采集心率数据需要 `心率服务` 和 `Command 服务` 组合起来使用。`心率服务` 负责监听硬件的返回数据，通过 `Command 服务` 向硬件发送 `0x03` 指令，告诉硬件开始发送采集的心电数据。发送 `0x04` 停止采集。

**示例代码**

~~~swift
// I. 开启心率监听
// heartService 可通过连接成功之后的 Connector 实例对象获得。
self.heartService.notify(characteristic: .data)
    .observeOn(MainScheduler.asyncInstance)
    .subscribe(onNext: { [weak self] data in
        // data is heart rate 
    })
        
// II. 向硬件发送采集指令: 1. instruction = 0x03 开始采集 2. instructio = 0x04 停止采集 
// commandService 可通过连接成功之后的 Connector 实例对象获得。
commandService.write(data: Data(bytes: [instruction]), to: .send).done {
        // successed to send command
        // do something
    }.catch { _ in
    // Failed to send 'xxx' command!")
}
~~~
 
**参数说明**

|参数|类型|说明|
| :---: | :----: |:----:|
|.data| 枚举类型 | 对应服务特性的 UUID |
|.send| 枚举类型 | 对应服务特性的 UUID |

### 同时获取心率和脑电数据

**说明**

同时获取心率和脑电数据需要 `eeg 服务`、`心率服务` 和 `Command 服务` 组合起来使用。`心率服务` 和 `eeg 服务` 负责监听硬件的返回数据，通过 `Command 服务` 向硬件发送 `0x05` 指令，告诉硬件开始发送采集的心电和脑电数据。发送 `0x06` 停止采集。

**示例代码**

~~~swift
// I. 开启心率监听
// heartService 可通过连接成功之后的 Connector 实例对象获得。
self.heartService.notify(characteristic: .data)
    .observeOn(MainScheduler.asyncInstance)
    .subscribe(onNext: { [weak self] data in
        // data is heart rate 
    })
  
// II. 开启 eeg 监听
// eegService 可通过连接成功之后的 Connector 实例对象获得。
self.eegService.notify(characteristic: Characteristic.EEG.data)
    .subscribe(onNext: { [weak self] data in 
         // data 就是脑电数据包，去除包头的 2 个字节剩下的就是脑电数据。
        var received = data
        received.removeFirst(2)
       // do something. e.g. cache data
        }, onError: { _ in
            // Failed to listen brainwave data.
    })
   
// III. 向硬件发送采集指令: 1. instruction = 0x05 开始采集 2. instructio = 0x05 停止采集 
// commandService 可通过连接成功之后的 Connector 实例对象获得。
commandService.write(data: Data(bytes: [instruction]), to: .send).done {
        // successed to send command
        // do something
    }.catch { _ in
    // Failed to send 'xxx' command!")
}
~~~

**参数说明**

|参数|类型|说明|
| :---: | :----: |:----:|
|.data| 枚举类型 | 对应服务特性的 UUID |
|.send| 枚举类型 | 对应服务特性的 UUID |

### 佩戴检测

**说明**

要查看硬件的电极点是否与皮肤接触好，我们通过 `eeg 服务` 的 contact 特性（Characteristic）。但是要 contact 的 notify 有数据，需要开启脑波数据。需要通过 `Command 服务` 向硬件发送 `0x01` 指令，告诉硬件开始发送采集的脑电数据。发送 `0x02` 停止采集。

**示例代码**

~~~swift
// I. 开启佩戴检测监听
self.eegService.notify(characteristic: .contact)
            .observeOn(MainScheduler())
            .subscribe(onNext: { data in
                // data 为佩戴检测数据，具体数据表示的含义请参考相关文档
            }, onError: { _ in
                // Failed to listen wearing state.
            }).disposed(by: _disposeBag)

// II. 向硬件发送采集指令: 1. instruction = 0x01 开始采集 2. instructio = 0x02 停止采集
// commandService 可通过连接成功之后的 Connector 实例对象获得。 
commandService.write(data: Data(bytes: [instruction]), to: .send).done {
        // successed to send command
        // do something
    }.catch { _ in
    // Failed to send 'xxx' command!")
}
~~~

**参数说明**

|参数|类型|说明|
| :---: | :----: |:----:|
|.contact| 枚举类型 | 对应服务特性的 UUID |
|.send| 枚举类型 | 对应服务特性的 UUID |

### DFU 服务

**说明**

DFU（Device Firmware Update）固件更新，固件更新是单独的一个服务，通过第三方库 iOSDFULibrary 实现（注意：如果没有引用，可通过 `cocoapods` 引入，地址要与 Demo 一致）。

**DFU 步骤**

1. 连接设备。
2. 准备好要更新的固件包。
3. 创建 DFUServiceInitiator 对象。（可设置代理查看更新过程和状态）
4. 根据固件包设置 DFUFirmware 对象。
5. 将 DFUFirmware 对象给 DFUServiceInitiator 对象开始固件更新。

~~~swift
// 创建 DFUServiceInitiator 对象
let initiator = DFUServiceInitiator(centralManager: self.cManager, target: self.peripheral)
    // 设置代理监听更新过程
    initiator.delegate = self
    initiator.progressDelegate = self
    initiator.enableUnsafeExperimentalButtonlessServiceInSecureDfu = true
    // 根据固件包设置 DFUFirmware 对象。 url 为要更新的固件更新包路径。
    let firmware = DFUFirmware(urlToZipFile: url, type: DFUFirmwareType.application)
    // 将 DFUFirmware 对象给 DFUServiceInitiator 对象开始固件更新。
    let _ = initiator.with(firmware: firmware!).start()
~~~


> 为了能够简单快捷的调用以上硬件连接接口和服务接口，我们将以上介绍的接口做了整合，可根据自己需求选择使用
## 整合接口BLEManager

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
// 关闭脑电数据订阅
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









