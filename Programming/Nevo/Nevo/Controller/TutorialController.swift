//
//  TutorialController.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/2.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIkit

class TutorialController: UIViewController, SyncControllerDelegate {
    private var mTutorialView: TutorialView?
    private var mSync:SyncController?
    //This controller is not displayed on the storyboard

    override func viewDidLoad() {
        super.viewDidLoad()

        //init TutorialView
        mTutorialView = TutorialView(frame: CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height), delegate: self)
        self.view.addSubview(mTutorialView!)
        mSync    = SyncController.sharedInstance
        mSync?.startConnect(true, delegate: self)
    }
    
    func scanButtonPressed(sender:UIButton) {
        mSync?.startConnect(true, delegate: self)
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
