//
//  AlarmTypeCell.swift
//  Nevo
//
//  Created by leiyuncun on 16/7/18.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class AlarmTypeCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            self.textLabel?.textColor = UIColor.white
            self.detailTextLabel?.textColor = UIColor.white
        }
    }
    
}
