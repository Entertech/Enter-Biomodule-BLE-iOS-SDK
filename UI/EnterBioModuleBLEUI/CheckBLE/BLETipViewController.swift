//
//  BLETipViewController.swift
//  EnterBioModuleBLEUI
//
//  Created by Enter on 2019/10/9.
//  Copyright © 2019 EnterTech. All rights reserved.
//

import UIKit
import SnapKit

class BLETipViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationItem()
        setUI()
    }
    
    private func setUI() {
        self.view.backgroundColor = UIColor.white
        let titleLabel = UILabel()
        titleLabel.text = "打开蓝牙以连接设备"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        titleLabel.textAlignment = .center
        self.view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints  {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(16)
        }
        
        
        let firstLabel = UILabel()
        firstLabel.text = "1.检查控制中心的蓝牙开关是否打开？"
        firstLabel.font = UIFont.systemFont(ofSize: 16)
        firstLabel.textAlignment = .left
        self.view.addSubview(firstLabel)
        firstLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(24)
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
        }
        
        
        let firstImgView = UIImageView()
        firstImgView.image = UIImage.loadImage(name: "img_control", any: self.classForCoder)
        self.view.addSubview(firstImgView)
        firstImgView.snp.makeConstraints {
            $0.top.equalTo(firstLabel.snp.bottom).offset(8)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
            $0.height.equalTo(firstImgView.snp.width).multipliedBy(207.0 / 327.0)
        }
        
        
        let secondLabel = UILabel()
        secondLabel.text = "2.检查设置应用中的蓝牙开关是否打开？"
        secondLabel.font = UIFont.systemFont(ofSize: 16)
        secondLabel.textAlignment = .left
        self.view.addSubview(secondLabel)
        secondLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(24)
            $0.top.equalTo(firstImgView.snp.bottom).offset(24)
        }
        
        
        let toSetting = UIButton()
        toSetting.setTitle("去设置", for: .normal)
        toSetting.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        toSetting.titleLabel?.textAlignment = .left
        toSetting.setTitleColor(.blue, for: .normal)
        toSetting.addTarget(self, action: #selector(toSettingPage), for: .touchUpInside)
        self.view.addSubview(toSetting)
        toSetting.snp.makeConstraints {
            $0.left.equalToSuperview().offset(24)
            $0.top.equalTo(secondLabel.snp.bottom).offset(8)
        }
        
        
        let secondImgView = UIImageView()
        secondImgView.image = UIImage.loadImage(name: "img_switch", any: classForCoder)
        self.view.addSubview(secondImgView)
        secondImgView.snp.makeConstraints {
            $0.top.equalTo(toSetting.snp.bottom).offset(8)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
            $0.height.equalTo(secondImgView.snp.width).multipliedBy(207.0 / 327.0)
        }
        
    }
    
    @objc
    private func toSettingPage() {
        let url = URL(string: UIApplication.openSettingsURLString)!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func setNavigationItem() {
        let backItem = UIBarButtonItem(image: UIImage.loadImage(name: "icon_back", any: classForCoder), style: .plain, target: self, action: #selector(backAction))
        self.navigationItem.leftBarButtonItem = backItem
        self.navigationItem.title = ""
    }
    
    @objc private func backAction() {
        self.navigationController?.dismiss(animated: true, completion: nil)
        
    }
}
