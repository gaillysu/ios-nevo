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
        
        self.layer.mask = shapelayer
    }
}


class DashBoardChargingView: UIView, DashBoardElementViewCornerable {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!

    class func factory() -> DashBoardChargingView {
        return Bundle.main.loadNibNamed("DashBoardElementView", owner: nil, options: nil)![0] as! DashBoardChargingView
    }
}

class DashBoardSunriseView: UIView, DashBoardElementViewCornerable {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    class func factory() -> DashBoardSunriseView {
        return Bundle.main.loadNibNamed("DashBoardElementView", owner: nil, options: nil)![1] as! DashBoardSunriseView
    }
}

class DashBoardHomeClockView: UIView, DashBoardElementViewCornerable {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    
    class func factory() -> DashBoardHomeClockView {
        return Bundle.main.loadNibNamed("DashBoardElementView", owner: nil, options: nil)![2] as! DashBoardHomeClockView
    }
    
}
