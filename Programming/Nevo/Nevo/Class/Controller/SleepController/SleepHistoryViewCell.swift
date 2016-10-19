//
//  SleepHistoryViewCell.swift
//  Nevo
//
//  Created by leiyuncun on 16/8/23.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class SleepHistoryViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var labelWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateTitleLabel(_ labelText: String){
        let contentDict:[String:AnyObject] = [NSFontAttributeName:titleLabel.font]
        titleLabel.text = labelText.capitalized(with: Locale.current)
        let statusLabelSize = labelText.size(attributes: contentDict)
        labelWidth.constant = 80
        layoutIfNeeded()
    }

}
