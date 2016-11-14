//
//  AddPresetViewController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/3.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

public enum AddPresetControllerPurpose {
    case Add
    case Edit
}


class AddPresetViewController: UIViewController,ButtonManagerCallBack {

    @IBOutlet weak var addPresetView: AddPresetView!
    var addDelegate:AddPresetDelegate?
    
    var purpose:AddPresetControllerPurpose = .Add
    var goalItem:Presets? = nil
    
    init() {
        super.init(nibName: "AddPresetViewController", bundle: Bundle.main)
        styleEvolve()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        
        switch purpose {
        case .Add:
            navigationController?.title = NSLocalizedString("add_goal", comment: "")
        default:
            navigationController?.title = NSLocalizedString("Edit goal", comment: "")
            
            addPresetView.presetNumber.text = "\((goalItem?.steps)!)"
            addPresetView.presetName.text = goalItem?.label
        }
        
        addPresetView.bulidAddPresetView(self.navigationItem, delegate: self)
        
        // MARK: - APPTHEME ADJUST
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            view.backgroundColor = UIColor.getLightBaseColor()
            addPresetView.backgroundColor = UIColor.getLightBaseColor()
            addPresetView.presetNumber.backgroundColor = UIColor.getGreyColor()
            addPresetView.presetName.backgroundColor = UIColor.getGreyColor()
        } else {
            view.backgroundColor = UIColor(rgba: "#EFEFF4")
            addPresetView.backgroundColor = UIColor(rgba: "#EFEFF4")
            addPresetView.presetNumber.backgroundColor = UIColor.white
            addPresetView.presetName.backgroundColor = UIColor.white
        }
    }

    // MARK: - ButtonManagerDelegate
    func controllManager(_ sender:AnyObject){
        let number:NSString = addPresetView.presetNumber.text! as NSString
        let length:Int = number.length
        if(length >= 4){
            switch purpose {
            case .Add:
                addDelegate?.onAddPresetNumber(Int(addPresetView.presetNumber.text!)!, name: addPresetView.presetName.text!)
            default:
                goalItem?.label = addPresetView.presetName.text!
                goalItem?.steps = (addPresetView.presetNumber.text?.toInt())!
            }
            self.navigationController?.popViewController(animated: true)
        }else{
            if((UIDevice.current.systemVersion as NSString).floatValue >= 8.0){
                let actionSheet:ActionSheetView = ActionSheetView(title: "", message: NSLocalizedString("goal_must_bigger_1000", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                actionSheet.view.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
                let alertAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: UIAlertActionStyle.default, handler: { (action:UIAlertAction) -> Void in

                })
                actionSheet.addAction(alertAction)
                self.present(actionSheet, animated: true, completion: nil)
            }else{
                let actionSheet:UIAlertView = UIAlertView(title: "", message: NSLocalizedString("goal_must_bigger_1000", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("Cancel", comment: ""), otherButtonTitles: NSLocalizedString("Ok", comment: ""))
                actionSheet.alertViewStyle = UIAlertViewStyle.plainTextInput
                actionSheet.show()
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        addPresetView.presetName.resignFirstResponder()
        addPresetView.presetNumber.resignFirstResponder()
    }
}

extension AddPresetViewController {
    fileprivate func styleEvolve() {
        if !AppTheme.isTargetLunaR_OR_Nevo() {
//            view.backgroundColor = UIColor.getGreyColor()
        }
    }
}
