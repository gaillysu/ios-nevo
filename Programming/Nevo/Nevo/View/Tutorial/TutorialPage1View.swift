//
//  TutorialPage1View.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 9/2/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation
import UIkit

class TutorialPage1View : UIView {
    var mDelegate:Page1Controller?

    let TEXT_FONT:UIFont = UIFont(name:"Raleway-Light", size: 20)!
    
    init(frame: CGRect, delegate:UIViewController) {
        super.init(frame: frame)
        super.backgroundColor = UIColor.whiteColor()
        if let callBackDelgate = delegate as? Page1Controller {

            mDelegate = callBackDelgate
        }
        buildTutorialPage()
        
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        buildTutorialPage()
    }
    
    func buildTutorialPage() {
        
        let guideImage:UIImageView = UIImageView(image: UIImage(named: String("stupe1" as NSString)))
        guideImage.frame = CGRectMake(0, 0, self.frame.size.width-70, 100)
        guideImage.center = CGPointMake(self.frame.size.width/2.0, 130)
        guideImage.contentMode = UIViewContentMode.ScaleAspectFit
        guideImage.userInteractionEnabled = true;
        guideImage.backgroundColor = UIColor.clearColor()
        self.addSubview(guideImage)

        let titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, guideImage.frame.size.width, 50))
        titleLabel.center = CGPointMake(self.frame.size.width/2.0, guideImage.frame.origin.y+guideImage.frame.size.height+70)
        titleLabel.textAlignment = NSTextAlignment.Left
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = NSLineBreakMode.ByCharWrapping
        titleLabel.font = TEXT_FONT
        titleLabel.text = NSLocalizedString("Enable Bluetooth on your phone",comment:"lable string")
        self.addSubview(titleLabel)


        let statesImage:UIImageView = UIImageView(image: UIImage(named: String("Bluetoothoff" as NSString)))
        statesImage.frame = CGRectMake(0, 0, self.frame.size.width-70, 100)
        statesImage.center = CGPointMake(self.frame.size.width/2.0, 400)
        statesImage.contentMode = UIViewContentMode.ScaleAspectFit
        statesImage.backgroundColor = UIColor.clearColor()
        self.addSubview(statesImage)

        let nextButton:UIButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        nextButton.frame = CGRectMake(0, 0, 120, 50)
        nextButton.setTitle(NSLocalizedString("Next",comment:"button title string"), forState: UIControlState.Normal)
        nextButton.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height-100)
        nextButton.addTarget(self, action: "ButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(nextButton)
    }

    func ButtonAction(sender:UIButton){
        mDelegate?.nextButtonAction(sender)
    }
}