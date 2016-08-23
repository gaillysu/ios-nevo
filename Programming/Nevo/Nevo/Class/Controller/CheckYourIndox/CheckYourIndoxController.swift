//
//  CheckYourIndoxController.swift
//  Nevo
//
//  Created by leiyuncun on 16/6/30.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class CheckYourIndoxController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.lt_setBackgroundColor(UIColor(rgba: "#54575a"))
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        let leftButton:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "cancel_lunar"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(leftCancelAction(_:)))
        self.navigationItem.leftBarButtonItem = leftButton

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.lt_reset()
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
    }

    func leftCancelAction(sender:UIBarButtonItem) {
        let viewController = self.navigationController?.popViewControllerAnimated(true)
        if viewController != nil {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
