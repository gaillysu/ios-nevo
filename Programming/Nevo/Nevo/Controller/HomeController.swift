//
//  HomeController.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation
import UIKit

/*
Controller of the Home Screen,
it should handle very little, only the initialisation of the different Views and the Sync Controller
*/

class HomeController: UIViewController, SyncControllerDelegate{
    
    @IBOutlet var homeView: HomeView!
    private var mPacketsbuffer:[NSData]=[]
    private var sync:SyncController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        homeView.bulidHomeView(self.navigationItem)

        let timer:NSTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector:"timerAction:", userInfo: nil, repeats: true);
        
    }

    override func viewDidAppear(animated: Bool) {
        
        if !ConnectionControllerImpl.sharedInstance.hasSavedAddress() {
            
            NSLog("No saved device, let's launch the tutorial")
            
            self.performSegueWithIdentifier("Home_Tutorial", sender: self)
            
        } else {
            if(sync == nil)
            {
               NSLog("We have a saved address, no need to go through the tutorial")
               sync  = SyncController.sharedInstance
               sync?.startConnect(false, delegate: self)
            }
            NSLog("We getGoal in home screen")
            mPacketsbuffer = []
            SyncController.sharedInstance.getGoal()
        }

        
        //TEST this is for test
//        var tapAction = UITapGestureRecognizer(target: self, action: "gotoProfileScreen")
//        homeView.addGestureRecognizer(tapAction)
        //end TEST
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func timerAction(NSTimer) {
        homeView.getClockTimerView().currentTimer()
    }

    
    /**
    goto profileTest screen.  just for test
    */
    func gotoProfileScreen(){
        self.performSegueWithIdentifier("Home_profile", sender: self)
    }
    
    /**
    
    See SyncControllerDelegate
    
    */
    func packetReceived(packet:RawPacket) {
        
        mPacketsbuffer.append(packet.getRawData())
        
        if(NSData2Bytes(packet.getRawData())[0] == 0xFF)
        {
                if NSData2Bytes(packet.getRawData())[1] == 0x26
                {
                var dailySteps:Int = Int(NSData2Bytes(mPacketsbuffer[0])[2] )
                dailySteps =  dailySteps + Int(NSData2Bytes(mPacketsbuffer[0])[3] )<<8
                dailySteps =  dailySteps + Int(NSData2Bytes(mPacketsbuffer[0])[4] )<<16
                dailySteps =  dailySteps + Int(NSData2Bytes(mPacketsbuffer[0])[5] )<<24
            
                var dailyStepGoal:Int = Int(NSData2Bytes(mPacketsbuffer[0])[6] )
                dailyStepGoal =  dailyStepGoal + Int(NSData2Bytes(mPacketsbuffer[0])[7] )<<8
                dailyStepGoal =  dailyStepGoal + Int(NSData2Bytes(mPacketsbuffer[0])[8] )<<16
                dailyStepGoal =  dailyStepGoal + Int(NSData2Bytes(mPacketsbuffer[0])[9] )<<24
            
                let numberOfSteps = NSUserDefaults.standardUserDefaults().objectForKey("NUMBER_OF_STEPS_GOAL_KEY") as? Int
            
                var percent :Float = Float(dailySteps)/Float(dailyStepGoal)
            
                NSLog("get Daily Steps is: \(dailySteps), getDaily Goal is: \(dailyStepGoal), saved Goal is:\(numberOfSteps),percent is: \(percent)")
            
                homeView.setProgress(percent)
                }
                //reset buffer for every end-packet
                mPacketsbuffer = []
        }        
    }
    func connectionStateChanged(isConnected: Bool) {
        //NOTHING to do here
    }
}
