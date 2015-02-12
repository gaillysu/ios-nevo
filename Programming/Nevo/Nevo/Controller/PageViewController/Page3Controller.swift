//
//  Page3Controller.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/10.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class Page3Controller: UIViewController,ButtonActionCallBack,ConnectionControllerDelegate {

    var pagesView:TutorialScanPageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        pagesView = TutorialScanPageView(frame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height),delegate:self)
        self.view .addSubview(pagesView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    Button Action CallBack
    */
    func nextButtonAction(sender:UIButton){

        if sender.isEqual(pagesView.connectButton) {

            let isConnectedBool:Bool = ConnectionControllerImpl.sharedInstance.isConnected()
            if(isConnectedBool) {
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                ConnectionControllerImpl.sharedInstance.connect()
                ConnectionControllerImpl.sharedInstance.setDelegate( self)
            }
        } else {
            //Finish Button Action
            self.dismissViewControllerAnimated(true, completion: nil);
        }

    }

    func connectionStateChanged(isConnected : Bool){

        if isConnected {
            //connect Success clear
            pagesView.connectSuccessClean()
        }
    }

    func packetReceived(RawPacket) {

    }
}
