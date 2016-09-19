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
    func didSelectedSegmentedControl(_ segment:UISegmentedControl)
}

class ToolbarView: UIView {

    var delegate:toolbarSegmentedDelegate?

    init(frame: CGRect,items:[String]) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear

        let segment:UISegmentedControl = UISegmentedControl(items: items)
        segment.frame = CGRect(x: 0, y: 0, width: self.frame.size.width-30, height: 29)
        segment.selectedSegmentIndex = 0
        let infoDictionary:[String : AnyObject] = Bundle.main.infoDictionary! as [String : AnyObject]
        
        let app_Name:String = infoDictionary["CFBundleName"] as! String
        if app_Name == "LunaR" {
            segment.tintColor = UIColor(rgba: "#7ED8D1")
        }else{
            segment.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        }
        segment.addTarget(self, action: #selector(ToolbarView.segmentAction(_:)), for: UIControlEvents.valueChanged)

        let itemSeg:UIBarButtonItem = UIBarButtonItem(customView: segment)
        itemSeg.style = UIBarButtonItemStyle.done
        itemSeg.action = nil

        let flexible:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)

        let navToolbar:UIToolbar = UIToolbar(frame:  CGRect( x: 0, y: 0, width: self.frame.size.width, height: 35))
        navToolbar.shadowImage(forToolbarPosition: UIBarPosition.any)
        let imageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: -20, width: 420, height: 64))
        imageView.backgroundColor = AppTheme.NEVO_CUSTOM_COLOR(Red: 247.0, Green: 247.0, Blue: 247.0)
        navToolbar.addSubview(imageView)
        navToolbar.sendSubview(toBack: imageView)
        navToolbar.setItems([flexible,itemSeg,flexible], animated: true)
        self.addSubview(navToolbar)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func segmentAction(_ segment:UISegmentedControl){
        delegate?.didSelectedSegmentedControl(segment)
    }


    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        let bezierPath = UIBezierPath()
        //确定组成绘画的点
        let topLeft = CGPoint(x: 0,y: self.frame.size.height-0.3)
        let topRight = CGPoint(x: self.frame.size.width,y: self.frame.size.height-0.3)

        //开始绘制
        bezierPath.move(to: topLeft)
        bezierPath.addLine(to: topRight)

        //使路径闭合，结束绘制
        bezierPath.close()

        //设定颜色，并绘制它们
        UIColor.gray.setFill()
        UIColor.gray.setStroke()

        bezierPath.lineWidth = 0.3
        bezierPath.fill()
        bezierPath.stroke()
    }
}
