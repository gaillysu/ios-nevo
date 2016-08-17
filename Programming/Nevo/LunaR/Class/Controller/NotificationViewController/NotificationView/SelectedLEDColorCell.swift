//
//  SelectedLEDColorCell.swift
//  Nevo
//
//  Created by leiyuncun on 16/7/27.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class SelectedLEDColorCell: UITableViewCell {

    @IBOutlet weak var Color2Button: UIButton!
    @IBOutlet weak var Color4Button: UIButton!
    @IBOutlet weak var Color6Button: UIButton!
    @IBOutlet weak var Color8Button: UIButton!
    @IBOutlet weak var Color10Button: UIButton!
    @IBOutlet weak var Color12Button: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    @IBAction func SelectedColorAction(sender: AnyObject) {
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
