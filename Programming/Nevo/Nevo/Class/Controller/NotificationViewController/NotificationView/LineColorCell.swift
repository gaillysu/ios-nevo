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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textLabel?.backgroundColor = UIColor.clear
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            self.textLabel!.textColor = UIColor.white
            imageName.image = UIImage(named:"notifications_selected_background")
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
