//
//  TableListCell.swift
//  Nevo
//
//  Created by leiyuncun on 15/3/3.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class TableListCell: UITableViewCell {
    @IBOutlet weak var statesSwitch: UISwitch!

    var mSwitchDelegate:SwitchActionDelegate?

    @IBAction func onTypeSwitchAction(sender: AnyObject) {
        let switchSender:UISwitch = sender as! UISwitch
        mSwitchDelegate?.onSwitch(switchSender.on, sender: switchSender)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
