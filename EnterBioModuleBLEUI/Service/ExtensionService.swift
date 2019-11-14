//
//  ExtensionService.swift
//  EnterBioModuleBLEUI
//
//  Created by Enter on 2019/10/23.
//  Copyright © 2019 EnterTech. All rights reserved.
//

import UIKit

/// 所有的 Error
public enum EnterError: Error {
    case timeout
    case invalid(message: String)
    case busy
}


class ExtensionService: NSObject {
    
    static let bleStateChanged = NSNotification.Name(rawValue: "dfuStateChanged")

}

extension UIColor {
    static func colorFromInt(r:Int, g:Int, b:Int, alpha:CGFloat) -> UIColor {
        return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: alpha)
    }
}

extension UIImage {
    static func loadImage(name: String) -> UIImage? {
        //return UIImage(named: name, in: Bundle(identifier: "cn.entertech.EnterBioModuleBLEUI"), compatibleWith: nil)
        return UIImage(named: name, in: Bundle(identifier: "org.cocoapods.EnterBioModuleBLEUI"), compatibleWith: nil)
    }
}

extension UIImage {
    /// GIF
    class func resolveGifImage(gif: String) -> [UIImage]{
        var images:[UIImage] = []
        //let gifPath = Bundle.init(identifier: "cn.entertech.EnterBioModuleBLEUI")?.path(forResource: gif, ofType: "gif")
        let gifPath = Bundle.init(identifier: "org.cocoapods.EnterBioModuleBLEUI")?.path(forResource: gif, ofType: "gif")
        if gifPath != nil{
            if let gifData = try? Data(contentsOf: URL.init(fileURLWithPath: gifPath!)){
                let gifDataSource = CGImageSourceCreateWithData(gifData as CFData, nil)
                let gifcount = CGImageSourceGetCount(gifDataSource!)
                for i in 0...gifcount - 1{
                    let imageRef = CGImageSourceCreateImageAtIndex(gifDataSource!, i, nil)
                    let image = UIImage(cgImage: imageRef!)
                    images.append(image)
                }
            }
        }
        return images
    }
}
