//
//  StepGoalSetingController.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/11.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class StepGoalSetingController: UIViewController, ConnectionControllerDelegate {

    @IBOutlet var stepGoalView: StepGoalSetingView!

    override func viewDidLoad() {
        super.viewDidLoad()

        stepGoalView.bulidStepGoalView(self)
        
        ConnectionControllerImpl.sharedInstance.setDelegate(self)
        
        checkConnection()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - ButtonAction
    func controllManager(sender:UIButton) {
        if sender.isEqual(stepGoalView.goalButton) {
            NSLog("goalButton")
            stepGoalView.initPickerView()
        }

        if sender.isEqual(stepGoalView.modarateButton) {
            NSLog("modarateButton")
            stepGoalView.cleanButtonControlState()
            stepGoalView.modarateButton.selected = true
            stepGoalView.goalButton.setTitle("7000", forState: UIControlState.Normal)
        }

        if sender.isEqual(stepGoalView.intensiveButton) {
            NSLog("intensiveButton")
            stepGoalView.cleanButtonControlState()
            stepGoalView.intensiveButton.selected = true
            stepGoalView.goalButton.setTitle("10000", forState: UIControlState.Normal)

        }

        if sender.isEqual(stepGoalView.sportiveButton) {
            NSLog("sportiveButton")
            stepGoalView.cleanButtonControlState()
            stepGoalView.sportiveButton.selected = true
            stepGoalView.goalButton.setTitle("20000", forState: UIControlState.Normal)
        }

        if sender.isEqual(stepGoalView.customButton) {
            NSLog("customButton")
            //stepGoalView.cleanButtonControlState()
            //stepGoalView.customButton.selected = true
        }
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
        
        //Maybe we just got disconnected, let's check
        
        checkConnection()
        
    }
    
    
    
    /**
    
    Checks if any device is currently connected
    
    */
    
    func checkConnection() {
        
        
        
        if !ConnectionControllerImpl.sharedInstance.isConnected() {
            
            //We are currently not connected
            
            
            
            //TODO by Cloud Display the not connected screen instead of this popup
            
            var alert:UIAlertView = UIAlertView(title:"Alert", message:"This is an example alert!", delegate:self, cancelButtonTitle:"Hide")
            
            
            
            alert.show();
            
        }
        
        
    }

}
