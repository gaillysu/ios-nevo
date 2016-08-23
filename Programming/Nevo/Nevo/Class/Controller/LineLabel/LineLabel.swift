//
//  LineLabel.swift
//  Nevo
//
//  Created by leiyuncun on 16/8/15.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class LineLabel: UILabel {

    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override init(frame: CGRect) {
        super.init(frame: frame)
        font = UIFont(name: "HelveticaNeue-Bold", size: 17)!
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        // Drawing code
        super.drawRect(rect)
        let ctx = UIGraphicsGetCurrentContext()
        CGContextMoveToPoint(ctx, 0, rect.size.height-2)
        CGContextAddLineToPoint(ctx, rect.size.width, rect.size.height - 2)
        CGContextSetStrokeColorWithColor(ctx, UIColor.lightGrayColor().CGColor)
        CGContextSetLineWidth(ctx, 2);  //线宽
        CGContextStrokePath(ctx)
    }

}
