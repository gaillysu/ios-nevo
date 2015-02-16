//
//  TutorialController.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/2.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIkit

class TutorialController: UIViewController {
    var mTutorialView: TutorialView?
    var sync:SyncController?
    //This controller is not displayed on the storyboard

    override func viewDidLoad() {
        super.viewDidLoad()

        //init TutorialView
        mTutorialView = TutorialView(frame: CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height), delegate: self)
        self.view.addSubview(mTutorialView!)

        sync = SyncController(controller: self, forceScan:true)
        

    }
    
    func scanButtonPressed(sender:UIButton) {
        SyncController(controller: self, forceScan:true)
    }
    
    /**
    See ConnectionControllerDelegate
    */
    func packetReceived(RawPacket) {
        //Do nothing
    }
    
    /**
    See ConnectionControllerDelegate
    */
    func connectionStateChanged(isConnected : Bool) {
        //TODO by Hugo
        //When we receive a connection, let's start the app automatically
    }


}
