//
//  UserProfileCell.swift
//  Nevo
//
//  Created by leiyuncun on 16/3/18.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import AutocompleteField

class UserProfileCell: UITableViewCell {
    @IBOutlet weak var labelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueTextField: AutocompleteField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func updateLabel(labelText: String){
        let contentDict:[String:AnyObject] = [NSFontAttributeName:titleLabel.font]
        titleLabel.text = labelText
        let statusLabelSize = labelText.sizeWithAttributes(contentDict)
        labelWidthConstraint.constant = statusLabelSize.width + 5
        layoutIfNeeded()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
