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
        super.init(nibName: "AddPresetViewController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addPresetView.bulidAddPresetView(self.navigationItem, delegate: self)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - ButtonManagerDelegate
    func controllManager(sender:AnyObject){
        let number:NSString = addPresetView.presetNumber.text! as NSString
        let length:Int = number.length
        if(length >= 4){
            addDelegate?.onAddPresetNumber(Int(addPresetView.presetNumber.text!)!, name: addPresetView.presetName.text!)
            self.navigationController?.popViewControllerAnimated(true)
        }else{
            if((UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0){
                let actionSheet:UIAlertController = UIAlertController(title: "", message: NSLocalizedString("goal_must_bigger_1000", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                actionSheet.view.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
                let alertAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in

                })
                actionSheet.addAction(alertAction)
                self.presentViewController(actionSheet, animated: true, completion: nil)
            }else{
                let actionSheet:UIAlertView = UIAlertView(title: "", message: NSLocalizedString("goal_must_bigger_1000", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("Cancel", comment: ""), otherButtonTitles: NSLocalizedString("Ok", comment: ""))
                actionSheet.alertViewStyle = UIAlertViewStyle.PlainTextInput
                actionSheet.show()
            }
        }
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
