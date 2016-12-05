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

    func getPresetTableViewCell(_ indexPath:IndexPath,tableView:UITableView,presetArray:[MEDUserGoal],delegate:ButtonManagerCallBack)->UITableViewCell{
        let cell:PresetTableViewCell = tableView.dequeueReusableCell(withIdentifier: "UserGoal_Identifier", for: indexPath) as! PresetTableViewCell
        cell.delegate = delegate
        cell.presetStates.tag = (indexPath as NSIndexPath).row

        let presetModel:MEDUserGoal = presetArray[indexPath.row]
        cell.presetSteps.text = "\(presetModel.stepsGoal)"
        cell.presetName.text = NSLocalizedString("\(presetModel.label)", comment: "")
        cell.presetStates.isOn = presetModel.status
        if(!presetModel.status){
            cell.backgroundColor = UIColor.clear
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.none;
        cell.viewDefaultColorful()
        
        return cell
    }

    func controllManager(_ sender:AnyObject){
        mDelegate?.controllManager(sender)
    }
}
