//
//  Page1Controller.swift
//  Nevo
//
//  Created by leiyuncun on 15/5/14.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class Page5Controller: UIViewController,ButtonActionCallBack {

    var pagesView:TutorialPage5View!

    override func viewDidLoad() {
        super.viewDidLoad()

        pagesView = TutorialPage5View(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height), delegate: self, bluetoothHint: true)
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
        AppTheme.DLog("Page5 CallBack Success")
        if sender.isEqual(pagesView.getBackButton()) {
            self.navigationController?.popViewControllerAnimated(true)
        }else{
            let page6cont = Page6Controller()
            self.navigationController?.pushViewController(page6cont, animated: true)
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
