//
//  PresetView.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/3.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class PresetView: UITableView {

    var mDelegate:ButtonManagerCallBack?
    var leftButton:UIBarButtonItem?

    func bulidPresetView(_ navigation:UINavigationItem,delegateB:ButtonManagerCallBack){
        mDelegate = delegateB
        navigation.title = NSLocalizedString("title_goal", comment: "")
        leftButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(PresetView.controllManager(_:)))
        navigation.rightBarButtonItem = leftButton
    }

    func getPresetTableViewCell(_ indexPath:IndexPath,tableView:UITableView,presetArray:[Presets],delegate:ButtonManagerCallBack)->UITableViewCell{
        let endCellID:String = "PresetTableViewCell"
        var endCell = tableView.dequeueReusableCell(withIdentifier: endCellID)
        if (endCell == nil) {
            let nibs:[Any] = Bundle.main.loadNibNamed("PresetTableViewCell", owner: self, options: nil)!
            endCell = nibs[0] as? PresetTableViewCell;

        }
        (endCell as! PresetTableViewCell).delegate = delegate
        (endCell as! PresetTableViewCell).presetStates.tag = (indexPath as NSIndexPath).row

        let presetModel:Presets = presetArray[(indexPath as NSIndexPath).row]
        (endCell as! PresetTableViewCell).presetSteps.text = "\(presetModel.steps)"
        (endCell as! PresetTableViewCell).presetName.text = NSLocalizedString("\(presetModel.label)", comment: "")
        (endCell as! PresetTableViewCell).presetStates.isOn = presetModel.status
        if(!presetModel.status){
            (endCell as! PresetTableViewCell).backgroundColor = UIColor.clear
        }
        endCell?.selectionStyle = UITableViewCellSelectionStyle.none;
        
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            let cell = endCell as! PresetTableViewCell
            cell.backgroundColor = UIColor.getGreyColor()
            cell.contentView.backgroundColor = UIColor.getGreyColor()
            cell.presetSteps.textColor = UIColor.white
            cell.presetName.textColor = UIColor.white
            cell.presetStates.onTintColor = UIColor.getBaseColor()
        }
        
        return endCell!
    }

    func controllManager(_ sender:AnyObject){
        mDelegate?.controllManager(sender)
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
