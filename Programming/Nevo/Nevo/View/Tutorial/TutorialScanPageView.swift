//
//  TutorialScanPageView.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 9/2/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation
import UIkit

class TutorialScanPageView : UIView {
    
    var mDelegate:UIViewController?
    
    init(frame: CGRect, delegate:UIViewController) {
        super.init(frame: frame)
        
        mDelegate = delegate
        
        buildTutorialPage()
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        buildTutorialPage()
    }
    
    func buildTutorialPage() {
        
        //page number 2 display startButton
        let startButton:UIButton = UIButton(frame: CGRectMake(100, 100, 100, 50))

        startButton .setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        startButton.titleLabel?.font = UIFont.systemFontOfSize(20)
        startButton.setTitle(NSLocalizedString("Scan", comment:"") , forState: UIControlState.Normal)
        startButton.addTarget(self, action: Selector("ScanAction:"), forControlEvents: UIControlEvents.TouchUpInside)
        startButton.enabled = true
        self.addSubview(startButton)

    }
    
    //Scan button action
    func ScanAction(sender:UIButton){
        NSLog("ScanAction")
        UIView.animateKeyframesWithDuration(0.3, delay: 0, options: UIViewKeyframeAnimationOptions(), animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(0.00, 0.00);
            }) { (Bool) -> Void in
                self.removeFromSuperview();
        }
        //SyncController(controller:self).sendRawPacket();
    }
    
}