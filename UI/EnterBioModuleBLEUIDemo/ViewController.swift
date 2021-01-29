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
        //Single connection
        let connection = BLEConnectViewController(bleManager: ble)
        
        //multi connection
//        let ble2 = BLEManager()
//        let connection = BLEConnectViewController(bleManagers: [ble, ble2])
        
        connection.cornerRadius = 6
        connection.mainColor = UIColor(red: 0, green: 100.0/255.0, blue: 1, alpha: 1)
        
        // Firmware Update
        connection.firmwareVersion  = "2.2.2"
        connection.firmwareURL = Bundle.main.url(forResource: "dfutest0730", withExtension: "zip")
        connection.firmwareUpdateLog = "1.Log"
        
        //mac address
        connection.isConnectByMac = false
        
        
        self.present(connection, animated: true, completion: nil)
    }
    
}

