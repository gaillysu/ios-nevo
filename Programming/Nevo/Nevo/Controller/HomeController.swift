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

class HomeController: UIViewController {
    
    @IBOutlet var homeView: HomeView!


    override func viewDidLoad() {
        super.viewDidLoad()

        homeView.bulidHomeView()

        let timer:NSTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector:"timerAction:", userInfo: nil, repeats: true);

        self.performSegueWithIdentifier("Home_Tutorial", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func timerAction(NSTimer) {
        homeView.clockTimerView.currentTimer()
    }

    @IBAction func managerButtonAction(sender: UIButton) {
        //TODO remove
        //if sender == homeView.connectButton {
            NSLog("connectButton");
            
            SyncController(controller: self).sendRawPacket()
           
        //}
    }
}
