//
//  Characteristic.swift
//  EnterBioModuleBLE
//
//  Created by HyanCat on 27/10/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation
import CoreBluetooth

public protocol CharacteristicType {
    var uuid: CBUUID { get }
}

extension CharacteristicType where Self : RawRepresentable {
    public var uuid: CBUUID {
        return CBUUID(string: self.rawValue as! String)
    }
}

public protocol CharacteristicReadType: CharacteristicType {}

public protocol CharacteristicWriteType: CharacteristicType {}

public protocol CharacteristicNotifyType: CharacteristicType {}

public enum Characteristic {
    public enum DeviceInfo: String, CharacteristicReadType {
        case mac = "2A24"
        case serial = "2A25"
        case firmwareRevision = "2A26"
        case hardwareRevision = "2A27"
        case manufacturer = "2A29"
    }

    public enum Battery: String, CharacteristicReadType, CharacteristicNotifyType {
        case battery = "2A19"
    }
    public enum Command {
        public enum Write: String, CharacteristicWriteType {
            case send = "0000FF21-1212-ABCD-1523-785FEABCD123"
        }
        public enum Notify: String, CharacteristicNotifyType {
            case receive = "0000FF22-1212-ABCD-1523-785FEABCD123"
        }
    }

    public enum Connect {
        public enum Write: String, CharacteristicWriteType {
            case userID = "0000FF11-1212-ABCD-1523-785FEABCD123"
        }
        public enum Notify: String, CharacteristicNotifyType {
            case state = "0000FF13-1212-ABCD-1523-785FEABCD123"
        }
    }

    public enum EEG: String, CharacteristicNotifyType {
        case data = "0000FF31-1212-ABCD-1523-785FEABCD123"
        case contact = "0000FF32-1212-ABCD-1523-785FEABCD123"
    }

    public enum DFU: String, CharacteristicWriteType {
        case control = "0000FF41-1212-ABCD-1523-785FEABCD123"
        case package = "0000FF42-1212-ABCD-1523-785FEABCD123"
    }

    public enum Heart {
        public enum Notify: String, CharacteristicNotifyType {
            case data = "0000FF51-1212-ABCD-1523-785FEABCD123"
        }
    }
}
