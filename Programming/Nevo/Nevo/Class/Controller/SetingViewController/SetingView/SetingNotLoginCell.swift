//
//  SetingNotLoginCell.swift
//  Nevo
//
//  Created by leiyuncun on 16/6/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class SetingNotLoginCell: UITableViewCell {

    @IBOutlet weak var notLoginlabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        notLoginlabel.viewDefaultColorful()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
