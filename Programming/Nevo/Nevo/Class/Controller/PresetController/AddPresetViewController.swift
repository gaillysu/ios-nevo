//
//  AddPresetViewController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/3.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit


class AddPresetViewController: UIViewController,ButtonManagerCallBack {

    @IBOutlet weak var addPresetView: AddPresetView!
    var addDelegate:AddPresetDelegate?
    
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - ButtonManagerDelegate
    func controllManager(_ sender:AnyObject){
        let number:NSString = addPresetView.presetNumber.text! as NSString
        let length:Int = number.length
        if(length >= 4){
            addDelegate?.onAddPresetNumber(Int(addPresetView.presetNumber.text!)!, name: addPresetView.presetName.text!)
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AddPresetViewController {
    fileprivate func styleEvolve() {
        if !AppTheme.isTargetLunaR_OR_Nevo() {
//            view.backgroundColor = UIColor.getGreyColor()
        }
    }
}
