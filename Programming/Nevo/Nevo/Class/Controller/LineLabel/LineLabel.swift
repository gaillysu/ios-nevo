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
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        super.draw(rect)
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.move(to: CGPoint(x: 0, y: rect.size.height-2))
        ctx?.addLine(to: CGPoint(x: rect.size.width, y: rect.size.height - 2))
        ctx?.setStrokeColor(UIColor.lightGray.cgColor)
        ctx?.setLineWidth(2);  //线宽
        ctx?.strokePath()
    }

}
