//
//  PageViewController.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/10.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class PageViewController: UIViewController {

    @IBOutlet var pageview: PageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pageview.bulidPageView()

        let pageFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)

        //TODO Displays the Page slide
        //Array represents the display of the page
        let pagesArray:[UIView] = [TutorialPage1View(frame:pageFrame,delegate:self),TutorialPage1View(frame:pageFrame,delegate:self),TutorialScanPageView(frame:pageFrame,delegate:self)]
        pageview.displayPageView(pagesArray)
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
