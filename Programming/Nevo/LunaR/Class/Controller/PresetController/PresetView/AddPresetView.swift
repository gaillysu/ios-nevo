//
//  AddPresetView.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/3.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class AddPresetView: UIView {
    var mDelegate:ButtonManagerCallBack?

    @IBOutlet weak var presetNumber: UITextField!
    @IBOutlet weak var presetName: UITextField!

    func bulidAddPresetView(navigation:UINavigationItem,delegate:ButtonManagerCallBack){
        mDelegate = delegate
        navigation.title = NSLocalizedString("add_goal", comment: "")
        self.backgroundColor = UIColor.getGreyColor()//AppTheme.NEVO_CUSTOM_COLOR(Red: 241.0, Green: 240.0, Blue: 241.0)

        let rightButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: #selector(AddPresetView.controllManager(_:)))
        navigation.rightBarButtonItem = rightButton

        let rightView:UILabel = UILabel(frame: CGRectMake(0,0,50,presetNumber.frame.size.height))
        rightView.text = NSLocalizedString("steps_unit", comment: "")
        rightView.textAlignment = NSTextAlignment.Center
        rightView.font = AppTheme.SYSTEMFONTOFSIZE(mSize: 18)
        rightView.textColor = UIColor.grayColor()
        presetNumber.rightView = rightView
        presetNumber.rightViewMode = UITextFieldViewMode.Always
        presetNumber.textAlignment = NSTextAlignment.Right
        presetNumber.font = AppTheme.SYSTEMFONTOFSIZE(mSize: 18)
        presetNumber.keyboardType = UIKeyboardType.NumberPad
        presetNumber.layer.cornerRadius = 8
        presetNumber.layer.masksToBounds = true
        presetNumber.layer.borderWidth = 1
        presetNumber.layer.borderColor = UIColor.grayColor().CGColor
        presetNumber.backgroundColor = UIColor.whiteColor()

        presetName.leftView = UILabel(frame: CGRectMake(0,0,10,presetName.frame.size.height))
        presetName.leftViewMode = UITextFieldViewMode.Always
        presetName.layer.cornerRadius = 8
        presetName.layer.masksToBounds = true
        presetName.layer.borderWidth = 1
        presetName.layer.borderColor = UIColor.whiteColor().CGColor
        presetName.placeholder = NSLocalizedString("goal_name", comment: "")
        presetName.backgroundColor = UIColor.whiteColor()
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
