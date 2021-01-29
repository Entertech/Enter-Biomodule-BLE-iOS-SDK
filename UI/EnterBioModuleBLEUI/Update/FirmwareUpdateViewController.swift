//
//  FirmwareUpdateViewController.swift
//  Flowtime
//
//  Created by Enter on 2019/9/6.
//  Copyright © 2019 Enter. All rights reserved.
//

import UIKit
import EnterBioModuleBLE

class FirmwareUpdateViewController: UIViewController {
    
    enum UpdateState: Int {
        case show = 1
        case faild = 2
        case updating = 3
        case completed = 4
    }
    
    private var ble: BLEManager?
    
    private var currentState: UpdateState?
    private var titleLabel: UILabel = UILabel()
    private var titleImageView: UIImageView = UIImageView()
    private var updateNotesLabel: UILabel = UILabel()
    private var updateBtn: UIButton = UIButton()
    private let progressView = UIImageView()
    
    init(ble: BLEManager?) {
        super.init(nibName: nil, bundle: nil)
        self.ble = ble
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = BLEManagerClass.shared.mainColor
        setLayout()
        updateBtn.backgroundColor = .white
        setNavigationItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(didFirmwareUpdateStateChanged(_:)), name: NSNotification.Name(rawValue: "dfuStateChanged"), object: nil)
        let target  = self.navigationController?.interactivePopGestureRecognizer?.delegate
        let pan = UIPanGestureRecognizer(target: target, action:  nil)
        self.view.addGestureRecognizer(pan)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setLayout() {
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        
        updateNotesLabel.textColor  = .white
        updateNotesLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        if let color = BLEManagerClass.shared.mainColor {
            updateBtn.setTitleColor(color, for: UIControl.State.normal)
        }
        updateBtn.addTarget(self, action: #selector(updateBtnTouched(_:)), for: .touchUpInside)
        
        self.view.addSubview(titleImageView)
        self.view.addSubview(titleLabel)
        self.view.addSubview(updateNotesLabel)
        self.view.addSubview(updateBtn)
        titleImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().multipliedBy(0.5)
            $0.width.height.equalTo(64)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleImageView.snp.bottom).offset(16)
        }
        
        updateNotesLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(280)
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
        }
        
        updateBtn.snp.makeConstraints {
            $0.height.equalTo(45)
            $0.centerY.equalToSuperview().multipliedBy(1.4)
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
        }
        if let r = BLEManagerClass.shared.cornerRadius {
            updateBtn.layer.cornerRadius = r
        }
        
        
        self.view.addSubview(progressView)
        self.view.bringSubviewToFront(progressView)
        progressView.snp.makeConstraints {
            $0.left.equalTo(titleImageView.snp_leftMargin)
            $0.right.equalTo(titleImageView.snp_rightMargin)
            $0.top.equalTo(titleImageView.snp_topMargin)
            $0.bottom.equalTo(titleImageView.snp_bottomMargin)
        }
        
        progressView.animationImages = UIImage.resolveGifImage(gif: "loading", any: self.classForCoder)
        progressView.animationDuration = 2
        progressView.animationRepeatCount = Int.max
        
        setUpdateViewState(state: 1)
    }
    
    public func setNotes(note: String) {
        let attributedText = NSMutableAttributedString(string: note)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        attributedText.addAttribute(kCTParagraphStyleAttributeName as NSAttributedString.Key, value: style, range: NSMakeRange(0, attributedText.length))
        updateNotesLabel.lineBreakMode = .byWordWrapping
        updateNotesLabel.numberOfLines = 0
        updateNotesLabel.attributedText = attributedText
    }
    
    @objc private  func updateBtnTouched(_ sender: Any) {
        switch currentState! {
        
        case .show:
            if let url = BLEManagerClass.shared.firmwareURL {
                firmwareUpdate(url: url)
                setUpdateViewState(state: 3)
            }
            
            break
        case .faild:
            break
        case .updating:
            break
        case .completed:
            break
        }
    }
    
    /// 设置升级状态
    ///
    /// - Parameter state: 按照枚举UpdateState对应的数字
    public func setUpdateViewState(state: Int) {
        self.navigationItem.leftBarButtonItem?.isEnabled = true
        updateBtn.isHidden = true
        progressView.isHidden = true
        if progressView.isAnimating {
            progressView.stopAnimating()
        }
        titleLabel.textAlignment = .center
        titleImageView.isHidden = false
        currentState = UpdateState(rawValue: state)
        switch state {
            
        case UpdateState.show.rawValue:
            titleImageView.image = UIImage.loadImage(name: "img_firmware", any: self.classForCoder)
            titleLabel.text = lang("固件升级")
            updateNotesLabel.textAlignment = .center
            setNotes(note: BLEManagerClass.shared.firmwareUpdateLog)
            updateBtn.setTitle(lang("开始升级"), for: .normal)
            updateBtn.isHidden = false
            
        case UpdateState.faild.rawValue:
            titleImageView.image = UIImage.loadImage(name: "img_fail", any: self.classForCoder)
            titleLabel.text = lang("升级失败")
            setNotes(note: lang("请返回重新连接设备后再次尝试"))
            updateNotesLabel.textAlignment = .center
            
        case UpdateState.updating.rawValue:
            setNotes(note: lang("固件升级需要一些时间，请保持设备在手机附近。"))
            titleLabel.text = lang("升级中...")
            titleImageView.isHidden = true
            progressView.isHidden = false
            progressView.startAnimating()
            updateNotesLabel.textAlignment = .center

            self.navigationItem.leftBarButtonItem?.isEnabled = false
            
        case UpdateState.completed.rawValue:
            setNotes(note: lang("返回上层页面重新连接"))
            titleLabel.text = lang("升级成功")
            titleImageView.image = UIImage.loadImage(name: "img_success", any: self.classForCoder)
            updateNotesLabel.textAlignment = .center
            ble?.disconnect()
            
            
        default:
            break
        }
    }
    
    
    private func firmwareUpdate(url: URL) {
        do {
            try ble?.dfu(fileURL: url) //dfu(fileURL: url)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func setNavigationItem() {
        let backItem = UIBarButtonItem(image: UIImage.loadImage(name: "icon_back_white", any: classForCoder), style: .plain, target: self, action: #selector(backAction))
        self.navigationItem.leftBarButtonItem = backItem
        let naviLabel = UILabel()
        naviLabel.text = lang("固件升级")
        naviLabel.textAlignment = .center
        naviLabel.textColor = .white
        naviLabel.font = UIFont.systemFont(ofSize: 17)
        self.navigationItem.titleView = naviLabel
    }
    
    @objc private func backAction() {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    //MARK - STATE NOTIFICATION
    @objc private func didFirmwareUpdateStateChanged(_ notification: Notification) {
        if let info = notification.userInfo,
            let state = info["dfuStateKey"] as? DFUState {
            let msg = info["msg"] as? String
            switch state {

            case .none:
                break
            case .upgrading(let progress):
                print("DFU upgrading: \(progress)")
            case .succeeded:
                setUpdateViewState(state: 4)
            case .failed:
                print("DFU error: \(msg)")
                setUpdateViewState(state: 2)

            case .connecting:
                break
            case .starting:
                break
            case .enablingDfuMode:
                break
            case .validating:
                break
            case .uploading:
                break
            }
        }

    }
    

    
}
