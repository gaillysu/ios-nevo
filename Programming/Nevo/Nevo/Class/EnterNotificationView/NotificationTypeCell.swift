//
//  NotificationTypeCell.swift
//  Nevo
//
//  Created by leiyuncun on 15/3/4.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

protocol SwitchActionDelegate {

    /**
    Switch event callback
    :param: results Switch state
    */
    func onSwitch(results:Bool ,sender:UISwitch)
    
}

class NotificationTypeCell: UITableViewCell {

    @IBOutlet weak var typeTitle: UILabel!
    var ActionDelegate:SwitchActionDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
