//
//  ViewController.swift
//  BluetoothConnectingUIDemo
//
//  Created by Enter on 2019/10/22.
//  Copyright © 2019 EnterTech. All rights reserved.
//

import UIKit
import EnterBioModuleBLEUI
import EnterBioModuleBLE

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func showNavigation(_ sender: Any) {
        let ble = BLEManager()
        let connection = BLEConnectViewController(bleManager: ble)
        connection.cornerRadius = 6
        connection.mainColor = UIColor(red: 0, green: 100.0/255.0, blue: 1, alpha: 1)
        connection.firmwareVersion  = "2.2.2"
        connection.firmwareURL = Bundle.main.url(forResource: "dfutest1", withExtension: "zip")
        connection.firmwareUpdateLog = "1.请在此输入日志信息。\n2.更新内容1。\n3.更新内容2。"
        connection.isConnectByMac = true // mac地址连接
        self.present(connection, animated: true, completion: nil)
    }
    
}

