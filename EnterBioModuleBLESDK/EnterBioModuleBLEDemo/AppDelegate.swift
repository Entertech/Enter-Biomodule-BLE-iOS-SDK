//
//  AppDelegate.swift
//  EnterBioModuleBLE
//
//  Created by NyanCat on 25/10/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import UIKit
import SVProgressHUD
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setMinimumDismissTimeInterval(1.0)
        SVProgressHUD.setMaximumDismissTimeInterval(2.0)
        SVProgressHUD.setDefaultMaskType(.none)

        do {
            try AVAudioSession.sharedInstance().setActive(true)
            if #available(iOS 10.0, *) {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
            } else {
                // TODO: early iOS 10 Fallback on earlier versions
            }
        } catch {
            SVProgressHUD.showError(withStatus: "开启后台播放失败")
        }

        return true
    }

}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
