//
//  CurrentPaletteCell.swift
//  Nevo
//
//  Created by leiyuncun on 15/3/10.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class CurrentPaletteCell: UITableViewCell {

    @IBOutlet weak var currentLabel: UILabel!

    @IBOutlet weak var currentColorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
