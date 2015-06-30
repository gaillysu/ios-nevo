//
//  Page1Controller.swift
//  Nevo
//
//  Created by leiyuncun on 15/5/14.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class Page6Controller: UIViewController,ButtonActionCallBack {

    var pagesView:TutorialPage6View!

    override func viewDidLoad() {
        super.viewDidLoad()

        pagesView = TutorialPage6View(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height), delegate: self, bluetoothHint: true)
        self.view .addSubview(pagesView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    Button Action CallBack
    */
    func nextButtonAction(sender:UIButton){
        AppTheme.DLog("Page6 CallBack Success")
        if sender.isEqual(pagesView.getBackButton()) {
            self.navigationController?.popViewControllerAnimated(true)
        }else{
            self.dismissViewControllerAnimated(true, completion: nil);
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
