//
//  SelectEEGViewController.swift
//  BLETool
//
//  Created by Anonymous on 2019/2/19.
//  Copyright © 2019 EnterTech. All rights reserved.
//

import UIKit
import SnapKit
import Then
import EnterBioModuleBLE
import RxBluetoothKit
import BlocksKit
import SVProgressHUD

class CommandModeViewController: UIViewController {

    var eegService: EEGService!
    var commandService: CommandService!
    var heartService: HeartService!
    var peripheral: Peripheral!

    private var type = CommandModeType.eeg
    private let eegButton = UIButton().then {
        $0.setTitle("EEG", for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        $0.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        $0.layer.cornerRadius = 10
        $0.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        $0.layer.borderWidth = 1
    }
    private let heartButton = UIButton().then {
        $0.setTitle("Heart", for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        $0.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        $0.layer.cornerRadius = 10
        $0.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        $0.layer.borderWidth = 1
    }
    private let mixButton = UIButton().then {
        $0.setTitle("EEG && Heart", for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        $0.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        $0.layer.cornerRadius = 10
        $0.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        $0.layer.borderWidth = 1
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.layout()
        self.addEvents()
    }

    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 16
        $0.alignment = .fill
        $0.distribution = .fillEqually
    }

    private func setupViews() {
        self.view.addSubview(stackView)
        self.stackView.addArrangedSubview(eegButton)
        self.stackView.addArrangedSubview(heartButton)
        self.stackView.addArrangedSubview(mixButton)
    }

    private func addEvents() {
        eegButton.bk_(whenTapped: {
            if self.eegService == nil || self.commandService == nil {
                SVProgressHUD.showError(withStatus: "sorry! the servic is no use")
                return
            }
            self.type = .eeg
            self.performSegue(withIdentifier: "toEEG", sender: self)
        })

        heartButton.bk_(whenTapped: {
            if self.heartService == nil || self.commandService == nil {
                SVProgressHUD.showError(withStatus: "sorry! the service is no use")
                return
            }
            self.type = .heart
            self.performSegue(withIdentifier: "toEEG", sender: self)
        })

        mixButton.bk_(whenTapped: {
            if self.eegService == nil || self.heartService == nil || self.commandService == nil {
                SVProgressHUD.showError(withStatus: "sorry! the service is no use")
                return
            }
            self.type = .mix
            self.performSegue(withIdentifier: "toEEG", sender: self)
        })
    }

    private func layout() {
        self.stackView.snp.makeConstraints {
            $0.left.equalTo(16)
            $0.right.equalTo(-16)
            if #available(iOS 11.0, *) {
                $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(16)
                $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            } else {
                $0.top.equalTo(64)
                $0.bottom.equalTo(-16)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? EEGViewController {
            destination.type = self.type
            destination.heartService = self.heartService
            destination.eegService = eegService
            destination.peripheral = peripheral
            destination.commandService = commandService
        }
    }
}

public enum CommandModeType: String {
    case eeg = "eeg"
    case heart = "heart"
    case mix = "mix"
}
