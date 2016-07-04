//
//  InformationController.swift
//  Nevo
//
//  Created by leiyuncun on 16/7/4.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class InformationController: UIViewController {

    init() {
        super.init(nibName: "InformationController", bundle: NSBundle.mainBundle())
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Register"
        self.navigationController?.navigationBar.lt_setBackgroundColor(UIColor(rgba: "#54575a"))
        
        let leftButton:UIBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(rightAction(_:)))
        self.navigationItem.rightBarButtonItem = leftButton
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.lt_reset()
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func rightAction(sender:UIBarButtonItem) {
        
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
