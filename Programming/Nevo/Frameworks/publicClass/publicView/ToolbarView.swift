//
//  ToolbarView.swift
//  Nevo
//
//  Created by leiyuncun on 15/11/26.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit
import UIColor_Hex_Swift

protocol toolbarSegmentedDelegate:NSObjectProtocol {
    func didSelectedSegmentedControl(segment:UISegmentedControl)
}

class ToolbarView: UIView {

    var delegate:toolbarSegmentedDelegate?

    init(frame: CGRect,items:[String]) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()

        let segment:UISegmentedControl = UISegmentedControl(items: items)
        segment.frame = CGRectMake(0, 0, self.frame.size.width-30, 29)
        segment.selectedSegmentIndex = 0
        let infoDictionary:[String : AnyObject] = NSBundle.mainBundle().infoDictionary!
        
        let app_Name:String = infoDictionary["CFBundleName"] as! String
        if app_Name == "LunaR" {
            segment.tintColor = UIColor(rgba: "#7ED8D1")
        }else{
            segment.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        }
        segment.addTarget(self, action: #selector(ToolbarView.segmentAction(_:)), forControlEvents: UIControlEvents.ValueChanged)

        let itemSeg:UIBarButtonItem = UIBarButtonItem(customView: segment)
        itemSeg.style = UIBarButtonItemStyle.Done
        itemSeg.action = nil

        let flexible:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)

        let navToolbar:UIToolbar = UIToolbar(frame:  CGRectMake( 0, 0, self.frame.size.width, 35))
        navToolbar.shadowImageForToolbarPosition(UIBarPosition.Any)
        let imageView:UIImageView = UIImageView(frame: CGRectMake(0, -20, 420, 64))
        imageView.backgroundColor = AppTheme.NEVO_CUSTOM_COLOR(Red: 247.0, Green: 247.0, Blue: 247.0)
        navToolbar.addSubview(imageView)
        navToolbar.sendSubviewToBack(imageView)
        navToolbar.setItems([flexible,itemSeg,flexible], animated: true)
        self.addSubview(navToolbar)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func segmentAction(segment:UISegmentedControl){
        delegate?.didSelectedSegmentedControl(segment)
    }


    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        let bezierPath = UIBezierPath()
        //确定组成绘画的点
        let topLeft = CGPointMake(0,self.frame.size.height-0.3)
        let topRight = CGPointMake(self.frame.size.width,self.frame.size.height-0.3)

        //开始绘制
        bezierPath.moveToPoint(topLeft)
        bezierPath.addLineToPoint(topRight)

        //使路径闭合，结束绘制
        bezierPath.closePath()

        //设定颜色，并绘制它们
        UIColor.grayColor().setFill()
        UIColor.grayColor().setStroke()

        bezierPath.lineWidth = 0.3
        bezierPath.fill()
        bezierPath.stroke()
    }
}
