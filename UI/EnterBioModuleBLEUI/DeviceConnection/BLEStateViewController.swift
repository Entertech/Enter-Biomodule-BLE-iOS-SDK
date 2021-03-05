//
//  BLEStateViewController.swift
//  EnterBioModuleBLEUI
//
//  Created by Enter on 2019/10/23.
//  Copyright © 2019 EnterTech. All rights reserved.
//

import UIKit
import EnterBioModuleBLE

class BLEStateViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    public var cornerRadius: CGFloat = 8
    //MARK:- Public
    public var mainColor = UIColor.colorFromInt(r: 0, g: 100, b: 255, alpha: 1) {
        didSet {
            backgroundView?.backgroundColor = mainColor
        }
    }
    
    private var isMac: Bool = false
    
    //MARK:- Private
    private var ble: BLEManager?
    private var backgroundView: UIView?
    private var tableView: UITableView?
    private var animationView: UIImageView?
    private var connectingLabel: UILabel?
    private var reconnectView: UIView?
    private var reconnectLabel: UILabel?
    private var reconnectBtn: UIButton?
    private var batteryView: BatteryView?
    private let tipLabel = UILabel()
    private var index: Int = 0 //蓝牙数组里的第几个对象
    
    /// 是否通过mac地址连接
    private var mac:String?{
        get {
            return UserDefaults.standard.string(forKey: "MacAdderss\(index)")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "MacAdderss\(index)")
        }
    }
    
    //MARK:- Method
    init(index: Int, _ corner: CGFloat = 8, _ mainColor: UIColor = UIColor.colorFromInt(r: 0, g: 100, b: 255, alpha: 1)) {
        super.init(nibName: nil, bundle: nil)
        Language.initLocale()
        ble = BLEManagerClass.shared.bleList[index]
        self.mainColor = mainColor
        self.cornerRadius = corner
        isMac = UserDefaults.standard.bool(forKey: "isConnectByMac")
        self.index = index
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationItem()
        setUI()
        if let corner = BLEManagerClass.shared.cornerRadius {
           cornerRadius = corner
        }
        if let color = BLEManagerClass.shared.mainColor {
           
           self.mainColor = color
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(stateNotification(_:)), name: NSNotification.Name("BLEConnectionStateNotify"), object: nil)

        tableView?.reloadData()
        if ble!.state == .disconnected {
            self.connect()
        } else if ble!.state.isConnected {
            showBattery()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setUI() {
        
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = .systemBackground
        } else {
            self.view.backgroundColor = .white
        }
        
        backgroundView = UIView()
        backgroundView?.backgroundColor = mainColor
        self.view.addSubview(backgroundView!)
        backgroundView?.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.height.equalTo(232)
        }
        
        animationView = UIImageView()
        animationView?.animationImages = UIImage.resolveGifImage(gif: "loading", any: self.classForCoder)
        animationView?.animationDuration = 2
        animationView?.animationRepeatCount = Int.max
        
        connectingLabel = UILabel()
        connectingLabel?.text = lang("连接中...")
        connectingLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        connectingLabel?.textColor = .white
        
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView?.delegate = self
        tableView?.dataSource = self
        self.view.addSubview(tableView!)
        tableView?.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(self.backgroundView!.snp.bottom)
            $0.bottom.equalToSuperview()
        }
        
        batteryView = BatteryView()
        batteryView?.setup()
        batteryView?.layout()
        
        reconnectView = UIView()
        reconnectView?.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        reconnectLabel = UILabel()
        reconnectLabel?.text = lang("未找到设备")
        reconnectLabel?.textColor = .white
        reconnectLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        reconnectView?.addSubview(reconnectLabel!)
        reconnectLabel?.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        reconnectBtn = UIButton()
        reconnectBtn?.setTitle(lang("重新连接"), for: .normal)
        reconnectBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        reconnectBtn?.setTitleColor(.black, for: .normal)
        reconnectBtn?.backgroundColor = .white
        reconnectBtn?.layer.cornerRadius = 16
        reconnectBtn?.addTarget(self, action: #selector(reconnectAction), for: .touchUpInside)
        reconnectView?.addSubview(reconnectBtn!)
        reconnectBtn?.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(reconnectLabel!.snp.bottom).offset(45)
            $0.width.equalTo(92)
            $0.height.equalTo(32)
        }
        
        
        tipLabel.text = "new"
        tipLabel.textAlignment = .center
        tipLabel.textColor = .white
        tipLabel.font = UIFont.systemFont(ofSize: 12)
        tipLabel.backgroundColor = UIColor.colorFromInt(r: 255, g: 72, b: 82, alpha: 1)
        tipLabel.layer.cornerRadius = 11
        tipLabel.layer.masksToBounds = true
    }
    
    private func connect() {
        NotificationCenter.default.addObserver(self, selector: #selector(batteryNotification(_:)), name: NSNotification.Name("BatteryNotify"), object: nil)
        if let mac = mac, isMac {
            do {
                try ble?.scanAndConnect(mac) { (flag) in
                    if flag {
                        print("connect success")
                    } else {
                        print("connect failed")
                    }
                }
            } catch {
                print("unknow error \(error)")
            }
        } else {
            do {
                try ble?.scanAndConnect { (flag) in
                    if flag {
                        print("connect success")
                    } else {
                        print("connect failed")
                    }
                }
            } catch {
                print("unknow error \(error)")
            }
        }
         
    }
    
    
    /// 连接动画
    private func setConnectionAnimation() {
        removeAll()
        backgroundView?.addSubview(animationView!)

        animationView?.startAnimating()
        
        animationView?.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalTo(36)
            $0.width.equalTo(36)
        }
        
        backgroundView?.addSubview(connectingLabel!)
        
        connectingLabel?.snp.makeConstraints {
            $0.centerX.equalToSuperview().offset(10)
            $0.top.equalTo(animationView!.snp.bottom).offset(24)
        }
    }
    /// 结束动画
    private func removeAll() {
        for e in backgroundView!.subviews {
            e.snp.removeConstraints()
            e.removeFromSuperview()
        }

    }
    
    /// 显示电量
    private func showBattery() {
        removeAll()
        backgroundView?.addSubview(batteryView!)
        batteryView?.power = ble?.battery
        batteryView?.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.equalTo(150)
            $0.height.equalTo(150)
        }
    }
    
    /// 重连
    private func showReconnectView() {
        removeAll()
        backgroundView?.addSubview(reconnectView!)
        reconnectView?.snp.makeConstraints {
            $0.left.right.bottom.top.equalToSuperview()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if ble!.state.isConnected {
            if let _ = mac, isMac {
                return 3
            }
            return 2
        }
        if ble!.state == .disconnected {
            if let _ = mac, isMac  {
                return 2
            }
            
        }
        return 1
    }
    
    //MARK:- Tableview Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && ble!.state == .disconnected{
            return 4
        } else if section == 0 {
            return 3
        }
        if section == 1 {
            return 1
        }
        if section == 2 {
            return 1
        }
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var identifier = "com.entertech.ble.\(indexPath.section).\(indexPath.row)"
        if ble!.state == .disconnected {
            identifier = "com.entertech.ble.disconnected.\(indexPath.row)"
        }
        let cell:  UITableViewCell
        if let reuseView = tableView.dequeueReusableCell(withIdentifier: identifier) {
            cell = reuseView
        } else {
            if indexPath.section == 2 || indexPath.section == 1 {
                cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
            } else {
                cell = UITableViewCell(style: .value1, reuseIdentifier: identifier)
            }
           
        }
        
        
        if ble!.state == .disconnected {
            switch (indexPath.section, indexPath.row) {
            case (0, 0):
                cell.backgroundColor = UIColor.colorFromInt(r: 255, g: 72, b: 82, alpha: 1)
                cell.textLabel?.text = lang("无法连接设备？")
                cell.detailTextLabel?.text = ""
                cell.accessoryType = .disclosureIndicator
            case (0, 1):
                if let _ = tipLabel.superview {
                    tipLabel.snp.removeConstraints()
                    tipLabel.removeFromSuperview()
                }
                cell.textLabel?.text = lang("硬件版本")
                cell.detailTextLabel?.text = "0.0.0"
                cell.detailTextLabel?.textColor = .lightGray
                cell.accessoryType = .none
            case (0, 2):
                cell.textLabel?.text = lang("固件版本")
                cell.detailTextLabel?.text = "0.0.0"
                cell.detailTextLabel?.textColor = .lightGray
                cell.accessoryType = .none
            case (0, 3):
                cell.textLabel?.text = lang("蓝牙地址")
                cell.accessoryType = .none
                cell.detailTextLabel?.text = "00.00.00.00.00.00"
                cell.detailTextLabel?.textColor = .lightGray
            case (1, 0):
                cell.textLabel?.textColor = .red
                cell.textLabel?.text = lang("删除设备")
                cell.textLabel?.textAlignment = .center
            default:
                break
            }
        } else if ble!.state == .searching || ble!.state == .connecting {
            switch (indexPath.section, indexPath.row) {
            case (0, 0):
                cell.textLabel?.text = lang("硬件版本")
                cell.detailTextLabel?.text = "0.0.0"
                cell.detailTextLabel?.textColor = .lightGray
                cell.accessoryType = .none
            case (0, 1):
                if let _ = tipLabel.superview {
                    tipLabel.snp.removeConstraints()
                    tipLabel.removeFromSuperview()
                }
                cell.textLabel?.text = lang("固件版本")
                cell.detailTextLabel?.text = "0.0.0"
                cell.detailTextLabel?.textColor = .lightGray
                cell.accessoryType = .none
            case (0, 2):
                cell.textLabel?.text = lang("蓝牙地址")
                cell.accessoryType = .none
                cell.detailTextLabel?.text = "00.00.00.00.00.00"
                cell.detailTextLabel?.textColor = .lightGray
            default:
                break
            }
        } else  {
            switch (indexPath.section, indexPath.row) {
            case (0, 0):
                cell.textLabel?.text = lang("硬件版本")
                cell.detailTextLabel?.text = ble!.deviceInfo.hardware
                cell.detailTextLabel?.textColor = .lightGray
                cell.accessoryType = .none
            case (0, 1):
                cell.textLabel?.text = lang("固件版本")
                cell.detailTextLabel?.text = ble!.deviceInfo.firmware
                cell.detailTextLabel?.textColor = .lightGray
                cell.accessoryType = .none
                if let version = BLEManagerClass.shared.firmwareVersion, ble!.deviceInfo.firmware != "0.0.0"{
                    let serviceVerNum = Int(version.replacingOccurrences(of: ".", with: ""))
                    let currentVerNum = Int(ble!.deviceInfo.firmware.replacingOccurrences(of: ".", with: ""))
                    if let sVer = serviceVerNum,  let cVer = currentVerNum, cVer < sVer {
                        cell.accessoryType = .disclosureIndicator
                        if let _ = tipLabel.superview {
 
                        } else {
                            cell.contentView.addSubview(tipLabel)
                            tipLabel.snp.makeConstraints {
                                $0.centerY.equalToSuperview()
                                $0.right.equalTo(cell.detailTextLabel!.snp.left).offset(-8)
                                $0.width.equalTo(38)
                                $0.height.equalTo(22)
                            }
                        }
                    }
                }
            case (0, 2):
                cell.textLabel?.text = lang("蓝牙地址")
                cell.accessoryType = .none
                cell.detailTextLabel?.text = ble!.deviceInfo.mac
                cell.detailTextLabel?.textColor = .lightGray
            default:
                break
            }
        }
        
        if ble!.state.isConnected {
            switch (indexPath.section, indexPath.row) {
            case (1, 0):
                cell.textLabel?.textColor = mainColor
                cell.textLabel?.text = lang("查看已连接的设备")
            case (2, 0):
                cell.textLabel?.textColor = .red
                cell.textLabel?.text = lang("删除设备")
                cell.textLabel?.textAlignment = .center
            default:
                break
            }

        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            if indexPath.row == 1 {
                if let _ = tipLabel.superview {
                    let updateVC = FirmwareUpdateViewController(ble: ble)
                    self.navigationController?.pushViewController(updateVC, animated: true)
                }
            } else if indexPath.row == 0 {
                if tableView.cellForRow(at: indexPath)!.reuseIdentifier == "com.entertech.ble.disconnected.\(indexPath.row)" {
                    let tipVC = FindDeviceViewController()
                    self.navigationController?.pushViewController(tipVC, animated: true)
                }
            }
        } else if indexPath.section == 1 {
            if tableView.cellForRow(at: indexPath)!.reuseIdentifier == "com.entertech.ble.disconnected.\(indexPath.row)" {
                mac = nil
                ble?.disconnect()
            } else {
                //TODO:- Check device
                ble?.checkDevice()
            }
        } else if indexPath.section == 2 && indexPath.row == 0 {
            mac = nil
            ble?.disconnect()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0.1 : 32.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1 && ble!.state.isConnected {
            return lang("点击后已连接的设备指示灯将会闪烁 2 次。")
        }
        return ""
    }
    
    //MARK:- Method
    private func setNavigationItem() {
        let backItem = UIBarButtonItem(image: UIImage.loadImage(name: "icon_back", any: self.classForCoder), style: .plain, target: self, action: #selector(backAction))
        self.navigationItem.leftBarButtonItem = backItem
        self.navigationItem.title = lang("设备连接")
    }
    
    @objc private func backAction() {
        if BLEManagerClass.shared.bleList.count > 1 {
            self.navigationController?.popToRootViewController(animated: true)
        } else {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
        
        
    }
    
    @objc func stateNotification(_ notification: Notification) {
        if let data = notification.userInfo!["value"] as? Int {
            switch data {
            case 0://  disconnected
                DispatchQueue.main.async {
                    self.showReconnectView()
                    self.tableView?.reloadData()
                }

            case 1, 2://  searching
                DispatchQueue.main.async {
                    self.setConnectionAnimation()
                    self.tableView?.reloadData()
                }

            case 3://  connected
                //showBattery()
                break
            default:
                break
            }
            
        }
    }
    
    @objc func batteryNotification(_ notification: Notification) {
        if let data = notification.userInfo!["value"] as? Battery {
            print(data)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5, execute: {
                self.showBattery()
                self.tableView?.reloadData()
                self.mac = self.ble?.deviceInfo.mac
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name("BatteryNotify"), object: nil)
            })
            
            
        }
    }
    
    @objc func reconnectAction()  {
        self.connect()
    }


}
