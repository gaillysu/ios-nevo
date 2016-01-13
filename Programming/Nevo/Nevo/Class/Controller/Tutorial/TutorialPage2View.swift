//
//  TutorialPage1View.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 9/2/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation

class TutorialPage2View : UIView {
    private var mDelegate:Page2Controller?

    let TEXT_FONT:UIFont = UIFont(name:"Raleway-Light", size: 25)!

    let BACK_BUTTON_FONT:UIFont = UIFont(name:"Raleway-Light", size: 20)!

    let BACKGROUND_COLOR:UIColor = UIColor(red: 244.0/255.0, green: 242.0/255.0, blue: 241.0/255.0, alpha: 1)

    private var mBackButton:UIButton?

    private var mBluetoothHint:Bool = false
    
    init(frame: CGRect, delegate:UIViewController, bluetoothHint:Bool) {
        mBluetoothHint = bluetoothHint
        super.init(frame: frame)
        super.backgroundColor = BACKGROUND_COLOR
        if let callBackDelgate = delegate as? Page2Controller {

            mDelegate = callBackDelgate
        }
        buildTutorialPage()
        
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        buildTutorialPage()
    }

    func buildTutorialPage() {

        let backButton = UIButton(type:UIButtonType.Custom)
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
        guideImage.userInteractionEnabled = true;
        guideImage.backgroundColor = UIColor.clearColor()
        self.addSubview(guideImage)

        let titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, self.frame.size.width-20, 60))
        titleLabel.center = CGPointMake(self.frame.size.width/2.0, guideImage.frame.origin.y+guideImage.frame.size.height+70)
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        titleLabel.font = AppTheme.FONT_RALEWAY_LIGHT(mSize:23)
        titleLabel.text = NSLocalizedString("EnableBluetoothPhone",comment:"lable string")
        self.addSubview(titleLabel)


        let statesImage:UIImageView = UIImageView(image: UIImage(named: String("Bluetoothoff" as NSString)))
        statesImage.frame = CGRectMake(0, 0, self.frame.size.width-70, 100)
        statesImage.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0+50)
        statesImage.contentMode = UIViewContentMode.ScaleAspectFit
        statesImage.backgroundColor = UIColor.clearColor()
        self.addSubview(statesImage)

        

        let nextButton:UIButton = UIButton(type:UIButtonType.Custom)
        nextButton.frame = CGRectMake(0, 0, 120, 50)
        nextButton.setTitle(NSLocalizedString("Next",comment:"button title string"), forState: UIControlState.Normal)
        nextButton.titleLabel?.font = TEXT_FONT
        nextButton.setTitleColor(AppTheme.NEVO_SOLAR_YELLOW(), forState: UIControlState.Normal)
        if AppTheme.GET_IS_iPhone5S() {
            nextButton.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height-25)
        }else {
            nextButton.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height-50)
        }
        nextButton.addTarget(self, action: "ButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        nextButton.hidden = true
        self.addSubview(nextButton)

        let errorLabel:UILabel = UILabel(frame: CGRectMake(0, 0, titleLabel.frame.size.width, 90))
        errorLabel.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height-100)
        errorLabel.textAlignment = NSTextAlignment.Center
        errorLabel.numberOfLines = 0
        errorLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        errorLabel.font = TEXT_FONT
        errorLabel.text = NSLocalizedString("BluetoothIcon",comment:"lable string")
        self.addSubview(errorLabel)

        let upwardimage:UIImageView = UIImageView(image: UIImage(named: String("upward" as NSString)))
        upwardimage.frame = CGRectMake(0, 0,20, 50)
        upwardimage.contentMode = UIViewContentMode.ScaleAspectFit
        upwardimage.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height-20)
        upwardimage.backgroundColor = UIColor.clearColor()
        self.addSubview(upwardimage)

        if mBluetoothHint  {
            statesImage.image = UIImage(named:"Bluetoothon")
            titleLabel.text = NSLocalizedString("BluetoothEnabled",comment:"lable string")
            titleLabel.textAlignment = NSTextAlignment.Center
            nextButton.hidden = false
            upwardimage.hidden = true
            errorLabel.hidden = true
        }

    }
    
    func getBackButton() -> UIButton? {
        return mBackButton
    }
    
    func getBluetoothHint() -> Bool {
        return mBluetoothHint
    }

    func ButtonAction(sender:UIButton){
        mDelegate?.nextButtonAction(sender)
    }
}