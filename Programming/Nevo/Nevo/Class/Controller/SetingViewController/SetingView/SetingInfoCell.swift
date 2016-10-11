//
//  SetingInfoCell.swift
//  Nevo
//
//  Created by leiyuncun on 16/6/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class SetingInfoCell: UITableViewCell {

    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var userName: UILabel!
    
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
            emailLabel.textColor = UIColor.white
            userName.textColor = UIColor.white
        }
    }
}


// MARK: - Style Evolve
extension SetingInfoCell {
    fileprivate func styleEvolve() {
        // if lunar
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            contentView.backgroundColor = UIColor.getGreyColor()
            emailLabel.textColor = UIColor.white
            userName.textColor = UIColor.white
        }
    }
}
