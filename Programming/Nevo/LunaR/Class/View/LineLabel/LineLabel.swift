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
    override func drawRect(rect: CGRect) {
        // Drawing code
        super.drawRect(rect)
        let ctx = UIGraphicsGetCurrentContext()
        CGContextMoveToPoint(ctx, 0, rect.size.height-2)
        CGContextAddLineToPoint(ctx, rect.size.width, rect.size.height - 2)
        CGContextSetStrokeColorWithColor(ctx, UIColor.grayColor().CGColor)
        CGContextStrokePath(ctx)
    }

}
