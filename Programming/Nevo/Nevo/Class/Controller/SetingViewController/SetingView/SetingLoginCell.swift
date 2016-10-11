//
//  SetingLoginCell.swift
//  Nevo
//
//  Created by leiyuncun on 16/6/15.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class SetingLoginCell: UITableViewCell {

    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
}

// MARK: - Style Evolve
extension SetingLoginCell {
    fileprivate func styleEvolve() {
        // if lunar
        
        // this class was never used...
        if !AppTheme.isTargetLunaR_OR_Nevo() {
        }
    }
}
