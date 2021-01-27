# SDK API

- [SDK API](#sdk-api)
  - [Device Related API](#device-related-api)
    - [Device Scan](#device-scan)
    - [Device Connection](#device-connection)
  - [Service Related](#service-related)
    - [Single Ordinary Service](#single-ordinary-service)
    - [Get Brainwave Data](#get-brainwave-data)
    - [Get Heart Rate Data](#get-heart-rate-data)
    - [Get Heart Rate And EEG Data At The Same Time](#get-heart-rate-and-eeg-data-at-the-same-time)
    - [Wear Testing](#wear-testing)
    - [DFU Service](#dfu-service)

## Device Related API

### Device Scan

**Interface Description**

Scan the surrounding Bluetooth devices.

**Example Code**

~~~swift
// scanner is an instance of Scanner object
scanner.scan().observeOn(MainScheduler.asyncInstance)
             .subscribe(onNext: { (peripheral) in
                // peripheral is the device object you scanned
            }).disposed(by: disposeBag)
~~~

**Stop Scanning**

~~~swift 
sanner.stop()
~~~

### Device Connection

**Interface Description**

Connect the specified Peripheral object.

**Code Example**

~~~swift
// Create a connector based on the specified Peripheral object. Generally it is the peripheral from scan().
let connector = Connector(peripheral: peripheral)
firstly {
        connector.tryConnect()
        }.done {
            // connect successed
            // All services supported by the device can be obtained through the connector. connector.allServices
        }.catch { (error) in
            // connect failed
    }
~~~

**Disconnect**

~~~swift
connector.cancel()
~~~


**Bluetooth Service Description**

> Services generally have three types of applications: a single common service, a combination of services, and DFU services.

## Service Related

### Single Ordinary Service

Ordinary Service include `Battery` 和 `Device Infomation`。

**Description**

This kind of service can obtain the information returned by the hardware directly through the characteristic of the service (property) such as read or notify.

e.g. `Battery`
**Voltage To Power Calculation Formula**

This voltage formula is applied to model 401015, with a capacity of 40mAh, and a rated voltage of 3.7V. If your device is not of this model, please define the formula according to actual needs

```
voltage is x (uint: V)


【1】q：remaining battery [0 - 100]

	q =  a1*exp(-((x-b1)/c1)^2) + a2*exp(-((x-b2)/c2)^2) + a3*exp(-((x-b3)/c3)^2)

	q = max([min([q, 100]), 0])


       		a1 =       99.84
       		b1 =       4.244
       		c1 =      0.3781
       		a2 =       21.38
       		b2 =       3.953
       		c2 =      0.1685
       		a3 =       15.21
       		b3 =       3.813
       		c3 =     0.09208


【2】t is Remaining usage time (uint: min):

	t = 4.52*q
```

**Sample Code**

~~~swift
// self.service is one of allServices obtained after the above connector is successfully connected
if let service = self.service as? BatteryService {
    service.read(characteristic: .battery).done { data in
        // there is only one byte in data.
        // read batery from data.copiedBytes[0]
        // The voltage is obtained here, please refer to the above formula to calculate the power
    }.catch { _ in
        // Failed to read value!
    }
}
~~~

**Parameter Description**

|       Parameter        |   Type   |      Description       |
| :---------------: | :------: | :-------------: |
|     .battery      | Enum | UUID of battery voltage |
| .hardwareRevision | Enum | UUID of the hardware version |
| .firmwareRevision | Enum | UUID of the firmware version |
|       .mac        | Enum | UUID of MAC address  |

**Service Composition**
>Some functions require multiple services to be combined to meet demand.

### Get Brainwave Data

**Description**

EEG needs `Command service` and `EEG service` used in combination, `EEG service` is responsible for monitoring hardware return data. `Command service` sending to the hardware `0x01` instructions that tell the hardware to start sending acquisition of EEG data（Note: To obtain EEG data must be open to wearing detection monitor ）. Send 0x02stop the acquisition.

**Sample Code**

~~~swift
// I.  Turn on the eeg wearing test (must be turned on, otherwise you will not receive brain wave data)
self.eegService.notify(characteristic: .contact)
            .subscribe (onNext: {
            print("wear contact data is \($0.first!)")
        })
        
// II. Enable eeg monitoring 
// eegService can be obtained through the Connector instance object after a successful connection.
self.eegService.notify(characteristic: Characteristic.EEG.data)
    .subscribe(onNext: { [weak self] data in 
         // data is the EEG data packet. After removing the 2 bytes of the header, the rest is EEG data.
        var received = data
        received.removeFirst(2)
       // do something. e.g. cache data
        }, onError: { _ in
            // Failed to listen brainwave data.
    })
    
// III. Send acquisition instructions to the hardware: 1. instruction = 0x01 start acquisition 2. instructio = 0x02 stop acquisition 
// commandService can be obtained through the Connector instance object after successful connection.
commandService.write(data: Data(bytes: [instruction]), to: .send).done {
        // successed to send command
        // do something
    }.catch { _ in
    // Failed to send 'xxx' command!")
}
~~~

**Parameter Description**

|   Parameter      |         Type         |                        Description                           |
| :---: | :----------: |   :-------------------------------------------:   |
|   .data   | Enum | UUID corresponding to service characteristics |
|   .send   | Enum | UUID corresponding to service characteristics |

### Get Heart Rate Data

**Description**

It needs `Heart rate service` and `Command service` used in combination. `Heart rate service` It is responsible for monitoring hardware return data, `Command service` sending to the hardware `0x03` that tell the hardware to start sending ECG data acquisition, Send `0x04` stop the acquisition.

**Sample Code**

~~~swift
// I. urn on heart rate monitoring 
// heartService can be obtained through the Connector instance object after a successful connection.
self.heartService.notify(characteristic: .data)
    .observeOn(MainScheduler.asyncInstance)
    .subscribe(onNext: { [weak self] data in
        // data is heart rate 
    })
        
// II. Send acquisition instructions to the hardware: 1. instruction = 0x03 start acquisition 2. instructio = 0x04 stop acquisition 
// commandService can be obtained through the Connector instance object after the connection is successful.
commandService.write(data: Data(bytes: [instruction]), to: .send).done {
        // successed to send command
        // do something
    }.catch { _ in
    // Failed to send 'xxx' command!")
}
~~~
 
**Parameter Description**

|Parameter|Type|Description|
| :---: | :----: |:----:|
|.data| Enum | UUID corresponding to service characteristics |
|.send| Enum | UUID corresponding to service characteristics |

### Get Heart Rate And EEG Data At The Same Time

**Description**

It needs `Heart rate service`, `EEG service` and `Command service` used in combination.  `Command serivce` sending to the hardware `0x05` that tell the hardware ECG and EEG start sending data collected. Send `0x06` stop the acquisition.

**Sample Code**

~~~swift
// I. Turn on heart rate monitoring 
// heartService can be obtained through the Connector instance object after a successful connection.
self.heartService.notify(characteristic: .data)
    .observeOn(MainScheduler.asyncInstance)
    .subscribe(onNext: { [weak self] data in
        // data is heart rate 
    })
  
// II. Enable eeg monitoring 
// eegService can be obtained through the Connector instance object after a successful connection.
self.eegService.notify(characteristic: Characteristic.EEG.data)
    .subscribe(onNext: { [weak self] data in 
         // data is the EEG data packet. After removing the 2 bytes of the header, the rest is EEG data.
        var received = data
        received.removeFirst(2)
       // do something. e.g. cache data
        }, onError: { _ in
            // Failed to listen brainwave data.
    })
   
// III. Send acquisition instructions to the hardware: 1. instruction = 0x05 start acquisition 2. instructio = 0x06 stop acquisition 
// commandService can be obtained through the Connector instance object after a successful connection.
commandService.write(data: Data(bytes: [instruction]), to: .send).done {
        // successed to send command
        // do something
    }.catch { _ in
    // Failed to send 'xxx' command!")
}
~~~

**Parameter Description**

|Parameter|Type|Description|
| :---: | :----: |:----:|
|.data| Enum | UUID corresponding to service characteristics |
|.send| Enum | UUID corresponding to service characteristics |

### Wear Testing

**Description**

 To see if the hardware point of electrode contact with the skin is good,， `EEG Service` sending `0x07` turn off monitoringBut to notify the contact to have data, you need to turn on brain wave data.

**示例代码**

~~~swift
// I. Turn on the wearing detection and monitoring, bind the wearing monitoring to the eeg service, and send the parameters. Contact is turned on
self.eegService.notify(characteristic: .contact)
            .observeOn(MainScheduler())
            .subscribe(onNext: { data in
                // data is wearing test data, please refer to relevant documents for the meaning of specific data
            }, onError: { _ in
                // Failed to listen wearing state.
            }).disposed(by: _disposeBag)

// II. Send collection instructions to the hardware: 1. instruction = 0x07 
// commandService can be obtained through the Connector instance object after the connection is successful.
commandService.write(data: Data(bytes: [instruction]), to: .send).done {
        // successed to send command
        // do something
    }.catch { _ in
    // Failed to send 'xxx' command!")
}
~~~

**Parameter Description**

|   Parameter   |   Type   |        Description         |
| :------: | :------: | :-----------------: |
| .contact | Enum | UUID corresponding to service characteristics |
|  .send   | Enum | UUID corresponding to service characteristics |

### DFU Service

**Description**

DFU（Device Firmware Update）firmware update, firmware update is a separate service

**DFU steps**

1. Set the url address
2. Upgrade by incoming url address
3. Create listener `dfuStateChanged`
4. Get upgrade callback

~~~swift
// Create a listener
NotificationCenter.default.addObserver(self, selector: #selector(didFirmwareUpdateStateChanged(_:)), name: NSNotification.Name(rawValue: "dfuStateChanged"), object: nil)

// Incoming firmware url
do {
        // bleManger is an instance of BleManager
        try bleManager.dfu(fileURL: url) 
} catch {
        print(error.localizedDescription)
}
// Implement the monitoring method and complete the callback
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