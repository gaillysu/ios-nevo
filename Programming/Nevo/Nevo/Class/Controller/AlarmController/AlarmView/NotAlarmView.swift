//
//  NotAlarmView.swift
//  Nevo
//
//  Created by leiyuncun on 16/2/24.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class NotAlarmView: UIView {
    @IBOutlet weak var contentLabel: UILabel!

    class func getNotAlarmView()->UIView {
        let nibView:NSArray = NSBundle.mainBundle().loadNibNamed("NotAlarmView", owner: nil, options: nil)
        let view:UIView = nibView.objectAtIndex(0) as! UIView
        view.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
        (nibView.objectAtIndex(0) as! NotAlarmView).contentLabel.text = NSLocalizedString("no_alarm_content", comment: "")
        return nibView.objectAtIndex(0) as! UIView
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
