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

    func bulidPresetView(navigation:UINavigationItem,delegateB:ButtonManagerCallBack){
        mDelegate = delegateB
        navigation.title = NSLocalizedString("title_goal", comment: "")
        leftButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: #selector(PresetView.controllManager(_:)))
        navigation.rightBarButtonItem = leftButton
    }

    func getPresetTableViewCell(indexPath:NSIndexPath,tableView:UITableView,presetArray:[Presets],delegate:ButtonManagerCallBack)->UITableViewCell{
        let endCellID:String = "PresetTableViewCell"
        var endCell = tableView.dequeueReusableCellWithIdentifier(endCellID)
        if (endCell == nil) {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("PresetTableViewCell", owner: self, options: nil)
            endCell = nibs.objectAtIndex(0) as? PresetTableViewCell;

        }
        (endCell as! PresetTableViewCell).delegate = delegate
        (endCell as! PresetTableViewCell).presetStates.tag = indexPath.row

        let presetModel:Presets = presetArray[indexPath.row]
        (endCell as! PresetTableViewCell).presetSteps.text = "\(presetModel.steps)"
        (endCell as! PresetTableViewCell).presetName.text = NSLocalizedString("\(presetModel.label)", comment: "")
        (endCell as! PresetTableViewCell).presetStates.on = presetModel.status
        if(presetModel.status){
            (endCell as! PresetTableViewCell).backgroundColor = UIColor.getLightBaseColor()
        }else{
            endCell?.backgroundColor = UIColor.getGreyColor()
        }
        endCell?.selectionStyle = UITableViewCellSelectionStyle.None;
        return endCell!
    }

    func controllManager(sender:AnyObject){
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
