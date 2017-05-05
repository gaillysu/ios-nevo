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
    
    @IBOutlet weak var avatarImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        viewDefaultColorful()
        emailLabel.viewDefaultColorful()
        userName.viewDefaultColorful()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if MEDUserProfile.getAll().count > 0 {
            if let resultArray = AppTheme.LoadKeyedArchiverName(NevoAllKeys.MEDAvatarKeyAfterSave()) {
                avatarImageView.layer.cornerRadius = 0.5 * avatarImageView.layer.frame.width
                avatarImageView.layer.masksToBounds = true
            }
        }
    }
}
