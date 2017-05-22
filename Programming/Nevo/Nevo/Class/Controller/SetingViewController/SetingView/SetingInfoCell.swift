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
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height/2
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.borderWidth = 1
        avatarImageView.layer.borderColor = UIColor.lightGray.cgColor
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if MEDUserProfile.getAll().count > 0 {
            if let _ = Tools.LoadKeyedArchiverName(NevoAllKeys.MEDAvatarKeyAfterSave()) {
                avatarImageView.layer.cornerRadius = 0.5 * avatarImageView.layer.frame.width
                avatarImageView.layer.masksToBounds = true
            }
        }
    }
}
