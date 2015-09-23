//
//  Page3Controller.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/10.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class Page4Controller: UIViewController,ButtonActionCallBack,SyncControllerDelegate {

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

        if sender.isEqual(pagesView.getConnectButton()) {

            let isConnectedBool:Bool = ConnectionControllerImpl.sharedInstance.isConnected()
            if(isConnectedBool) {
                pagesView.connectSuccessClean()
            } else {
                SyncController.sharedInstance.startConnect(true, delegate: self)
            }
        } else if sender.isEqual(pagesView.getBackButton()) {
            self.navigationController?.popViewControllerAnimated(true)
        }else {
            //Next Button Action
            //self.dismissViewControllerAnimated(true, completion: nil);
            let page5cont = Page5Controller()
            self.navigationController?.pushViewController(page5cont, animated: true)
        }

    }

    func connectionStateChanged(isConnected : Bool){

        if isConnected {
            //connect Success clear
            pagesView.connectSuccessClean()
        }
    }

    func packetReceived(packet: NevoPacket) {

    }

    func receivedRSSIValue(number:NSNumber){

    }
}
