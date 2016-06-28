//
//  UserHeader.swift
//  Nevo
//
//  Created by leiyuncun on 16/3/21.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class UserHeader: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initValue() {
        let headerButton:UIButton = UIButton(type: UIButtonType.Custom)
        headerButton.frame = CGRectMake(0, 0, 60, 60)
        headerButton.addTarget(self, action: Selector("HeaderAction:"), forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(headerButton)

        let name:UILabel = UILabel(frame: CGRectMake(0,0,60,60))
    }

    func HeaderAction(sender:UIButton) {

    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
