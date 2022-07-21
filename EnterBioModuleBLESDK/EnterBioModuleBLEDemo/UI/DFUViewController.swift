//
//  DFUViewController.swift
//  BLETool
//
//  Created by Anonymous on 2017/12/13.
//  Copyright © 2017年 EnterTech. All rights reserved.
//

import UIKit
import iOSDFULibrary
import CoreBluetooth
import SVProgressHUD

class DFUViewController: UIViewController, DFUServiceDelegate, DFUProgressDelegate {

    var cManager: CBCentralManager!
    var peripheral: CBPeripheral!
    private var firmwareFileURL: URL?

    @IBOutlet weak var coreTypeSwitch: UISwitch!
    @IBOutlet weak var peripheralName: UILabel!
    @IBOutlet weak var fileName: UILabel!
    @IBOutlet weak var fileSize: UILabel!
    @IBOutlet weak var fileType: UILabel!
    @IBOutlet weak var updatingPercentage: UILabel!


    @IBAction func uploadAction(_ sender: UIButton) {
        self.performDFU()
    }

    @IBAction func selectFileAction(_ sender: UIButton) {
        self.setupFileMessage()
    }

    @IBAction func scanDeviceAction(_ sender: UIButton) {
        self.peripheralName.text = peripheral.name
    }

    private var files: [URL]!

    private func setupFileMessage() {
        if let filename = Persistence.shared.dfuPacketName {
            self.fileName.text = filename
            self.fileType.text = ""
            self.fileSize.text = String(fileSizeWith(name: filename, type: "zip"))
            self.firmwareFileURL = Persistence.shared.dfuPacketURL
            
        }
    }

    private func fileSizeWith(name: String, type: String) -> Int {
        let fManager = FileManager.default
        let contentDatas = fManager.contents(atPath: Persistence.shared.dfuPacketURL!.path)
        return contentDatas?.count == nil ? 0 : contentDatas!.count
    }
    let dfuQueue = DispatchQueue.init(label: "DFU_Test")
    private func performDFU() {
        
        let initiator = DFUServiceInitiator(queue:dfuQueue)
        initiator.delegate = self
        initiator.progressDelegate = self
        initiator.enableUnsafeExperimentalButtonlessServiceInSecureDfu = true
        initiator.alternativeAdvertisingNameEnabled = false
        initiator.dataObjectPreparationDelay = 0.4
        initiator.packetReceiptNotificationParameter = 0
        initiator.logger = self
        if coreTypeSwitch.isOn {
            let customUUIDs = [ DFUUuid(withUUID: CBUUID(string: "0000FF40-1212-abcd-1523-785FEABCD123"), forType: .legacyService),
                                DFUUuid(withUUID: CBUUID(string: "0000FF41-1212-abcd-1523-785FEABCD123"), forType: .legacyControlPoint),
                                DFUUuid(withUUID: CBUUID(string: "0000FF42-1212-abcd-1523-785FEABCD123"), forType: .legacyPacket),
                                DFUUuid(withUUID: CBUUID(string: "0000FF44-1212-abcd-1523-785feabcd123"), forType: .legacyVersion),
                                ]
            // Set the custom UUDIds
            initiator.uuidHelper = DFUUuidHelper(customUuids: customUUIDs)
            initiator.forceScanningForNewAddressInLegacyDfu = true
        }
        if let url = self.firmwareFileURL {
            if let firmware = try? DFUFirmware(urlToZipFile: url, type: DFUFirmwareType.application) {
                let _ = initiator.with(firmware: firmware).start(target: self.peripheral)
            }
            
        } else {
            SVProgressHUD.showInfo(withStatus: "no available files")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.setupFileMessage()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        coreTypeSwitch.isOn = false
    }

    // dfu service delegate Method
    func dfuStateDidChange(to state: DFUState) {
        switch state {
        case .connecting:
            SVProgressHUD.showInfo(withStatus: "connecting")
        case .starting:
            SVProgressHUD.showInfo(withStatus: "starting dfu...")
        case .enablingDfuMode:
            SVProgressHUD.showInfo(withStatus: "enablingDfuMode dfu...")
        case .uploading:
            SVProgressHUD.showInfo(withStatus: "uploading dfu...")
        case .validating:
            SVProgressHUD.showInfo(withStatus: "validating dfu...")
        case .disconnecting:
            SVProgressHUD.showInfo(withStatus: "disconnecting dfu...")
        case .completed:
            self.updatingPercentage.text = String("完成")
            SVProgressHUD.showInfo(withStatus: "completed dfu...")
        case .aborted:
            SVProgressHUD.showInfo(withStatus: "aborted dfu...")
        }
    }

    func dfuError(_ error: DFUError, didOccurWithMessage message: String) {
        print("dfu error!!! \(message)")
    }

    // dfu progress delegate Method
    func dfuProgressDidChange(for part: Int, outOf totalParts: Int, to progress: Int, currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
        self.updatingPercentage.text = String("\(progress)% (\(part)/\(totalParts))")
    }
}

extension DFUViewController: LoggerDelegate {
    func logWith(_ level: LogLevel, message: String) {
        print(message)
    }
}
