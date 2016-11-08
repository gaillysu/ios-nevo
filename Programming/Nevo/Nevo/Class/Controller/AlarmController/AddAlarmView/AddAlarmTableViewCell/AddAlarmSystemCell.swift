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
        // Initialization code
        
        // MARK: - APPTHEME ADJUST
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            backgroundColor = UIColor.getGreyColor()
            contentView.backgroundColor = UIColor.getGreyColor()
            textLabel?.textColor = UIColor.white
            detailTextLabel?.textColor = UIColor.white
            systemTitle.textColor = UIColor.white
            repeatSwicth.tintColor = UIColor.getBaseColor()
            repeatSwicth.onTintColor = UIColor.getBaseColor()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
