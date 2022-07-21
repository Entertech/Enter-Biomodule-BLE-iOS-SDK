//
//  ScanViewController.swift
//  EnterBioModuleBLE
//
//  Created by NyanCat on 25/10/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import UIKit
import CoreBluetooth
import SVProgressHUD
import RxSwift
import EnterBioModuleBLE

class ScanViewController: UITableViewController {

    let disposeBag: DisposeBag = DisposeBag()

    var isScanning: Bool = false

    var peripheralList: [ScannedPeripheral] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableHeader()
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableView.automaticDimension
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        stopScan()
    }

    @IBAction func scanButtonTouched(_ sender: UIButton) {
        if isScanning {
            stopScan()
        } else {
            startScan()
        }
        isScanning = !isScanning
        self.navigationItem.rightBarButtonItem?.title =  isScanning ? "Stop" : "Scan"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pushToService" {
            let vc = segue.destination as! PeripheralViewController
            vc.peripheral = _selectedPeripheral
        }
    }

    // MARK: - Delegates

    // MARK: TableView Delegate

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripheralList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deviceCellIdentifier", for: indexPath)
        let item = peripheralList[indexPath.row]
        cell.textLabel?.text = item.peripheral.displayName
        cell.detailTextLabel?.text = item.rssi.stringValue
        cell.imageView?.image = (item.peripheral.state == .connected ? #imageLiteral(resourceName: "icon_bluetooth") : #imageLiteral(resourceName: "icon_bluetooth_disconnect"))
        cell.imageView?.highlightedImage = cell.imageView?.image
        return cell
    }

    private var _selectedPeripheral: Peripheral?

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        _selectedPeripheral = peripheralList[indexPath.row].peripheral
        return indexPath
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    private func updatePeripheralIfNeeded(_ peripheral: CBPeripheral) {
        if let index = self.peripheralList.firstIndex(where: { $0.peripheral.identifier == peripheral.identifier }) {
            let indexPath = IndexPath(row: index, section: 0)
            dispatch_to_main {
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
    private let sanner: EnterBioModuleBLE.EnterScanner = EnterScanner()
    private var textField: UITextField?
    private func tableHeader() {
        /// 今天的数据
        let tableviewHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30))
        let uuidLabel = UILabel(frame: CGRect.init(x: 20, y: 3, width: 50, height: 24))
        uuidLabel.text = "UUID:"
        tableviewHeaderView.addSubview(uuidLabel)
        textField = UITextField(frame: CGRect.init(x: 80, y: 3, width: UIScreen.main.bounds.width-100, height: 24))
        textField?.placeholder = "FF10"
        textField?.text = "FF10"
        textField?.borderStyle = .roundedRect
        textField?.returnKeyType = .done
        tableviewHeaderView.addSubview(textField!)
        tableView.tableHeaderView = tableviewHeaderView
    }
    private var scannerUUID = "-1212-ABCD-1523-785FEABCD123"
    private func startScan() {
        clear()
        let uniqueKey = textField?.text ?? "FF10"
        let uuid = "0000" + uniqueKey + scannerUUID
        sanner.scan(uuid: uuid)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (peripheral) in
                guard let `self` = self else { return }
                self.peripheralList.append(peripheral)
                let indexPath = IndexPath(row: self.peripheralList.count-1, section: 0)
                self.tableView.insertRows(at: [indexPath], with: .bottom)
            })
            .disposed(by: disposeBag)
    }

    private func stopScan() {
        sanner.stop()
    }

    private func clear() {
        self.peripheralList = []
        self.tableView.reloadData()
    }
}
