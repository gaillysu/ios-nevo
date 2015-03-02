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
        
    }
    func connectionStateChanged(isConnected: Bool) {
        //Do nothing
    }
}
