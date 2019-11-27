# SDK API 说明

- [SDK API 说明](#sdk-api-%e8%af%b4%e6%98%8e)
  - [设备相关 API](#%e8%ae%be%e5%a4%87%e7%9b%b8%e5%85%b3-api)
    - [设备扫描](#%e8%ae%be%e5%a4%87%e6%89%ab%e6%8f%8f)
    - [设备连接](#%e8%ae%be%e5%a4%87%e8%bf%9e%e6%8e%a5)
  - [服务相关](#%e6%9c%8d%e5%8a%a1%e7%9b%b8%e5%85%b3)
    - [单个普通服务](#%e5%8d%95%e4%b8%aa%e6%99%ae%e9%80%9a%e6%9c%8d%e5%8a%a1)
    - [获取脑波数据](#%e8%8e%b7%e5%8f%96%e8%84%91%e6%b3%a2%e6%95%b0%e6%8d%ae)
    - [获取心率数据](#%e8%8e%b7%e5%8f%96%e5%bf%83%e7%8e%87%e6%95%b0%e6%8d%ae)
    - [同时获取心率和脑电数据](#%e5%90%8c%e6%97%b6%e8%8e%b7%e5%8f%96%e5%bf%83%e7%8e%87%e5%92%8c%e8%84%91%e7%94%b5%e6%95%b0%e6%8d%ae)
    - [佩戴检测](#%e4%bd%a9%e6%88%b4%e6%a3%80%e6%b5%8b)
    - [DFU 服务](#dfu-%e6%9c%8d%e5%8a%a1)

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
**电池电压转电量计算公式**

```
已知电压为x（单位：V）


【1】剩余电量百分比q（单位：%；取值范围：0~100）表达式：

	q =  a1*exp(-((x-b1)/c1)^2) + a2*exp(-((x-b2)/c2)^2) + a3*exp(-((x-b3)/c3)^2)	# 高斯拟合曲线

	q = max([min([q, 100]), 0])	# 取值范围限制在0~100

	其中参数值如下:
       		a1 =       99.84
       		b1 =       4.244
       		c1 =      0.3781
       		a2 =       21.38
       		b2 =       3.953
       		c2 =      0.1685
       		a3 =       15.21
       		b3 =       3.813
       		c3 =     0.09208


【2】剩余使用时长t（单位：min）表达式：

	t = 4.52*q
```

**示例代码**

~~~swift
// self.service 是上面 connector 连接成功之后获取的 allServices 之一
if let service = self.service as? BatteryService {
    service.read(characteristic: .battery).done { data in
        // there is only one byte in data.
        // read batery from data.copiedBytes[0]
        // 此处得到电压, 计算电量请参考上述公式
    }.catch { _ in
        // Failed to read value!
    }
}
~~~

**参数说明**

|       参数        |   类型   |      说明       |
| :---------------: | :------: | :-------------: |
|     .battery      | 枚举类型 | 电池电压的 UUID |
| .hardwareRevision | 枚举类型 | 硬件版本的 UUID |
| .firmwareRevision | 枚举类型 | 固件版本的 UUID |
|       .mac        | 枚举类型 | MAC地址的 UUID  |

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

|   参数      |         类型         |                        说明                           |
| :---: | :----------: |   :-------------------------------------------:   |
|   .data   | 枚举类型 | 对应服务特性的 UUID |
|   .send   | 枚举类型 | 对应服务特性的 UUID |

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
   
// III. 向硬件发送采集指令: 1. instruction = 0x05 开始采集 2. instructio = 0x06 停止采集 
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

 要查看硬件的电极点是否与皮肤接触好，我们通过 `eeg 服务` 的 contact 特性（Characteristic）,发送·`0x07`开启脱落监测。但是要 contact 的 notify 有数据，需要开启脑波数据。

**示例代码**

~~~swift
// I. 开启佩戴检测监听,佩戴监测与 eeg 服务绑定, 发送参数 .contact开启
self.eegService.notify(characteristic: .contact)
            .observeOn(MainScheduler())
            .subscribe(onNext: { data in
                // data 为佩戴检测数据，具体数据表示的含义请参考相关文档
            }, onError: { _ in
                // Failed to listen wearing state.
            }).disposed(by: _disposeBag)

// II. 向硬件发送采集指令: 1. instruction = 0x07
// commandService 可通过连接成功之后的 Connector 实例对象获得。 
commandService.write(data: Data(bytes: [instruction]), to: .send).done {
        // successed to send command
        // do something
    }.catch { _ in
    // Failed to send 'xxx' command!")
}
~~~

**参数说明**

|   参数   |   类型   |        说明         |
| :------: | :------: | :-----------------: |
| .contact | 枚举类型 | 对应服务特性的 UUID |
|  .send   | 枚举类型 | 对应服务特性的 UUID |

### DFU 服务

**说明**

DFU（Device Firmware Update）固件更新，固件更新是单独的一个服务

**DFU 步骤**

1. 设置好url地址
2. 通过传入url地址升级
3. 创建监听`dfuStateChanged`
4. 获取升级回调

~~~swift
// 创建监听
NotificationCenter.default.addObserver(self, selector: #selector(didFirmwareUpdateStateChanged(_:)), name: NSNotification.Name(rawValue: "dfuStateChanged"), object: nil)

// 传入固件 url
do {
        // bleManger是BleManager的实例
        try bleManager.dfu(fileURL: url) 
} catch {
        print(error.localizedDescription)
}
// 实现监听方法,完成回调
@objc private func didFirmwareUpdateStateChanged(_ notification: Notification) {
        if let info = notification.userInfo,
            let state = info["dfuStateKey"] as? DFUState {

            switch state {

            case .none:
                break
            case .prepared:
                break
            case .upgrading(let progress):
                break
            case .succeeded:
                break
            case .failed:
                break

            }
        }

    }
~~~

