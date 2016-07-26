//
//  OTALineView.swift
//  Nevo
//
//  Created by leiyuncun on 16/7/25.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class OTALineView: UIView {

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        // 绘制中划线
        let context = UIGraphicsGetCurrentContext()
        CGContextMoveToPoint(context, 0, 0)
        CGContextAddLineToPoint(context, rect.size.width, 0)
        CGContextSetLineWidth(context, 1);  //线宽
        CGContextSetAllowsAntialiasing(context, true);
        CGContextSetRGBStrokeColor(context, 255.0 / 255.0, 255.0 / 255.0, 255.0 / 255.0, 1.0);  //线的颜色
        CGContextStrokePath(context)
    }

}
