//
//  TutorialPage2View.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/11.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class TutorialPage2View: UIView {

    private var mDelegate:Page2Controller?

    let BACKGROUND_COLOR:UIColor = UIColor(red: 244.0/255.0, green: 242.0/255.0, blue: 241.0/255.0, alpha: 1)

    let TEXT_FONT:UIFont = UIFont(name:"Raleway-Light", size: 20)!
    
    let BUTTON_FONT:UIFont = UIFont(name:"Raleway-Light", size: 25)!

    let BACK_BUTTON_FONT:UIFont = UIFont(name:"Raleway-Light", size: 20)!

    private var mBackButton:UIButton?

    init(frame: CGRect, delegate:UIViewController) {
        super.init(frame: frame)
        super.backgroundColor = BACKGROUND_COLOR
        if let callBackDelgate = delegate as? Page2Controller {

            mDelegate = callBackDelgate
        }
        buildTutorialPage()

    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        buildTutorialPage()
    }

    func buildTutorialPage() {

        let backButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        backButton.frame = CGRectMake(15, 10, 70, 40)
        backButton.setTitle(NSLocalizedString("Back",comment:"button title string"), forState: UIControlState.Normal)
        backButton.titleLabel?.font = BACK_BUTTON_FONT
        backButton.setTitleColor(AppTheme.NEVO_SOLAR_YELLOW(), forState: UIControlState.Normal)
        backButton.addTarget(self, action: "ButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(backButton)
        
        mBackButton = backButton
        
        let guideImage:UIImageView = UIImageView(image: UIImage(named: String("step2" as NSString)))
        guideImage.frame = CGRectMake(0, 0, self.frame.size.width-70, 100)
        guideImage.center = CGPointMake(self.frame.size.width/2.0, 100)
        guideImage.contentMode = UIViewContentMode.ScaleAspectFit
        guideImage.backgroundColor = UIColor.clearColor()
        self.addSubview(guideImage)

        let sideImage:UIImageView = UIImageView(image: UIImage(named: String("side" as NSString)))
        sideImage.frame = CGRectMake(0, 0, 120, self.frame.size.width-100)
        if AppTheme.GET_IS_iPhone4S() {
            sideImage.center = CGPointMake(50, self.frame.size.height/2.0+20)
        }else{
            sideImage.center = CGPointMake(60, self.frame.size.height/2.0+20)
        }

        sideImage.contentMode = UIViewContentMode.ScaleAspectFit
        sideImage.backgroundColor = UIColor.clearColor()
        self.addSubview(sideImage)

        let titleLabel:UILabel = UILabel(frame: CGRectMake(sideImage.frame.size.width-70, guideImage.frame.origin.y+guideImage.frame.size.height-20, guideImage.frame.size.width, 100))
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        titleLabel.font = TEXT_FONT
        titleLabel.text = NSLocalizedString("WatchBluetooth",comment:"lable string")
        self.addSubview(titleLabel)

        let guide2Label:UILabel = UILabel(frame: CGRectMake(titleLabel.frame.origin.x, sideImage.frame.origin.y+sideImage.frame.size.height-30, titleLabel.frame.size.width, 80))
        guide2Label.textAlignment = NSTextAlignment.Left
        guide2Label.numberOfLines = 0
        guide2Label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        guide2Label.font = TEXT_FONT
        guide2Label.text = NSLocalizedString("LongPushLED",comment:"lable string")
        self.addSubview(guide2Label)

        let nextButton:UIButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        nextButton.frame = CGRectMake(0, 0, 120, 50)
        nextButton.setTitle(NSLocalizedString("Next",comment:"button title string"), forState: UIControlState.Normal)
        nextButton.backgroundColor = UIColor.clearColor()
        nextButton.titleLabel?.font = BUTTON_FONT
        nextButton.setTitleColor(AppTheme.NEVO_SOLAR_YELLOW(), forState: UIControlState.Normal)
        if AppTheme.GET_IS_iPhone4S() {
            nextButton.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height-25)
        }else {
            nextButton.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height-50)
        }

        nextButton.addTarget(self, action: "ButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(nextButton)

    }
    
    func ButtonAction(sender:UIButton){
        mDelegate?.nextButtonAction(sender)
    }
    
    func getBackButton() -> UIButton? {
        return mBackButton
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
