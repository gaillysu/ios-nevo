//
//  PresetTableViewCell.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/3.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit
import RealmSwift

class GoalTableViewCell: UITableViewCell,ButtonManagerCallBack {

    @IBOutlet weak var presetSteps: UILabel!
    @IBOutlet weak var presetName: UILabel!
    @IBOutlet weak var presetStates: UISwitch!
    @IBOutlet weak var separatorLineLabel: UILabel!
    
    var presetModel:MEDUserGoal? {
        didSet{
            if let model = presetModel {
                presetSteps.text = "\(model.stepsGoal)"
                presetName.text = NSLocalizedString("\(model.label)", comment: "")
                presetStates.isOn = model.status
                if(!model.status){
                    backgroundColor = UIColor.clear
                }
            }
        }
    }


    @IBAction func controllManager(_ sender: AnyObject) {
        /// When switch is turned off, cell's color should be clear.
        if(presetStates.isOn){
            viewDefaultColorful()
        }else{
            backgroundColor = UIColor.clear
            contentView.backgroundColor = UIColor.clear
        }
        separatorInset = .zero

        if let model = presetModel {
            let realm = try! Realm()
            try! realm.write {
                model.status = presetStates.isOn
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        /// Theme adjust
        presetSteps.viewDefaultColorful()
        presetName.viewDefaultColorful()
        presetStates.viewDefaultColorful()
    }
}
