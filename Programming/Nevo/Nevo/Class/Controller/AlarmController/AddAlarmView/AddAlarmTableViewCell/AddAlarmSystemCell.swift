//
//  AddAlarmSystemCell.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/11.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class AddAlarmSystemCell: UITableViewCell {

    @IBOutlet weak var systemTitle: UILabel!
    @IBOutlet weak var repeatSwicth: UISwitch!
    var mDelegate:ButtonManagerCallBack?

    @IBAction func buttonManager(_ sender: AnyObject) {
        mDelegate?.controllManager(sender)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewDefaultColorful()
        systemTitle.viewDefaultColorful()
        repeatSwicth.viewDefaultColorful()
    }
}
