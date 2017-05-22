//
//  NewAddAlarmHeader.swift
//  Nevo
//
//  Created by leiyuncun on 16/7/18.
//  Copyright © 2016年 Nevo. All rights reserved.
//
 
import UIKit
import SnapKit

class NewAddAlarmHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var alarmType: UISegmentedControl!
    
    var actionCallBack: ((_ sender:AnyObject) -> Void)?
    
    @IBAction func alarmTypeAction(_ sender: AnyObject) {
        actionCallBack?(sender)
    }
    
    override func awakeFromNib() {
        
        let dict: [String: AnyObject] = [NSForegroundColorAttributeName: UIColor.white]
        alarmType.setTitleTextAttributes(dict, for: UIControlState.selected)
        
        let bottomLineView = UIView()
        addSubview(bottomLineView)
        
        bottomLineView.snp.makeConstraints { (v) in
            v.left.equalToSuperview()
            v.right.equalToSuperview()
            v.bottom.equalToSuperview()
            v.height.equalTo(0.3)
        }
        
        alarmType.viewDefaultColorful()
        
        backgroundColor = UIColor.getNevoTabBarColor()
        contentView.backgroundColor = UIColor.getNevoTabBarColor()
        alarmType.backgroundColor = UIColor.getNevoTabBarColor()
        
        bottomLineView.backgroundColor = UIColor.baseColor
    }
}
