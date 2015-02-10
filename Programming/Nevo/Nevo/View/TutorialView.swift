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

    let color00C6DC = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)//The color of the button font color and other needs to use
    let fontRalewayBold:UIFont! = UIFont(name:"Raleway-Thin", size: 26);//Uniform font

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
        let backgroundImage:UIImageView = UIImageView(frame: CGRectMake(0, 0, self.frame.size.width, self.frame.height))
        backgroundImage.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0)
        backgroundImage.userInteractionEnabled = true;
        backgroundImage.backgroundColor = UIColor.clearColor();
        backgroundImage.image = UIImage(named: "NevoPicture")
        self.addSubview(backgroundImage)

        //Click into the tutorial page
        //TODO string
        tutorialButton = UIButton(frame: CGRectMake(0, 0, 230, 48))
        tutorialButton.setTitle(NSLocalizedString("Tutorial", comment:"Tutorial button title"), forState: UIControlState.Normal)
        tutorialButton.setTitleColor(color00C6DC, forState: UIControlState.Normal)
        tutorialButton.titleLabel?.font = fontRalewayBold
        tutorialButton.addTarget(self, action: Selector("displayTutorialPageView"), forControlEvents: UIControlEvents.TouchUpInside)
        tutorialButton.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height-106)
        self.addSubview(tutorialButton)

        //TODO string
        acheterButton = UIButton(frame: CGRectMake(0, 0, 230, 48))
        acheterButton.setTitle(NSLocalizedString("Acheter", comment:"Acheter button title"), forState: UIControlState.Normal)
        acheterButton.setTitleColor(color00C6DC, forState: UIControlState.Normal)
        acheterButton.titleLabel?.font = fontRalewayBold
        acheterButton.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height-53)
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
