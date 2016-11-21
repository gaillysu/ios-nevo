//
//  AnalysisValueCell.swift
//  Nevo
//
//  Created by leiyuncun on 16/8/25.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class AnalysisValueCell: UICollectionViewCell {
    
//    @IBOutlet weak var labelWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            titleLabel.textColor = UIColor.white
            valueLabel.textColor = UIColor.getBaseColor()
        }
    }

    func updateTitleLabel(_ labelText: String){
        let contentDict:[String:AnyObject] = [NSFontAttributeName:titleLabel.font]
        titleLabel.text = labelText
//        let statusLabelSize = labelText.size(attributes: contentDict)
//        if statusLabelSize.width>85 {
//            labelWidthConstraint.constant = statusLabelSize.width+5;
//        }else{
//            labelWidthConstraint.constant = 85
//        }
        
        layoutIfNeeded()
    }
    
    func updateLabel(_ labelText: String){
        valueLabel.text = labelText
    }
}
