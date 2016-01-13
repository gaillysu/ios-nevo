//
//  PageViewController.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/10.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit


class Page2Controller: UIViewController,ButtonActionCallBack {

    var mBluetoothTutorialView:TutorialPage2View?

    override func viewDidLoad() {
        super.viewDidLoad()

        //TODO Displays the Page slide
        //Array represents the display of the page

        mBluetoothTutorialView = TutorialPage2View(frame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height),delegate:self,bluetoothHint:AppDelegate.getAppDelegate().getMconnectionController().isBluetoothEnabled())
        self.view.addSubview(mBluetoothTutorialView!)
        
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector:Selector("checkBluetoothEnabled"), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
      Button Action CallBack
    */
    func nextButtonAction(sender:UIButton){

         AppTheme.DLog("CallBack Success")
        if sender.isEqual(mBluetoothTutorialView?.getBackButton()) {
            self.navigationController?.popViewControllerAnimated(true)
        }else{
            let page3controller = Page3Controller()
            self.navigationController?.pushViewController(page3controller, animated: true)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func checkBluetoothEnabled() {
        
        let btEnabled = AppDelegate.getAppDelegate().getMconnectionController().isBluetoothEnabled()
        
        if( mBluetoothTutorialView?.getBluetoothHint() != btEnabled ) {
            AppTheme.DLog("BT status changed, changin UI. New status : \(btEnabled)")
            
            mBluetoothTutorialView?.removeFromSuperview()
            
            mBluetoothTutorialView = TutorialPage2View(frame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height),delegate:self,bluetoothHint:AppDelegate.getAppDelegate().getMconnectionController().isBluetoothEnabled())
            self.view .addSubview(mBluetoothTutorialView!)
            
        }
        
    }

}