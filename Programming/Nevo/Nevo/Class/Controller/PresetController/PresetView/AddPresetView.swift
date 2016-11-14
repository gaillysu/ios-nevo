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
    
    func bulidAddPresetView(_ navigation:UINavigationItem,delegate:ButtonManagerCallBack){
        mDelegate = delegate
        navigation.title = NSLocalizedString("add_goal", comment: "")
        //self.backgroundColor = AppTheme.hexStringToColor("#EFEFF4")//AppTheme.NEVO_CUSTOM_COLOR(Red: 241.0, Green: 240.0, Blue: 241.0)

        let rightButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(AddPresetView.controllManager(_:)))
        navigation.rightBarButtonItem = rightButton

        let rightView:UILabel = UILabel(frame: CGRect(x: 0,y: 0,width: 50,height: presetNumber.frame.size.height))
        rightView.text = NSLocalizedString("steps_unit", comment: "")
        rightView.textAlignment = NSTextAlignment.center
        rightView.font = UIFont.systemFont(ofSize: 18)
        rightView.textColor = UIColor.gray
        presetNumber.rightView = rightView
        presetNumber.rightViewMode = UITextFieldViewMode.always
        presetNumber.textAlignment = NSTextAlignment.right
        presetNumber.font = UIFont.systemFont(ofSize: 18)
        presetNumber.keyboardType = UIKeyboardType.numberPad
        presetNumber.layer.cornerRadius = 8
        presetNumber.layer.masksToBounds = true
        presetNumber.layer.borderWidth = 1
        presetNumber.layer.borderColor = UIColor.gray.cgColor
        presetNumber.backgroundColor = UIColor.white

        presetName.leftView = UILabel(frame: CGRect(x: 0,y: 0,width: 10,height: presetName.frame.size.height))
        presetName.leftViewMode = UITextFieldViewMode.always
        presetName.layer.cornerRadius = 8
        presetName.layer.masksToBounds = true
        presetName.layer.borderWidth = 1
        presetName.layer.borderColor = UIColor.white.cgColor
        presetName.placeholder = NSLocalizedString("goal_name", comment: "")
        presetName.backgroundColor = AppTheme.NEVO_SOLAR_GRAY()
        
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            
            rightView.textColor = UIColor.white
            
            presetNumber.textColor = UIColor.white
            presetNumber.backgroundColor = UIColor.getLightBaseColor()
            presetNumber.setValue(UIColor.white, forKeyPath: "_placeholderLabel.textColor")
            presetNumber.tintColor = UIColor.white
            
            presetName.textColor = UIColor.white
            presetName.backgroundColor = UIColor.getLightBaseColor()
            presetName.layer.borderColor = UIColor.gray.cgColor
            presetName.setValue(UIColor.gray, forKeyPath: "_placeholderLabel.textColor")
            presetName.tintColor = UIColor.white
        }
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
