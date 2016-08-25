//
//  ForgotPasswordController.swift
//  Nevo
//
//  Created by leiyuncun on 16/6/29.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import AutocompleteField

class ForgotPasswordController: UIViewController {

    @IBOutlet weak var emailTextField: AutocompleteField!
    
    @IBOutlet weak var sendButton: UIButton!
    
    init() {
        super.init(nibName: "ForgotPasswordController", bundle: NSBundle.mainBundle())
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let leftButton:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "cancel_lunar"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(leftCancelAction(_:)))
        self.navigationItem.leftBarButtonItem = leftButton
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func leftCancelAction(sender:UIBarButtonItem) {
        let viewController = self.navigationController?.popViewControllerAnimated(true)
        if viewController != nil {
            self.dismissViewControllerAnimated(true, completion: nil)
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
