//
//  Page3Controller.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/10.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class Page3Controller: UIViewController,ButtonActionCallBack {

    override func viewDidLoad() {
        super.viewDidLoad()

        let pagesArray:UIView = TutorialScanPageView(frame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height),delegate:self)
        self.view .addSubview(pagesArray)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    Button Action CallBack
    */
    func nextButtonAction(sender:UIButton){

        NSLog("Page3 CallBack Success")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
