//
//  DashBoardElementView.swift
//  Nevo
//
//  Created by Quentin on 21/12/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import SnapKit

protocol DashBoardElementViewCornerable {
    func maskRoundCorner(positions: UIRectCorner, radius: CGFloat)
}

extension DashBoardElementViewCornerable where Self: UIView {
    func maskRoundCorner(positions: UIRectCorner, radius: CGFloat) {
        
        let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: positions, cornerRadii: CGSize(width: radius, height: radius))
        
        let shapelayer = CAShapeLayer()
        shapelayer.frame = bounds
        shapelayer.path = maskPath.cgPath
        
        layer.mask = shapelayer
    }
}


class DashBoardChargingView: UIView, DashBoardElementViewCornerable {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!

    @IBOutlet weak var imageViewTop: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottom: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.image = UIImage(named: "sun")
        titleLabel.text = NSLocalizedString("harvest_status", comment: "")
        contentLabel.text = NSLocalizedString("nosolar", comment: "")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let fontAttributes = [NSFontAttributeName: UIFont(name: "Raleway", size: 8)]
        if let titleLabelWidth = (titleLabel.text as NSString?)?.size(attributes: fontAttributes).width {
            if titleLabelWidth < titleLabel.bounds.width {
                titleLabel.snp.updateConstraints({ (v) in
                    v.height.equalTo(10)
                    layoutIfNeeded()
                })
            }
        }
        
        if !AppTheme.GET_IS_iPhone5S() {
            imageViewTop.constant = 10
            imageViewBottom.constant = 10
            layoutIfNeeded()
        }
    }
    
    class func factory() -> DashBoardChargingView {
        return Bundle.main.loadNibNamed("DashBoardElementView", owner: nil, options: nil)![0] as! DashBoardChargingView
    }
    
    func startRotateImageView() {
        contentLabel.text = NSLocalizedString("charging", comment: "")
        
        let circleByOneSecond:CGFloat = 2;
        
        let rotationAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.fromValue            = 0;
        rotationAnimation.toValue              = M_PI * 100000
        rotationAnimation.duration             = CFTimeInterval((1.0/circleByOneSecond)*100000);
        rotationAnimation.timingFunction       = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        imageView.layer.add(rotationAnimation, forKey: nil)
    }
    
    func stopRotateImageView() {
        contentLabel.text = NSLocalizedString("nosolar", comment: "")
        let pausedTime:CFTimeInterval = imageView.layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0;
        layer.timeOffset = pausedTime;
    }
    
    func resumeRotateImageView() {
        //let pausedTime:CFTimeInterval = imageView.layer.timeOffset;
        imageView.layer.speed = 1.0;
        imageView.layer.timeOffset = 0.0;
        imageView.layer.beginTime = 0.0;
        let timeSincePause:CFTimeInterval = imageView.layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.beginTime = timeSincePause;
    }

}

class DashBoardSunriseView: UIView, DashBoardElementViewCornerable {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.image = UIImage(named: "sunrise")
        cityLabel.text = "City Name"
        timeLabel.text = "06:00 AM"
        titleLabel.text = NSLocalizedString("sunrise", comment: "")
    }
    
    class func factory() -> DashBoardSunriseView {
        return Bundle.main.loadNibNamed("DashBoardElementView", owner: nil, options: nil)![1] as! DashBoardSunriseView
    }
}

class DashBoardHomeClockView: UIView, DashBoardElementViewCornerable {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.text = NSLocalizedString("hometime", comment: "")
        cityLabel.text = "City Name"
        countryLabel.text = "Country Name"
        timeLabel.text = Date().stringFromFormat("hh:mm a")

        timeLabel.sizeToFit()
        timeLabel.layer.backgroundColor = UIColor.getLightBaseColor().cgColor
        timeLabel.layer.cornerRadius = 3
        timeLabel.layer.masksToBounds = true
    }
    
    class func factory() -> DashBoardHomeClockView {
        return Bundle.main.loadNibNamed("DashBoardElementView", owner: nil, options: nil)![2] as! DashBoardHomeClockView
    }
}

class DashBoardCalorieView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    var progress: CGFloat = 0.75
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.text = NSLocalizedString("steps_taken", comment: "")
        valueLabel.text = "0"
        progressLabel.text = "0% " + NSLocalizedString("of_goal", comment: "")
    }
    
    class func factory() -> DashBoardCalorieView {
        return Bundle.main.loadNibNamed("DashBoardElementView", owner: nil, options: nil)![3] as! DashBoardCalorieView
    }
}
