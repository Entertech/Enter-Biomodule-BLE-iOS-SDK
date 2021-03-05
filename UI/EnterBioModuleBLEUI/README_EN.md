# Bluetooth Management UI Library

- [Bluetooth Management UI Library](#bluetooth-management-ui-library)
  - [Demo](#demo)
  - [Connect UI](#connect-ui)
    - [Parameters](#parameters)
    - [How To Use](#how-to-use)
    - [View](#view)
  - [Firmware Upgrade UI](#firmware-upgrade-ui)
    - [Parameters](#parameters-1)
    - [How To Use](#how-to-use-1)
    - [View](#view-1)

## Demo

Please refer to [EnterBioModuleBLEUIDemo](../EnterBioModuleBLEDemo/)。

[Heart Flow App](https://github.com/Entertech/Enter-AffectiveCloud-Demo-iOS.git) This demo application integrates basic Bluetooth functions, Bluetooth device management interface, emotional cloud SDK, and custom data display controls, showing that brain wave and heart rate data are collected from hardware to upload emotional cloud real-time analysis and finally generate analysis reports and data display the whole process.

## Connect UI

This UI library opens an entry module `BLEConnectViewController`, inherited from ViewController, parameters and calling methods are as follows:

### Parameters

| Parameter           | Type    | Defaults  | Description                                                       |
| -------------- | ------- | ------- | ---------------------------------------------------------- |
| cornerRadius   | CGFloat | 8       | rounded corners                                                   |
| mainColor      | UIColor | #0064FF | main color                                                  |
| isConnectByMac | Bool    | false   | When true, the mac address will be recorded when the device is connected for the first time, and subsequent connections will determine whether it matches |

### How To Use

~~~swift
let connection = BLEConnectViewController(bleManager: manager) // manager please see the description below 
// let connection = BLEConnectViewController(bleManagers: [manager1, manager2]] //Used for multiple devices
connection.cornerRadius = 6
connection.mainColor = UIColor(red: 0, green: 100.0/255.0, blue: 1, alpha: 1)
connection.isConnectByMac = true // mac address connection
self.present(connection, animated: true, completion: nil)
~~~

`BLEConnectViewController` Description of incoming parameters:

| Parameter        | Type            | Description               |
| ----------- | --------------- | ------------------ |
| bleManager  | BLEManager      | Examples of Bluetooth Management Module |
| bleManagers | BLEManager array | An array of instances of the Bluetooth management module for multi-device connection    |

`BLEManager` In the Bluetooth basic module SDK. See [EnterBioModuleBLESDK](../../EnterBioModuleBLESDK/EnterBioModuleBLE/)。

### View

<img src="https://github.com/Entertech/Enter-Biomodule-BLE-iOS-SDK/blob/master/img/Lark21.jpeg" width="300">

## Firmware Upgrade UI

This UI is optional. When the firmware needs to be upgraded, our upgrade UI can be configured as follows.

### Parameters

| parameter              | Type   | Defaults  | Description                                                  |
| ----------------- | ------ | ------- | ----------------------------------------------------- |
| firmwareVersion   | String | "0.0.1" | If you have new firmware, after connecting, it will judge whether the new firmware version is higher than the current one  |
| firmwareURL       | URL    | nil     | The location of the firmware placed in the sandbox                                   |
| firmwareUpdateLog | String | ""      | Update description                                       |

### How To Use

```swift
// let connection = BLEConnectViewController(bleManager: manager) add the following parameters when the Bluetooth connection UI is integrated
connection.firmwareVersion  = "1.2.1"
connection.firmwareURL = Bundle.main.url(forResource: "1.2.1", withExtension: "zip")
connection.firmwareUpdateLog = " 1. Please input log information here. \n 2. Update content 1. \n 3. Update content 2. "
```

### View

When setting to upgrade the firmware, there will be an upgrade prompt after connecting Bluetooth.

<img src="https://github.com/Entertech/Enter-Biomodule-BLE-iOS-SDK/blob/master/img/Lark22.jpeg" width="300">

After clicking the upgrade prompt, go to the upgrade interface.

<img src="https://github.com/Entertech/Enter-Biomodule-BLE-iOS-SDK/blob/master/img/Lark23.jpeg" width="300">
