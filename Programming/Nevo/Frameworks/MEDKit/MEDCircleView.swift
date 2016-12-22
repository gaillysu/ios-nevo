//
//  MEDCircleView.swift
//  Nevo
//
//  Created by Quentin on 22/12/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

open class MEDCircleView: UIView {
    open var circleColor: UIColor = UIColor.white
    
    /// Must be >0, <1
    open var value: CGFloat = 0.5 {
        willSet {
            if newValue < 0 || newValue > 1 {
                fatalError("unexpected value!")
            }
        }
        
        didSet {
            setNeedsDisplay()
        }
    }
}

extension MEDCircleView {
    open override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        let circlePath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.bounds.width / 2 - 1)
        context?.addPath(circlePath.cgPath)
        circlePath.lineWidth = 1
        
        let startAngle = 0 - CGFloat.pi / 2
        let endAngle = value * CGFloat.pi * 2 - CGFloat.pi / 2
        
        let path = UIBezierPath(arcCenter: CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2), radius: self.bounds.width / 2 - 2, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        path.lineWidth = 3
        
        circleColor.set()
        circlePath.stroke()
        path.stroke()
    }
}
