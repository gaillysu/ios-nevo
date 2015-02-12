//
//  PageViewController.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/10.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit


class Page1Controller: UIViewController,ButtonActionCallBack {

    
    override func viewDidLoad() {
        super.viewDidLoad()

        //TODO Displays the Page slide
        //Array represents the display of the page
        let pagesArray:UIView = TutorialPage1View(frame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height),delegate:self)
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

        NSLog("CallBack Success")
        let page2controller = Page2Controller()
        page2controller.navigationController?.navigationBarHidden = true
        self.navigationController?.pushViewController(page2controller, animated: true)
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
