//
//  DashBoardElementView.swift
//  Nevo
//
//  Created by Quentin on 21/12/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

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

    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.image = UIImage(named: "sun")
        titleLabel.text = "HARVEST STATUS"
        contentLabel.text = "Charging"
    }
    
    class func factory() -> DashBoardChargingView {
        return Bundle.main.loadNibNamed("DashBoardElementView", owner: nil, options: nil)![0] as! DashBoardChargingView
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
        cityLabel.text = "Shenzhen"
        timeLabel.text = "06:00 AM"
        titleLabel.text = "Sunrise"
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
        
        titleLabel.text = "HOME TIME"
        cityLabel.text = "Shenzhen"
        countryLabel.text = "China"
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
        
        titleLabel.text = "CALORIES BURNED"
        valueLabel.text = "366"
        progressLabel.text = "75% OF GOAL"
        
        let progressCircle = NevoCircleProgressView()
        layer.addSublayer(progressCircle)
        progressCircle.setProgressColor(UIColor.white)
        progressCircle.setProgress(progress)
    }
    
    class func factory() -> DashBoardCalorieView {
        return Bundle.main.loadNibNamed("DashBoardElementView", owner: nil, options: nil)![3] as! DashBoardCalorieView
    }
}
