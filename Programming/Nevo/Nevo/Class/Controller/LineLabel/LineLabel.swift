//
//  LineLabel.swift
//  Nevo
//
//  Created by leiyuncun on 16/8/15.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

public enum LineLabelPosition {
    case top
    case bottom
}

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
        if rect.origin.y<0 {
            ctx?.move(to: CGPoint(x: 0, y: rect.size.height-(rect.size.height-60-rect.origin.y-2)))
            ctx?.addLine(to: CGPoint(x: rect.size.width, y: rect.size.height - (rect.size.height-60-rect.origin.y-2)))
        }else{
            ctx?.move(to: CGPoint(x: 0, y: rect.size.height-2))
            ctx?.addLine(to: CGPoint(x: rect.size.width, y: rect.size.height - 2))
        }
        
        ctx?.setStrokeColor(UIColor.lightGray.cgColor)
        ctx?.setLineWidth(0);  //线宽
        ctx?.strokePath()
    }
    
    func addLineView(position:LineLabelPosition) {
        let lineView = UIView(frame: frame)
        addSubview(lineView)
        lineView.backgroundColor = UIColor.lightGray
        lineView.frame.size.height = 0.3
        
        if position == .top {
            lineView.frame.origin.y = -0.3
        } else if position == .bottom {
            lineView.frame.origin.y = frame.height
        }
    }
}
