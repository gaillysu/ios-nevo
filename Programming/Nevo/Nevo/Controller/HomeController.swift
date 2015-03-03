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
    override func viewDidLoad() {
        super.viewDidLoad()

        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 120, 30))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = NSLocalizedString("homeTitle", comment: "")
        titleLabel.font = UIFont.systemFontOfSize(25)
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel

        homeView.bulidHomeView()

        let timer:NSTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector:"timerAction:", userInfo: nil, repeats: true);
        
        if !ConnectionControllerImpl.sharedInstance.hasSavedAddress() {
            
            NSLog("No saved device, let's launch the tutorial")
            
            self.performSegueWithIdentifier("Home_Tutorial", sender: self)
            
        } else {
            NSLog("We have a saved address, no need to go through the tutorial")
            SyncController.sharedInstance.startConnect(false, delegate: self)
        }
        
    }

    override func viewDidAppear(animated: Bool) {
        NSLog("We getGoal in home screen")
        mPacketsbuffer = []
        SyncController.sharedInstance.getGoal()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func timerAction(NSTimer) {
        homeView.getClockTimerView().currentTimer()
    }

    @IBAction func managerButtonAction(sender: UIButton) {
        //TODO remove
        //if sender == homeView.connectButton {
            NSLog("connectButton");
            
         //   SyncController(controller: self).sendRawPacket()
           
        //}
    }
    
    /**
    
    See SyncControllerDelegate
    
    */
    func packetReceived(packet:RawPacket) {
        
        mPacketsbuffer.append(packet.getRawData())
        
        if(NSData2Bytes(packet.getRawData())[0] == 0xFF
            && NSData2Bytes(packet.getRawData())[1] == 0x26 )
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
            
                homeView.mProgressView.progress = percent
            
                mPacketsbuffer = []
        }        
    }
    func connectionStateChanged(isConnected: Bool) {
        //get Goal
        if isConnected
        {
            var dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                self.mPacketsbuffer = []
                SyncController.sharedInstance.getGoal()
            })
        }
    }
}
