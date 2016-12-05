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
    var goalItem:MEDUserGoal?
    
    init() {
        super.init(nibName: "AddPresetViewController", bundle: Bundle.main)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        
        
        switch purpose {
        case .Add:
            navigationItem.title = NSLocalizedString("add_goal", comment: "")
        default:
            navigationItem.title = NSLocalizedString("Edit goal", comment: "")
            
            addPresetView.presetNumber.text = "\((goalItem?.stepsGoal)!)"
            addPresetView.presetName.text = goalItem?.label
        }
        
        addPresetView.bulidAddPresetView(self.navigationItem, delegate: self)
        
        /// Theme adjust
        viewDefaultColorful()
        addPresetView.viewDefaultColorful()
        
        /// Todo: 2016-11-23
        /// Quentin
        if AppTheme.isTargetLunaR_OR_Nevo() {
            view.backgroundColor = UIColor(rgba: "#EFEFF4")
            addPresetView.backgroundColor = UIColor(rgba: "#EFEFF4")
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
                goalItem?.stepsGoal = (addPresetView.presetNumber.text?.toInt())!
            }
            _ = self.navigationController?.popViewController(animated: true)
        }else{
            if((UIDevice.current.systemVersion as NSString).floatValue >= 8.0){
                let actionSheet:ActionSheetView = ActionSheetView(title: "", message: NSLocalizedString("goal_must_bigger_1000", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                actionSheet.view.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
                let alertAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: UIAlertActionStyle.default, handler: { (action:UIAlertAction) -> Void in

                })
                actionSheet.addAction(alertAction)
                self.present(actionSheet, animated: true, completion: nil)
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        addPresetView.presetName.resignFirstResponder()
        addPresetView.presetNumber.resignFirstResponder()
    }
}
