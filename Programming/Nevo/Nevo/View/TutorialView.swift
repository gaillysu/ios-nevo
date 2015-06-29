//
//  TutorialView.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/2.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//


class TutorialView: UIView {
    private var mTutorialButton: UIButton?

    private var mBuyButton: UIButton?

    let COLOR_00C6DC = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1)//The color of the button font color and other needs to use

    private var mDelegate:UIViewController//The current controller

    init(frame: CGRect, delegate:UIViewController) {
        mDelegate = delegate
        
        super.init(frame: frame)
        super.backgroundColor = UIColor.whiteColor()
        
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
        if AppTheme.GET_IS_iPhone4S() {
            backgroundImage.image = AppTheme.GET_RESOURCES_IMAGE("NevoPicture960")
        }else {
            backgroundImage.image = AppTheme.GET_RESOURCES_IMAGE("NevoPicture")
        }

        self.addSubview(backgroundImage)

        //Click into the tutorial page
        var labelSize:CGSize = NSLocalizedString("Tutorial", comment:"Tutorial button title").boundingRectWithSize(CGSizeMake(self.frame.size.width, 1000), options: NSStringDrawingOptions.UsesFontLeading, attributes: [NSFontAttributeName:AppTheme.FONT_RALEWAY_THIN()], context: nil).size
        labelSize.height = ceil(labelSize.height);
        labelSize.width = ceil(labelSize.width);

        let tutorialButton = UIButton(frame: CGRectMake(0, 0, labelSize.width, labelSize.height))
        tutorialButton.setTitle(NSLocalizedString("Tutorial", comment:"Tutorial button title"), forState: UIControlState.Normal)
        tutorialButton.setTitleColor(COLOR_00C6DC, forState: UIControlState.Normal)
        tutorialButton.titleLabel?.font = AppTheme.FONT_RALEWAY_THIN()
        tutorialButton.addTarget(self, action: Selector("displayTutorialPageView"), forControlEvents: UIControlEvents.TouchUpInside)
        tutorialButton.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height-106)
        self.addSubview(tutorialButton)
        
        mTutorialButton = tutorialButton

        //Automatic text width
        var buyButtonSize:CGSize = NSLocalizedString("Acheter", comment:"Acheter button title").boundingRectWithSize(CGSizeMake(self.frame.size.width, 1000), options: NSStringDrawingOptions.UsesFontLeading, attributes: [NSFontAttributeName:AppTheme.FONT_RALEWAY_THIN()], context: nil).size
        buyButtonSize.height = ceil(buyButtonSize.height);
        buyButtonSize.width = ceil(buyButtonSize.width);

        let buyButton = UIButton(frame: CGRectMake(0, 0, buyButtonSize.width, buyButtonSize.height))
        buyButton.setTitle(NSLocalizedString("Acheter", comment:"Acheter button title"), forState: UIControlState.Normal)
        buyButton.setTitleColor(COLOR_00C6DC, forState: UIControlState.Normal)
        buyButton.titleLabel?.font = AppTheme.FONT_RALEWAY_THIN(mSize:24)
        buyButton.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height-53)
        buyButton.addTarget(self, action: Selector("DismisTutorial"), forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(buyButton)
        
        mBuyButton = buyButton


    }

    /*
    Display TutorialView page
    */
    func displayTutorialPageView(){
        let page1Cont = Page1Controller()
        mDelegate.navigationController?.pushViewController(page1Cont, animated: true)
    }

    /*
    Jump out of the Tutorial View
    */
    func DismisTutorial() {
        //mDelegate.dismissViewControllerAnimated(true, completion: nil)
        UIApplication.sharedApplication().openURL(NSURL(string:NSLocalizedString("nevoURL",comment:""))!)
    }
    
    func getTutorialButton() -> UIButton? {
        return mTutorialButton
    }
    
    func getBuyButton() -> UIButton? {
        return mBuyButton
    }

}
