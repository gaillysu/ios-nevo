//
//  PresetTableViewCell.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/3.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class PresetTableViewCell: UITableViewCell,ButtonManagerCallBack {

    @IBOutlet weak var presetSteps: UILabel!
    @IBOutlet weak var presetName: UILabel!
    @IBOutlet weak var presetStates: UISwitch!
    
    @IBOutlet weak var separatorLineLabel: UILabel!
    
    var delegate:ButtonManagerCallBack?


    @IBAction func controllManager(_ sender: AnyObject) {
       delegate?.controllManager(sender)
        
        /// When switch is turned off, cell's color should be clear.
        if(presetStates.isOn){
            viewDefaultColorful()
        }else{
            backgroundColor = UIColor.clear
            contentView.backgroundColor = UIColor.clear
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        /// Theme adjust
        presetSteps.viewDefaultColorful()
        presetName.viewDefaultColorful()
        presetStates.viewDefaultColorful()
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            separatorLineLabel.backgroundColor = UIColor.getLightBaseColor()
        }
    }
}
