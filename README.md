# Enter Biomodule BLE SDK

# 目录

- [Enter Biomodule BLE SDK](#enter-biomodule-ble-sdk)
- [目录](#%e7%9b%ae%e5%bd%95)
  - [介绍](#%e4%bb%8b%e7%bb%8d)
  - [Demo演示](#Demo演示)
  - [结构说明](#%e7%bb%93%e6%9e%84%e8%af%b4%e6%98%8e)
  - [安装集成](#%e5%ae%89%e8%a3%85%e9%9b%86%e6%88%90)
    - [环境要求](#%e7%8e%af%e5%a2%83%e8%a6%81%e6%b1%82)
    - [集成方式](#%e9%9b%86%e6%88%90%e6%96%b9%e5%bc%8f)
  - [蓝牙SDK](#%e8%93%9d%e7%89%99sdk)
  - [蓝牙UI](#%e8%93%9d%e7%89%99ui)

## 介绍

SDK 包含回车生物电采集模块的蓝牙连接和生物电采集控制。通过此 SDK 可以在 iOS app 里快速实现和我们的采集模块连接，并控制其进行数据的采集和停止等指令。UI模块提供了蓝牙连接的UI和通过蓝牙升级固件的UI。

## Demo演示

[心流](https://github.com/Entertech/Enter-AffectiveCloud-Demo-iOS.git)这个演示应用集成了基础蓝牙功能、蓝牙设备管理界面、情感云SDK、以及自定义的数据展示控件，较好的展示了脑波及心率数据从 硬件中采集到上传情感云实时分析最后产生分析报表及数据展示的整个过程。

## 开发组件

> 运行 Demo 需要 `pod install` 
 
工程有两部分组成：UI + SDK 。 
如图：

<img src="https://github.com/Entertech/Enter-Biomodule-BLE-iOS-SDK/blob/master/img/1.png?raw=true" width="600">

## 安装集成

### 环境要求

- Xcode版本: Xcode11

- 系统版本: iOS 11以上

### 集成方式

CocoaPods

1. 在`Podfile`中添加如下配置信息。

```
#(蓝牙SDK)
pod 'EnterBioModuleBLE'

#(蓝牙UI库，根据需求添加)
pod 'EnterBioModuleBLEUI' 
```

1. 在`Podfile`中添加 `add use_frameworks!`。
2. 运行 `pod install`。

## BLE基础SDK

> 提供模块连接及数据采集功能。

详细请参见[BLE基础SDK](EnterBioModuleBLESDK/)

## 蓝牙UI

> 提供标准的蓝牙连接及固件升级UI。

详细请参见[蓝牙UI](UI/)
