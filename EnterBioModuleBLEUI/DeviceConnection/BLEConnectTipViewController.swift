//
//  BLEConnectTipViewController.swift
//  EnterBioModuleBLEUI
//
//  Created by Enter on 2019/10/22.
//  Copyright © 2019 EnterTech. All rights reserved.
//

import UIKit

class BLEConnectTipViewController: UIViewController {
    
    private var isFirstTime = true
    //MARK:- Public
    public var cornerRadius: CGFloat = 8 {
        didSet {
            nextBtn?.layer.cornerRadius = self.cornerRadius
            nextBtn?.layer.masksToBounds = true
            imageBackground?.layer.cornerRadius = self.cornerRadius
            imageBackground?.layer.masksToBounds = true
        }
    }
    
    public var mainColor: UIColor = UIColor.colorFromInt(r: 0, g: 100, b: 255, alpha: 1) {
        didSet {
            nextBtn?.backgroundColor = self.mainColor
        }
    }
    
    //MARK:- Private UI
    private var imageBackground: UIView?
    private var imageView: UIImageView?
    private var textLabel: UILabel?
    private var nextBtn: UIButton?
    private var deviceIndex: Int = 0
    
    //MARK:- Method
    init(index: Int) {
        super.init(nibName: nil, bundle: nil)
        deviceIndex = index
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Method
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isFirstTime {
            if BLEManagerClass.shared.bleList.count == 1 {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
            
        } else {
            isFirstTime = false
        }
    }
    
    
    func setUI() {
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = .systemBackground
        } else {
            self.view.backgroundColor = .white
        }
        imageBackground = UIView()
        imageBackground?.layer.cornerRadius = self.cornerRadius
        imageBackground?.layer.masksToBounds = true
        imageBackground?.backgroundColor = UIColor.colorFromInt(r: 55, g: 58, b: 91, alpha: 1)
        self.view.addSubview(imageBackground!)
        imageBackground?.snp.makeConstraints {
            $0.left.equalToSuperview().offset(8)
            $0.right.equalToSuperview().offset(-8)
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(16)
            $0.height.equalTo(self.imageBackground!.snp.width).multipliedBy(0.5)
        }
        
        imageView = UIImageView()
        imageView?.image = UIImage.loadImage(name: "icon_chatu")
        self.view.addSubview(imageView!)
        imageView?.snp.makeConstraints {
            $0.center.equalTo(self.imageBackground!.snp.center)
            $0.width.equalTo(253)
            $0.height.equalTo(147)
        }
        
        textLabel = UILabel()
        let attributedText = NSMutableAttributedString(string:"长按设备按键直至灯亮。如果设备指示灯没有亮，先给设备充电，10 分钟之后再尝试。")
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        style.lineSpacing = 5
        attributedText.addAttribute(
            kCTParagraphStyleAttributeName as NSAttributedString.Key,
            value: style,
            range: NSMakeRange(0, attributedText.length))
        textLabel?.textAlignment = .left
        textLabel?.lineBreakMode = .byWordWrapping
        textLabel?.numberOfLines  = 0
        textLabel?.font = UIFont.systemFont(ofSize: 16)
        textLabel?.attributedText = attributedText
        self.view.addSubview(textLabel!)
        textLabel?.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.top.equalTo(self.imageBackground!.snp.bottom).offset(16)
            $0.height.equalTo(50)
        }
        
        nextBtn = UIButton()
        nextBtn?.layer.cornerRadius = self.cornerRadius
        nextBtn?.layer.masksToBounds = true
        nextBtn?.setTitle("下一步", for: .normal)
        nextBtn?.setTitleColor(.white, for: .normal)
        nextBtn?.backgroundColor = mainColor
        self.view.addSubview(nextBtn!)
        nextBtn?.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        nextBtn?.snp.makeConstraints {
            $0.centerY.equalToSuperview().multipliedBy(1.1)
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.height.equalTo(45)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    private func setNavigationItem() {
        let backItem = UIBarButtonItem(image: UIImage.loadImage(name: "icon_back"), style: .plain, target: self, action: #selector(backAction))
        self.navigationItem.leftBarButtonItem = backItem
        self.navigationItem.title = "设备连接"
    }
    
    @objc private func backAction() {
        if BLEManagerClass.shared.bleList.count == 1 {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func nextAction() {
        let stateVC = BLEStateViewController(index: deviceIndex, cornerRadius, mainColor)
        self.navigationController?.pushViewController(stateVC, animated: true)
    }


}
