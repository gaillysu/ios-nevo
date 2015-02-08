//
//  TutorialView.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/2.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIkit

class TutorialView: UIView {
    var tutorialButton: UIButton!

    var acheterButton: UIButton!

    let color00C6DC = UIColor(red: 65/255.0, green: 105/255.0, blue: 225/255.0, alpha: 1)//The color of the button font color and other needs to use
    let fontRalewayBold:UIFont! = UIFont(name:"Raleway-Thin", size: 30);//Uniform font

    var Controller:UIViewController!//The current controller

    init(frame: CGRect, delegate:UIViewController) {
        super.init(frame: frame)
        super.backgroundColor = UIColor.whiteColor()
        Controller = delegate
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
        let backgroundImage:UIImageView = UIImageView(frame: CGRectMake(0, 0, self.frame.size.width*(self.frame.width/self.frame.size.height)*1.5, self.frame.height*(self.frame.size.width/self.frame.size.height)*1.5))
        backgroundImage.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0)
        backgroundImage.userInteractionEnabled = true;
        backgroundImage.backgroundColor = UIColor.clearColor();
        backgroundImage.image = UIImage(named: "640-1136")
        self.addSubview(backgroundImage)

        //Click into the tutorial page
        //TODO string
        tutorialButton = UIButton(frame: CGRectMake(0, 0, 160, 48))
        tutorialButton.setTitle(NSLocalizedString("Tutorial", comment:""), forState: UIControlState.Normal)
        tutorialButton.setTitleColor(color00C6DC, forState: UIControlState.Normal)
        tutorialButton.titleLabel?.font = fontRalewayBold
        tutorialButton.addTarget(self, action: Selector("displayTutorialPageView"), forControlEvents: UIControlEvents.TouchUpInside)
        tutorialButton.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height-146)
        self.addSubview(tutorialButton)

        //TODO string
        acheterButton = UIButton(frame: CGRectMake(0, 0, 160, 48))
        acheterButton.setTitle(NSLocalizedString("Acheter", comment:""), forState: UIControlState.Normal)
        acheterButton.setTitleColor(color00C6DC, forState: UIControlState.Normal)
        acheterButton.titleLabel?.font = fontRalewayBold
        acheterButton.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height-93)
        acheterButton.addTarget(self, action: Selector("DismisTutorial"), forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(acheterButton)

    }

    /*
    Display TutorialView page
    */
    func displayTutorialPageView(){
        //TODO Displays the Page slide
        //Array represents the display of the page
        let imageArray:NSArray = ["nevo360","nevo360","nevo360"]
        let pageView:PageView = PageView(frame: CGRectMake(0, 0, 320, 320))
        pageView.frame = CGRectMake(0, 0, self.frame.width, self.frame.height)
        pageView.displayPageView(imageArray)
        self.addSubview(pageView)
    }

    /*
    Jump out of the Tutorial View
    */
    func DismisTutorial() {
        Controller.dismissViewControllerAnimated(true, completion: nil)
    }

}
