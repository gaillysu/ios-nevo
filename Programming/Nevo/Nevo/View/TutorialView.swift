//
//  TutorialView.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/2.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIkit

class TutorialView: UIView {
    var mTutorialButton: UIButton!

    var mBuyButton: UIButton!

    let COLOR_00C6DC = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)//The color of the button font color and other needs to use
    let FONT_RALEWAY_BOLD:UIFont! = UIFont(name:"Raleway-Thin", size: 26);//Uniform font


    var mDelegate:UIViewController!//The current controller

    init(frame: CGRect, delegate:UIViewController) {
        super.init(frame: frame)
        super.backgroundColor = UIColor.whiteColor()
        mDelegate = delegate
        bulidTutorialView()
    }


    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /*
    init all controls
    */
    func bulidTutorialView(){

        //The background image,center display
        let backgroundImage:UIImageView = UIImageView(frame: CGRectMake(0, 0, self.frame.size.width, self.frame.height))
        backgroundImage.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0)
        backgroundImage.userInteractionEnabled = true;
        backgroundImage.backgroundColor = UIColor.clearColor();
        backgroundImage.image = UIImage(named: "NevoPicture")
        self.addSubview(backgroundImage)

        //Click into the tutorial page
        //TODO string

        mTutorialButton = UIButton(frame: CGRectMake(0, 0, 160, 48))
        mTutorialButton.setTitle(NSLocalizedString("Tutorial", comment:"Tutorial button title"), forState: UIControlState.Normal)
        mTutorialButton.setTitleColor(COLOR_00C6DC, forState: UIControlState.Normal)
        mTutorialButton.titleLabel?.font = FONT_RALEWAY_BOLD
        mTutorialButton.addTarget(self, action: Selector("displayTutorialPageView"), forControlEvents: UIControlEvents.TouchUpInside)
        mTutorialButton.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height-106)
        self.addSubview(mTutorialButton)

        //TODO string
        mBuyButton = UIButton(frame: CGRectMake(0, 0, 160, 48))
        mBuyButton.setTitle(NSLocalizedString("Acheter", comment:"Acheter button title"), forState: UIControlState.Normal)
        mBuyButton.setTitleColor(COLOR_00C6DC, forState: UIControlState.Normal)
        mBuyButton.titleLabel?.font = FONT_RALEWAY_BOLD
        mBuyButton.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height-53)
        mBuyButton.addTarget(self, action: Selector("DismisTutorial"), forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(mBuyButton)


    }

    /*
    Display TutorialView page
    */
    func displayTutorialPageView(){
        
        let pageFrame = CGRectMake(0, 0, self.frame.width, self.frame.height)
        
        //TODO Displays the Page slide
        //Array represents the display of the page
        let pagesArray:[UIView] = [TutorialPage1View(frame:pageFrame,delegate:mDelegate),TutorialPage1View(frame:pageFrame,delegate:mDelegate),TutorialScanPageView(frame:pageFrame,delegate:mDelegate)]
        let pageView:PageView = PageView(frame: CGRectMake(0, 0, 320, 320))
        pageView.frame = pageFrame
        pageView.displayPageView(pagesArray)
        self.addSubview(pageView)
    }

    /*
    Jump out of the Tutorial View
    */
    func DismisTutorial() {
        mDelegate.dismissViewControllerAnimated(true, completion: nil)
    }

}
