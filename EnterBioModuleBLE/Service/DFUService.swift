//
//  DFUService.swift
//  EnterBioModuleBLE
//
//  Created by HyanCat on 02/11/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation
import CoreBluetooth

//public protocol DFUStateDelegate: class {
//    func dfuStateChanged(state: DFUState)
//}

public class DFUService: BLEService {
}

extension DFUService: ServiceTypable {
    public var serviceType: ServiceType {
        return .dfu
    }
}

// TODO: - DFU
//
//public class DFU: DFUProgressDelegate, DFUServiceDelegate {
//    var fileURL: URL!
//    
//    private let peripheral: CBPeripheral
//    private let manager: CBCentralManager
//    public weak var delegate: DFUStateDelegate?
//    
//    init(peripheral: CBPeripheral, manager: CBCentralManager) {
//        self.peripheral = peripheral
//        self.manager = manager
//    }
//    
//    private (set) var state: DFUState = .none {
//        didSet {
//            //NotificationName.dfuStateChanged.emit([NotificationKey.dfuStateKey.rawValue: state])
//            delegate?.dfuStateChanged(state: state)
//        }
//    }
//    
//    public func fire() {
//        let initiator = DFUServiceInitiator(centralManager: manager, target: peripheral)
//        initiator.delegate = self
//        initiator.progressDelegate = self
//        initiator.enableUnsafeExperimentalButtonlessServiceInSecureDfu = true
//        let firmware = DFUFirmware(urlToZipFile: fileURL, type: DFUFirmwareType.application)
//        
//        _ = initiator.with(firmware: firmware!).start()
//    }
//    
//    public func dfuStateDidChange(to state: iOSDFULibrary.DFUState) {
//        print("dfu state: \(state.description())")
//        switch state {
//        case .connecting:
//            self.state = .prepared
//        case .starting:
//            self.state = .prepared
//        case .enablingDfuMode:
//            self.state = .prepared
//        case .uploading:
//            self.state = .prepared
//        case .validating:
//            self.state = .prepared
//        case .disconnecting:
//            break
//        case .completed:
//            self.state = .succeeded
//        case .aborted:
//            self.state = .failed
//        }
//    }
//    
//    public func dfuError(_ error: DFUError, didOccurWithMessage message: String) {
//        self.state = .failed
//    }
//    
//    public func dfuProgressDidChange(for part: Int, outOf totalParts: Int, to progress: Int, currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
//        self.state = .upgrading(progress: UInt8(progress))
//    }
//}

