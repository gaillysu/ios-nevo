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

        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 120, 30))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "Step"
        titleLabel.font = UIFont.systemFontOfSize(25)
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel

        stepGoalView.bulidStepGoalView(self)

    }
    
    override func viewDidAppear(animated: Bool) {
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
            stepGoalView.mData = 7000
            ConnectionControllerImpl.sharedInstance.sendRequest(SetGoalRequest(goal: Goal.GoalFactory.newGoal("NUMBER_OF_STEPS",intensity: GoalIntensity.LOW,data: stepGoalView.mData)))
        }

        if sender.isEqual(stepGoalView.intensiveButton) {
            NSLog("intensiveButton")
            stepGoalView.cleanButtonControlState()
            stepGoalView.intensiveButton.selected = true
            stepGoalView.goalButton.setTitle("10000", forState: UIControlState.Normal)
            stepGoalView.mData = 10000
            ConnectionControllerImpl.sharedInstance.sendRequest(SetGoalRequest(goal: Goal.GoalFactory.newGoal("NUMBER_OF_STEPS",intensity: GoalIntensity.MEDIUM,data: stepGoalView.mData)))
        }

        if sender.isEqual(stepGoalView.sportiveButton) {
            NSLog("sportiveButton")
            stepGoalView.cleanButtonControlState()
            stepGoalView.sportiveButton.selected = true
            stepGoalView.goalButton.setTitle("20000", forState: UIControlState.Normal)
            stepGoalView.mData = 20000
            ConnectionControllerImpl.sharedInstance.sendRequest(SetGoalRequest(goal: Goal.GoalFactory.newGoal("NUMBER_OF_STEPS",intensity: GoalIntensity.HIGH,data: stepGoalView.mData)))
        }

        if sender.isEqual(stepGoalView.customButton) {
            NSLog("customButton")
            //stepGoalView.cleanButtonControlState()
            //stepGoalView.customButton.selected = true
            
        }

        if sender.isEqual(stepGoalView.noConnectScanButton) {
            NSLog("noConnectScanButton")
            stepGoalView.buttonAnimation(stepGoalView.noConnectScanButton)
            ConnectionControllerImpl.sharedInstance.connect()
        }

        if sender.isEqual(stepGoalView.enterButton) {
            ConnectionControllerImpl.sharedInstance.sendRequest(SetGoalRequest(goal: Goal.GoalFactory.newGoal("NUMBER_OF_STEPS",intensity: GoalIntensity.LOW,data: stepGoalView.mData)))
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
            stepGoalView.bulibNoConnectView()
            
        } else {

            stepGoalView.endConnectRemoveView()
            //TODO by Cloud dismiss the popup
        }
        
        
    }

}
