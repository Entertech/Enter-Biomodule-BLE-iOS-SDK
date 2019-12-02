//
//  CharacteristicViewController.swift
//  EnterBioModuleBLE
//
//  Created by NyanCat on 28/10/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import UIKit
import CoreBluetooth
import RxBluetoothKit
import RxSwift
import SVProgressHUD
import EnterBioModuleBLE

class CharacteristicViewController: UITableViewController {

    var service: BLEService!

    private var _characteristics: [RxBluetoothKit.Characteristic] = []

    let disposeBag: DisposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()

        _characteristics = service.rxService.characteristics ?? []

        if let service = self.service as? BatteryService {
            service.notify(characteristic: .battery)
                .observeOn(MainScheduler.asyncInstance)
                .subscribe(onNext: { bytes in
                    SVProgressHUD.showInfo(withStatus: "battery: \(bytes[0])")
                    print("notify battery: \(bytes[0])")
                }, onError: { _ in
                    SVProgressHUD.showError(withStatus: "监听电量失败")
                })
                .disposed(by: disposeBag)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _characteristics.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "characteristicCellIdentifier", for: indexPath)
        let characteristic = _characteristics[indexPath.row]
        cell.textLabel?.text = characteristic.displayName
        cell.detailTextLabel?.text = characteristic.uuid.uuidString
        return cell
    }

    var _selectedCharacteristic: RxBluetoothKit.Characteristic?

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        _selectedCharacteristic = _characteristics[indexPath.row]
        return indexPath
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let cell = tableView.cellForRow(at: indexPath)
        let characteristic = _characteristics[indexPath.row]
        if let service = self.service as? BatteryService {
            service.read(characteristic: .battery).done {
                cell?.detailTextLabel?.text = String(format: "%d%%", $0.copiedBytes[0])
            }.catch { _ in
                SVProgressHUD.showError(withStatus: "Failed to read value!")
            }
        }
        if let service = self.service as? DeviceInfoService, let characteristic = Characteristic.DeviceInfo(rawValue: characteristic.uuid.uuidString) {
            service.read(characteristic: characteristic).done { data -> Void in
                if characteristic == .mac {
                    cell?.detailTextLabel?.text = data.hexString
                } else {
                    cell?.detailTextLabel?.text = String(data: data, encoding: .utf8)
                }
            }.catch { _ in
                SVProgressHUD.showError(withStatus: "Failed to read value!")
            }
        }
    }
}
