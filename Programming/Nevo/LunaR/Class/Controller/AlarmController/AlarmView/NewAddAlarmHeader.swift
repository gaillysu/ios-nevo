//
//  NewAddAlarmHeader.swift
//  Nevo
//
//  Created by leiyuncun on 16/7/18.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class NewAddAlarmHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var alarmType: UISegmentedControl!
    var actionCallBack:((sender:AnyObject) -> Void)?
    
    
    @IBAction func alarmTypeAction(sender: AnyObject) {
        actionCallBack?(sender: sender)
    }
    
    override func awakeFromNib() {
        let dict:[String : AnyObject] = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        alarmType.setTitleTextAttributes(dict, forState: UIControlState.Selected)
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
