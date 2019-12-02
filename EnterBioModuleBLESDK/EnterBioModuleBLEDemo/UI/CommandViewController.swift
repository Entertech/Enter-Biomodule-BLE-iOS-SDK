//
//  CommandViewController.swift
//  EnterBioModuleBLE
//
//  Created by NyanCat on 27/10/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import UIKit
import CoreBluetooth
import RxBluetoothKit
import RxSwift
import SVProgressHUD
import EnterBioModuleBLE

class CommandViewController: UIViewController {

    let disposeBag = DisposeBag()

    var service: CommandService!

    @IBOutlet weak var textView: UITextView!

    var isNotifing: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
        }

        textView.text.append("\n")

        notifyIfNeeded()
    }

    @IBAction func commandAButtonTouched(_ sender: UIBarButtonItem) {
        send(data: Data([0x0A]))
    }

    @IBAction func commandBButtonTouched(_ sender: UIBarButtonItem) {
        send(data: Data([0x0B]))
    }

    @IBAction func commandRandomButtonTouched(_ sender: UIBarButtonItem) {
        let v = UInt8(arc4random() % 256)
        send(data: Data([v]))
    }

    private func notifyIfNeeded() {
        if isNotifing { return }

        self.service.notify(characteristic: .receive).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            let data = Data($0)
            self.received(data: data)
        }).disposed(by: disposeBag)
        isNotifing = true
    }

    private func send(data: Data) {
        self.service.write(data: data, to: .send).catch { _ in 
            SVProgressHUD.showError(withStatus: "Failed to send command!")
        }
    }

    private func received(data: Data) {
        dispatch_to_main {
            self.textView.text.append(data.hexString)
            self.textView.scrollRangeToVisible(NSMakeRange(self.textView.text.count-1, 1))
        }
    }

}
