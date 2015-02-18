//
//  StepGoalSetingController.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/11.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class StepGoalSetingController: UIViewController, SyncControllerDelegate {

    @IBOutlet var stepGoalView: StepGoalSetingView!
    
    private var mSyncController:SyncController?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        mSyncController = SyncController(controller: self, forceScan:false, delegate:self)
        
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 120, 30))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = NSLocalizedString("stepGoalTitle", comment: "")
        titleLabel.font = UIFont.systemFontOfSize(25)
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel

        stepGoalView.bulidStepGoalView(self)

    }
    
    override func viewDidAppear(animated: Bool) {
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
            stepGoalView.setNumberOfStepsGoal(7000)
            sendRequestGoal(GoalIntensity.LOW,value: stepGoalView.getNumberOfStepsGoal())
        }

        if sender.isEqual(stepGoalView.intensiveButton) {
            NSLog("intensiveButton")
            stepGoalView.cleanButtonControlState()
            stepGoalView.intensiveButton.selected = true
            stepGoalView.setNumberOfStepsGoal(10000)
            sendRequestGoal(GoalIntensity.MEDIUM,value: stepGoalView.getNumberOfStepsGoal())
        }

        if sender.isEqual(stepGoalView.sportiveButton) {
            NSLog("sportiveButton")
            stepGoalView.cleanButtonControlState()
            stepGoalView.sportiveButton.selected = true
            stepGoalView.setNumberOfStepsGoal(20000)
            sendRequestGoal(GoalIntensity.HIGH,value: stepGoalView.getNumberOfStepsGoal())
        }


        if sender.isEqual(stepGoalView.getNoConnectScanButton()?) {
            NSLog("noConnectScanButton")
            reconnect()
        }

        if sender.isEqual(stepGoalView.getEnterButton()?) {

            sendRequestGoal(GoalIntensity.LOW,value: stepGoalView.getNumberOfStepsGoal())

        }
    }
    
    func sendRequestGoal(GoalIntensity, value:Int) {
        
        var request = SetGoalRequest(goal: Goal.GoalFactory.newGoal("NUMBER_OF_STEPS",intensity: GoalIntensity.LOW,data: stepGoalView.getNumberOfStepsGoal()))
        
        ConnectionControllerImpl.sharedInstance.sendRequest(request)
    }
    
    func reconnect() {
        if let noConnectImage = stepGoalView.getNoConnectImage() {
            stepGoalView.buttonAnimation(noConnectImage)
        }
        mSyncController?.connect()
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
        
        
        
        if mSyncController != nil && !(mSyncController!.isConnected()) {
            
            //We are currently not connected
            stepGoalView.bulibNoConnectView()
            reconnect()
        } else {

            stepGoalView.endConnectRemoveView()
        }
        
        
    }

}
