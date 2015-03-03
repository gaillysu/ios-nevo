//
//  EnterNotificationController.swift
//  Nevo
//
//  Created by leiyuncun on 15/3/3.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class EnterNotificationController: UIViewController {

    @IBOutlet var enterNotifiView: EnterNotificationView!
    var type:Int!

    override func viewDidLoad() {
        super.viewDidLoad()

        enterNotifiView.bulidUI()

        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 120, 30))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = NSLocalizedString("NotificationType", comment: "")
        titleLabel.font = UIFont.systemFontOfSize(25)
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel

        let backButton:UIButton = UIButton(frame: CGRectMake(0, 0, 35, 35))
        backButton.setImage(UIImage(named: "back"), forState: UIControlState.Normal)
        backButton.addTarget(self, action: Selector("BackAction:"), forControlEvents: UIControlEvents.TouchUpInside)
        let item:UIBarButtonItem = UIBarButtonItem(customView: backButton as UIView);
        self.navigationItem.leftBarButtonItem = item

        //TODD
        switch (type){

        case 0:
            enterNotifiView.titleLabel.text = "FaceBook"
            break

        case 1:
            enterNotifiView.titleLabel.text = "SMS"
            break

        case 2:
            enterNotifiView.titleLabel.text = "CALL"
            break

        case 3:
            enterNotifiView.titleLabel.text = "EMAIL"
            break

        default:

            break
            
        }
        
    }

    func BackAction(back:UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
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
