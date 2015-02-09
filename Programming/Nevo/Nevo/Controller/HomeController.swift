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
    @IBOutlet var connectButton: UIButton!
    @IBOutlet var homeView: HomeView!
    var syncController : SyncController?

    override func viewDidLoad() {
        super.viewDidLoad()
        homeView.bulidHomeView()

        let timer:NSTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector:"timerAction:", userInfo: nil, repeats: true);

        let tutorialCont = TutorialController()
        self.presentViewController(tutorialCont, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func timerAction(NSTimer) {
        homeView.clockTimerView.currentTimer()
    }

    @IBAction func managerButtonAction(sender: UIButton) {
        //TODO by Hugo remove
        if sender == connectButton {
            NSLog("connectButton");
            
            syncController?.sendRawPacket()
           
        }
    }
}
