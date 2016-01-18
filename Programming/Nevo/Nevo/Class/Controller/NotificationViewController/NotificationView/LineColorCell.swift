//
//  LineColorCell.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/1.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class LineColorCell: UITableViewCell {

    @IBOutlet weak var imageName: UIImageView!
    @IBOutlet weak var Notificationtitle: UILabel!
    @IBOutlet weak var NotificationImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
