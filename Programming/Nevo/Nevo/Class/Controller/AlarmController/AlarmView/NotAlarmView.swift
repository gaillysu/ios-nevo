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
        let nibView:[Any] = Bundle.main.loadNibNamed("NotAlarmView", owner: nil, options: nil)!
        let view:UIView = nibView[0] as! UIView
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        (nibView[0] as! NotAlarmView).contentLabel.text = NSLocalizedString("no_alarm_content", comment: "")
        view.backgroundColor = UIColor.getBarColor()
        return nibView[0] as! UIView
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
