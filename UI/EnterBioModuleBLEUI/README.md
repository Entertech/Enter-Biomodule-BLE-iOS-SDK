# 蓝牙管理UI库

- [蓝牙管理UI库](#%e8%93%9d%e7%89%99%e7%ae%a1%e7%90%86ui%e5%ba%93)
  - [Demo](#demo)
  - [连接UI](#%e8%bf%9e%e6%8e%a5ui)
    - [属性](#%e5%b1%9e%e6%80%a7)
    - [集成方式](#%e9%9b%86%e6%88%90%e6%96%b9%e5%bc%8f)
    - [图示](#%e5%9b%be%e7%a4%ba)
  - [固件升级UI](#%e5%9b%ba%e4%bb%b6%e5%8d%87%e7%ba%a7ui)
    - [属性](#%e5%b1%9e%e6%80%a7-1)
    - [集成方式](#%e9%9b%86%e6%88%90%e6%96%b9%e5%bc%8f-1)
    - [图示](#%e5%9b%be%e7%a4%ba-1)

## Demo

本SDK请参见[EnterBioModuleBLEUIDemo](../EnterBioModuleBLEDemo/)

[心流](https://github.com/Entertech/Enter-AffectiveCloud-Demo-iOS.git) 这个演示应用集成了基础蓝牙功能、蓝牙设备管理界面、情感云SDK、以及自定义的数据展示控件，较好的展示了脑波及心率数据从 硬件中采集到上传情感云实时分析最后产生分析报表及数据展示的整个过程。

## 连接UI

本UI库开放一个入口模块`BLEConnectViewController`，继承自ViewController，参数及调用方法如下：

### 属性

| 参数           | 类型    | 默认值  | 说明                                                       |
| -------------- | ------- | ------- | ---------------------------------------------------------- |
| cornerRadius   | CGFloat | 8       | 控件圆角                                                   |
| mainColor      | UIColor | #0064FF | 主色调                                                     |
| isConnectByMac | Bool    | false   | true时, 第一次连接设备会记录mac地址,后续连接会判断是否匹配 |

### 集成方式

~~~swift
let connection = BLEConnectViewController(bleManager: manager) // manager 请看下面说明
// let connection = BLEConnectViewController(bleManagers: [manager1, manager2]] //多个设备时使用
connection.cornerRadius = 6
connection.mainColor = UIColor(red: 0, green: 100.0/255.0, blue: 1, alpha: 1)
connection.isConnectByMac = true // mac地址连接
self.present(connection, animated: true, completion: nil)
~~~

`BLEConnectViewController`传入参数说明：

| 参数        | 类型            | 说明               |
| ----------- | --------------- | ------------------ |
| bleManager  | BLEManager      | 蓝牙管理模块的实例 |
| bleManagers | BLEManager 数组 | 蓝牙管理模块的实例数组，用于多设备连接     |

`BLEManager`在蓝牙基础模块SDK中，请参见[EnterBioModuleBLESDK](../../EnterBioModuleBLESDK/EnterBioModuleBLE/)

### 图示

<img src="https://github.com/Entertech/Enter-Biomodule-BLE-iOS-SDK/blob/master/img/IMG_0830.PNG" width="300">

## 固件升级UI

本UI为可选,固件需要升级时,可如下配置使用我们的升级UI。

### 属性 

| 参数              | 类型   | 默认值  | 说明                                                  |
| ----------------- | ------ | ------- | ----------------------------------------------------- |
| firmwareVersion   | String | "0.0.1" | 如果您拥有新固件,连接后会判断新固件版本是否比当前当高 |
| firmwareURL       | URL    | nil     | 放入沙盒的固件位置                                    |
| firmwareUpdateLog | String | ""      | 更新内容说明                                          |

### 集成方式

```swift
// let connection = BLEConnectViewController(bleManager: manager) 在蓝牙连接UI集成时添加下列参数
connection.firmwareVersion  = "1.2.1"
connection.firmwareURL = Bundle.main.url(forResource: "1.2.1", withExtension: "zip")
connection.firmwareUpdateLog = "1.请在此输入日志信息。\n2.更新内容1。\n3.更新内容2。"
```

### 图示

当设置升级固件时, 连接蓝牙后会有升级提示。

<img src="https://github.com/Entertech/Enter-Biomodule-BLE-iOS-SDK/blob/master/img/IMG_0832.PNG" width="300">

点击升级提示后, 转到升级界面。

<img src="https://github.com/Entertech/Enter-Biomodule-BLE-iOS-SDK/blob/master/img/IMG_0831.PNG" width="300">
