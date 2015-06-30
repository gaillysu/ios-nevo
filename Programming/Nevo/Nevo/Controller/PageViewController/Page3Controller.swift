//
//  Page2Controller.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/10.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class Page3Controller: UIViewController,ButtonActionCallBack {

    var pagesView:TutorialPage3View!

    override func viewDidLoad() {
        super.viewDidLoad()

        pagesView = TutorialPage3View(frame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height),delegate:self)
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
        AppTheme.DLog("Page3 CallBack Success")
        if sender.isEqual(pagesView.getBackButton()) {
            self.navigationController?.popViewControllerAnimated(true)
        }else{
            let page4cont = Page4Controller()
            self.navigationController?.pushViewController(page4cont, animated: true)
        }
    }
}
