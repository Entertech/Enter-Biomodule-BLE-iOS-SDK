//
//  BatteryView.swift
//  Naptime
//
//  Created by HyanCat on 21/11/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import UIKit
import QuartzCore
import EnterBioModuleBLE

class BatteryView: UIView {

    private var _scaleLayer: CAShapeLayer = CAShapeLayer()
        
    
    private var _circleBackLayer: CAShapeLayer = CAShapeLayer()

    
    private var _circleForeLayer: CAShapeLayer = CAShapeLayer()

    var power: Battery? {
        didSet {
            if power == nil { return }
            DispatchQueue.main.async {
                self.updatePower(from: oldValue, to: self.power)
            }
        }
    }

    func setup() {
        _scaleLayer.lineWidth = 1
        _scaleLayer.strokeColor = UIColor(displayP3Red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5).cgColor
        _scaleLayer.fillColor = UIColor.clear.cgColor
        
        _circleBackLayer.lineWidth = 4
        _circleBackLayer.strokeColor = UIColor(displayP3Red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5).cgColor
        _circleBackLayer.fillColor = UIColor.clear.cgColor
        
        _circleForeLayer.lineWidth = 4
        _circleForeLayer.strokeColor = UIColor.white.cgColor
        _circleForeLayer.fillColor = UIColor.clear.cgColor
        _circleForeLayer.lineCap = convertToCAShapeLayerLineCap("round")
        
        _powerIcon.contentMode = .scaleAspectFit
        
        _powerLabel.textColor = UIColor.white
        _powerLabel.font = UIFont.systemFont(ofSize: 32, weight: .semibold)
        
        _continuousLabel.textColor = UIColor.white
        _continuousLabel.font = UIFont.systemFont(ofSize: 12)
        
        self.addSubview(_powerIcon)
        self.addSubview(_powerLabel)
        self.addSubview(_continuousLabel)

        self.layer.addSublayer(_scaleLayer)
        self.layer.addSublayer(_circleBackLayer)
        self.layer.addSublayer(_circleForeLayer)
    }

    func layout() {
        _powerIcon.snp.makeConstraints {
            $0.centerX.equalTo(self)
            $0.top.equalTo(self).offset(20)
            $0.width.equalTo(36)
            $0.height.equalTo(24)
        }
        _powerLabel.snp.makeConstraints {
            $0.center.equalTo(self)
        }
        _continuousLabel.snp.makeConstraints {
            $0.centerX.equalTo(self)
            $0.top.equalTo(_powerLabel.snp.bottom).offset(8)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let width = self.bounds.width

        let rect = CGRect(x: 6, y: 6, width: width-12, height: width-12)
        _scaleLayer.frame = rect
        _scaleLayer.path = makeScale(from: rect)
        _circleBackLayer.path = UIBezierPath(arcCenter: CGPoint(x: width/2, y: width/2),
                                             radius: width/2.0,
                                             startAngle: 0,
                                             endAngle: CGFloat.pi*2,
                                             clockwise: true).cgPath
        _circleForeLayer.path = UIBezierPath(arcCenter: CGPoint(x: width/2, y: width/2),
                                              radius: width/2.0,
                                              startAngle: -CGFloat.pi*0.5,
                                              endAngle: CGFloat.pi*1.5,
                                              clockwise: true).cgPath
    }

    private func updatePower(from: Battery?, to: Battery?) {
        if let to = to {
            _powerLabel.text = String(format: "%d%%", Int(to.percentage))
            _continuousLabel.text = String(format: "剩余 %d 小时电量", to.remain)
            _circleForeLayer.strokeEnd = CGFloat(to.percentage / 100)
        }

        let percent = to?.percentage ?? 0
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 1.0
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.fromValue = from?.percentage ?? 0
        animation.toValue = percent
        animation.isRemovedOnCompletion = true
        _circleForeLayer.add(animation, forKey: "strokeAnimation")

        _powerIcon.image = { () -> UIImage in
            switch percent {
            case 0..<0.1:
                return UIImage.loadImage(name: "icon_battery_10_white")!
            case 0.1..<0.4:
                return UIImage.loadImage(name: "icon_battery_40_white")!
            case 0.4..<0.6:
                return UIImage.loadImage(name: "icon_battery_60_white")!
            case 0.6..<0.8:
                return UIImage.loadImage(name: "icon_battery_80_white")!
            default:
                return UIImage.loadImage(name: "icon_battery_100_white")!
            }
        }()
    }

    private func makeScale(from rect: CGRect) -> CGPath {
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()!
        let alpha = CGFloat.pi * 6.0 / 180
        let ratio = rect.width/2.0
        (0..<60).forEach { _ in
            context.move(to: CGPoint(x: 0, y: ratio))
            context.addLine(to: CGPoint(x: 0, y: ratio-4))
            // print("\(alpha)-------\(radio)")
            context.rotate(by: alpha)
        }
        context.translateBy(x: -ratio, y: -ratio)
        UIGraphicsEndImageContext()
        return context.path!
    }

    private let _powerIcon: UIImageView = UIImageView(image: UIImage.loadImage(name: "icon_flowtime_disconnected_white"))
        
    
    private let _powerLabel: UILabel = UILabel()

    private let _continuousLabel: UILabel = UILabel()

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToCAShapeLayerLineCap(_ input: String) -> CAShapeLayerLineCap {
    return CAShapeLayerLineCap(rawValue: input)
}
