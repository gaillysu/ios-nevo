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
    var actionCallBack:((_ sender:AnyObject) -> Void)?
    
    
    @IBAction func alarmTypeAction(_ sender: AnyObject) {
        actionCallBack?(sender)
    }
    
    override func awakeFromNib() {
        let dict:[String : AnyObject] = [NSForegroundColorAttributeName:UIColor.white]
        alarmType.setTitleTextAttributes(dict, for: UIControlState.selected)
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
