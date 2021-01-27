# SDK

- [SDK](#sdk)
  - [Environment](#environment)
  - [Quick Access](#quick-access)
    - [Bluetooth Connection](#bluetooth-connection)
    - [EEG Service Subscription](#eeg-service-subscription)
    - [Heart Rate Data Subscription](#heart-rate-data-subscription)
  - [API Description](#api-description)
  - [Demo](#demo)

## Environment

- Xcode 11
- Swift 5.0

## Quick Access

> In order to be able to call the above hardware connection interface and service interface simply and quickly, the interfaces are integrated.

### Bluetooth Connection

~~~swift
// Scan the surrounding devices for 3 seconds, connect with the one with the strongest signal, and turn on the battery service
let manager = BLEManager()
manager.uploadCycle = 3 // The upload cycle required by Emotion Cloud, the default value is 3, and the upload cycle is 0.6*3=1.8 seconds. Please check Emotion Cloud documentation for details
manager.scanAndConnect { completed in
    // your code
}
~~~

~~~swift
// Disconnect
manager.disconnect()
~~~

Implement the subscription protocol BLEStateDelegate, get the connection status and get the power.
~~~swift 
manager.delegate = self

/// Proxy method of data connection
func bleConnectionStateChanged(state: BLEConnectionState, bleManager: BLEManager) {}

/// Proxy method for power acquisition
func bleBatteryReceived(battery: Battery, bleManager: BLEManager) {}
~~~


### EEG Service Subscription

~~~swift 
// Subscribe to EEG data and turn on drop detection
manager.startEEG()
~~~

~~~swift 
// Turn off EEG data subscription
manager.stopEEG()
~~~

Realize the subscription protocol BLEBioModuleDataSource to obtain EEG data.
~~~swift 
// Realize the agent
manager.dataSource = self

/// Delegate method for eeg data acquisition
func bleBrainwaveDataReceived(data: Data, bleManager: BLEManager){}
~~~

### Heart Rate Data Subscription

~~~swift
// Open EEG data subscription
manager.startHeartRate()
~~~

~~~swift
// Turn off EEG data subscription
manager.stopHeartRate()
~~~

实现订阅协议 BLEBioModuleDataSource, 获取心率数据。

~~~swift
// Realize the datasource
manager.dataSource = self

func bleHeartRateDataReceived(data: Data, bleManager: BLEManager){}
~~~

## API Description

See [EnterrBioModuleBLE API Document](../../APIDocuments/API_EN.md)

## Demo

See [EnterBioModuleBLEDemo](../EnterBioModuleBLEDemo/)

[Heart Flow App](https://github.com/Entertech/Enter-AffectiveCloud-Demo-iOS.git) This demo application integrates basic Bluetooth functions, Bluetooth device management interface, emotional cloud SDK, and custom data display controls, showing that brain wave and heart rate data are collected from hardware to upload emotional cloud real-time analysis and finally generate analysis reports and data display the whole process.