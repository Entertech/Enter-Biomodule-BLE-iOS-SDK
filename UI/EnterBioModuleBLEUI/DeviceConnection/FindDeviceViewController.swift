//
//  FindDeviceViewController.swift
//  EnterBioModuleBLEUI
//
//  Created by Enter on 2019/10/31.
//  Copyright © 2019 EnterTech. All rights reserved.
//

import UIKit
import RxSwift

class FindDeviceViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }
    
    func setUI() {
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = .systemBackground
        } else {
            self.view.backgroundColor = .white
        }
         
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.text = "未找到设备"
        titleLabel.textAlignment = .center
        
        let contentLabel = UILabel()
        contentLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        contentLabel.textAlignment = .left
        contentLabel.lineBreakMode = .byWordWrapping
        contentLabel.numberOfLines = 0
        let attributedText = NSMutableAttributedString(string:"1. 若长按按键时间大于 2 秒钟仍旧没有灯亮，请先给设备充电。充电 10 分钟后再尝试。\n\n2. 确保设备在手机附近。如果周围还有其他蓝牙设备，请把他们拿开。\n\n3. 查看系统设置中的蓝牙状态，确保蓝牙是打开的。\n\n4. 如果蓝牙已经打开，请关闭后再打开。\n\n5. 如果依旧无法连接，请重启手机后尝试。")
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        style.lineSpacing = 5
        attributedText.addAttribute(
            kCTParagraphStyleAttributeName as NSAttributedString.Key,
            value: style,
            range: NSMakeRange(0, attributedText.length))
        contentLabel.attributedText = attributedText
        
        self.view.addSubview(titleLabel)
        self.view.addSubview(contentLabel)
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(24)
        }
        
        contentLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
        }
    }


}
