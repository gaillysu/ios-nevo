//
//  MyNevoController.swift
//  Nevo
//
//  Created by leiyuncun on 15/5/18.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class MyNevoController: UIViewController,ButtonManagerCallBack {

    @IBOutlet var mynevoView: MyNevoView!

    override func viewDidLoad() {
        super.viewDidLoad()

        mynevoView.bulidMyNevoView(self)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func controllManager(sender:AnyObject){
        if(sender.isEqual(mynevoView.backButton)){
            self.navigationController?.popViewControllerAnimated(true)
        }

        if(sender.isEqual(mynevoView.UpgradeButton)){
            self.performSegueWithIdentifier("Setting_nevoOta", sender: self)
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
