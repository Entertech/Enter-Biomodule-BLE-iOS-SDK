//
//  DeviceConnectionViewController.swift
//  EnterBioModuleBLEUI
//
//  Created by Enter on 2019/10/9.
//  Copyright © 2019 EnterTech. All rights reserved.
//

import UIKit
import SnapKit
import EnterBioModuleBLE

class DeviceConnectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    public var cornerRadius: CGFloat = 8
    
    public var mainColor: UIColor = UIColor.colorFromInt(r: 0, g: 100, b: 255, alpha: 1)
    
    var deviceNum = 1
    var tableView: UITableView?
    init(ble: BLEManager) {
        super.init(nibName: nil, bundle: nil)
        BLEManagerClass.shared.bleList = [ble]
        deviceNum = 1
       
    }
    
    init(bleArray: [BLEManager]) {
        super.init(nibName: nil, bundle: nil)
        deviceNum = bleArray.count
        if deviceNum > 4 {
            self.deviceNum = 4
        }
        
        for i in 0..<deviceNum {
            BLEManagerClass.shared.bleList.append(bleArray[i])
        }

        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setNavigationItem()
        if let corner = BLEManagerClass.shared.cornerRadius {
           cornerRadius = corner
        }
        if let color = BLEManagerClass.shared.mainColor {
           
           self.mainColor = color
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView?.reloadData()
        
    }
    
    func setUI() {
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = .systemBackground
        } else {
            // Fallback on earlier versions
            self.view.backgroundColor = .white
        }
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView?.delegate = self
        tableView?.dataSource = self
        self.view.addSubview(tableView!)
        tableView?.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceNum
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "com.entertech.ble"
        let cell:  UITableViewCell
        if let reuseView = tableView.dequeueReusableCell(withIdentifier: identifier) {
            cell = reuseView
        } else {
            cell = UITableViewCell(style: .value1, reuseIdentifier: identifier)
        }
        cell.textLabel?.text = "设备\(indexPath.row+1)"
        if BLEManagerClass.shared.bleList[indexPath.row].state.isConnected {
            cell.detailTextLabel?.text = "已连接"
        } else {
            cell.detailTextLabel?.text = "未连接"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stateView = BLEConnectTipViewController(index: indexPath.row)
        stateView.cornerRadius = self.cornerRadius
        stateView.mainColor = self.mainColor
        self.navigationController?.pushViewController(stateView, animated: true)
    }
    

    
    private func setNavigationItem() {
        let backItem = UIBarButtonItem(image: UIImage.loadImage(name: "icon_back", any: classForCoder), style: .plain, target: self, action: #selector(backAction))
        self.navigationItem.leftBarButtonItem = backItem
        self.navigationItem.title = "设备连接"
    }
    
    @objc private func backAction() {
        self.navigationController?.dismiss(animated: true, completion: nil)
        
    }
}
