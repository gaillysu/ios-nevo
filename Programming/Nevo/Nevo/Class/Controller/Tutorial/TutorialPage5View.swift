//
//  TutorialPage1View.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 9/2/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation

class TutorialPage5View : UIView {
    private var mDelegate:Page5Controller?

    let TITLE_TEXT_FONT:UIFont = UIFont(name:"Raleway-Light", size: 25)!
    let CONTENT_TEXT_FONT:UIFont = UIFont(name:"Raleway-Light", size: 18)!
    let TEXT_FONT:UIFont = UIFont(name:"Raleway-Light", size: 25)!

    let BACK_BUTTON_FONT:UIFont = UIFont(name:"Raleway-Light", size: 20)!

    let BACKGROUND_COLOR:UIColor = UIColor(red: 244.0/255.0, green: 242.0/255.0, blue: 241.0/255.0, alpha: 1)

    private var mBackButton:UIButton?

    private var mBluetoothHint:Bool = false
    
    init(frame: CGRect, delegate:UIViewController, bluetoothHint:Bool) {
        mBluetoothHint = bluetoothHint
        super.init(frame: frame)
        super.backgroundColor = BACKGROUND_COLOR
        if let callBackDelgate = delegate as? Page5Controller {

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

        let titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, self.frame.size.width, 100))
        titleLabel.center = CGPointMake(self.frame.size.width/2.0, 100)
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        titleLabel.font = TITLE_TEXT_FONT
        titleLabel.text = NSLocalizedString("disconnection_title",comment:"")
        self.addSubview(titleLabel)

        let statesImage:UIImageView = UIImageView(image: UIImage(named: String("disconnection" as NSString)))
        statesImage.frame = CGRectMake(0, 0, self.frame.size.width, 230)
        statesImage.center=CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0-30)
        statesImage.contentMode = UIViewContentMode.ScaleAspectFit
        statesImage.backgroundColor = UIColor.clearColor()
        self.addSubview(statesImage)

        let contentLabel:UILabel = UILabel(frame: CGRectMake(5, statesImage.frame.origin.y+statesImage.frame.size.height,statesImage.frame.size.width-10, 130))
        contentLabel.textAlignment = NSTextAlignment.Center
        contentLabel.numberOfLines = 0
        contentLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        contentLabel.font = CONTENT_TEXT_FONT
        contentLabel.text = NSLocalizedString("disconnection_message",comment:"")
        self.addSubview(contentLabel)

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
        self.addSubview(nextButton)

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