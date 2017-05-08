//
//  UserHeader.swift
//  Nevo
//
//  Created by leiyuncun on 16/7/19.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class UserHeader: UITableViewHeaderFooterView {
    @IBOutlet weak var avatarView: UIButton!
    
    public func changeAvatar(with image:UIImage) {
        self.avatarView.setImage(image, for: .normal)
        avatarView.layer.cornerRadius = avatarView.frame.height/2
        avatarView.layer.masksToBounds = true
        avatarView.layer.borderWidth = 1
        avatarView.layer.borderColor = UIColor.lightGray.cgColor
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}


