//
//  TutorialPage1View.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 9/2/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation

class TutorialPage7View : UIView {
    private var mDelegate:Page7Controller?

    let TITLE_TEXT_FONT:UIFont = AppTheme.FONT_RALEWAY_LIGHT(mSize: 23)
    let CONTENT_TEXT_FONT:UIFont = AppTheme.FONT_RALEWAY_LIGHT(mSize: 17)
    let TEXT_FONT:UIFont = AppTheme.FONT_RALEWAY_LIGHT(mSize: 25)

    let BACK_BUTTON_FONT:UIFont = AppTheme.FONT_RALEWAY_LIGHT(mSize: 20)

    let BACKGROUND_COLOR:UIColor = UIColor(red: 244.0/255.0, green: 242.0/255.0, blue: 241.0/255.0, alpha: 1)

    private var mBackButton:UIButton?

    private var mBluetoothHint:Bool = false
    
    init(frame: CGRect, delegate:UIViewController, bluetoothHint:Bool) {
        mBluetoothHint = bluetoothHint
        super.init(frame: frame)
        super.backgroundColor = BACKGROUND_COLOR
        if let callBackDelgate = delegate as? Page7Controller {

            mDelegate = callBackDelgate
        }
        buildTutorialPage()
        
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        buildTutorialPage()
    }
    
    func buildTutorialPage() {


        let titleLabel:UILabel = UILabel(frame: CGRectMake(0, 10, 200, 58))
        titleLabel.center = CGPointMake(self.frame.size.width/2.0, 100)
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = NSLineBreakMode.ByCharWrapping
        titleLabel.font = AppTheme.FONT_RALEWAY_BOLD(mSize: 23)
        titleLabel.text = NSLocalizedString("SLEEP_TITLE",comment:"")
        self.addSubview(titleLabel)
        titleLabel.frame = CGRectMake(titleLabel.frame.origin.x, 10,200, 58.0)

        let statesImage:UIImageView = UIImageView(image: UIImage(named: String("sleeptracking_tutorial" as NSString)))
        statesImage.center=CGPointMake(statesImage.frame.size.width/2.0, self.frame.size.height/2.0-30)
        statesImage.contentMode = UIViewContentMode.ScaleAspectFit
        statesImage.backgroundColor = UIColor.clearColor()
        self.addSubview(statesImage)

        let contentLabel:UILabel = UILabel(frame: CGRectMake(statesImage.frame.size.width, statesImage.frame.origin.y,self.frame.size.width-statesImage.frame.size.width-10, statesImage.frame.size.height))
        contentLabel.textAlignment = NSTextAlignment.Center
        contentLabel.numberOfLines = 0
        contentLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        contentLabel.font = CONTENT_TEXT_FONT
        contentLabel.text = NSLocalizedString("sleep_description",comment:"")
        self.addSubview(contentLabel)

        let nextButton:UIButton = UIButton(type:UIButtonType.System)
        nextButton.frame = CGRectMake(0, 0, 58, 58)
        nextButton.setImage(UIImage(named: "cancelicon"), forState: UIControlState.Normal)
        nextButton.setImage(UIImage(named: "cancelicon"), forState: UIControlState.Highlighted)
        nextButton.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        //nextButton.setTitle(NSLocalizedString("Finish",comment:"button title string"), forState: UIControlState.Normal)
        nextButton.titleLabel?.font = TEXT_FONT
        nextButton.setTitleColor(AppTheme.NEVO_SOLAR_YELLOW(), forState: UIControlState.Normal)
        if AppTheme.GET_IS_iPhone5S() {
            nextButton.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height-25)
        }else {
            nextButton.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height-50)
        }
        nextButton.addTarget(self, action: "ButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(nextButton)
        mBackButton = nextButton

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