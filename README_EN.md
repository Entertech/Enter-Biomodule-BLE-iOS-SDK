# Enter Biomodule BLE SDK

# Table Of Contents

- [Enter Biomodule BLE SDK](#enter-biomodule-ble-sdk)
- [Table Of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Demo Presentation](#demo-presentation)
  - [Development Components](#development-components)
    - [BLE Basic SDK](#ble-basic-sdk)
    - [Bluetooth UI](#bluetooth-ui)
  - [Installation Integration](#installation-integration)
    - [Environmental Requirements](#environmental-requirements)
    - [Integration Method](#integration-method)

## Introduction

The SDK includes Bluetooth connection and bioelectric acquisition control of the enter bioelectric acquisition module. Through this SDK, you can quickly connect to our collection module in the iOS app, and control it for data collection and stop commands. The UI module provides the UI for Bluetooth connection and the UI for upgrading firmware via Bluetooth.

## Demo Presentation

We provide the [Heart FLow App](https://github.com/Entertech/Enter-AffectiveCloud-Demo-iOS.git) This demo application integrates basic Bluetooth functions, Bluetooth device management interface, emotional cloud SDK, and custom data display controls, showing that brain wave and heart rate data are collected from hardware to upload emotional cloud real-time analysis and finally generate analysis reports and data display the whole process.

## Development Components

> Required to run `pod install` 
 
The project consists of two parts: UI + SDK. As shown:

<img src="https://github.com/Entertech/Enter-Biomodule-BLE-iOS-SDK/blob/master/img/1.png?raw=true" width="600">

### BLE Basic SDK

> Provide module connection and data collection functions.

Please refer to [BLE Basic SDK](EnterBioModuleBLESDK/).

### Bluetooth UI

> Provide standard Bluetooth connection and firmware upgrade UI.

Please refer to [BLE UI](UI/).

## Installation Integration

### Environmental Requirements

- Xcode version: Xcode11 and above

- System version: iOS 11 and above

### Integration Method

CocoaPods

1. In `Podfile` add the following configuration information.

```
use_frameworks!

pod 'EnterBioModuleBLE'

# Add as needed 
pod 'EnterBioModuleBLEUI' 
```

2. Run `pod install`.