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

let clockTimerView = ClockView(frame: CGRectMake(0, 0, 300, 300))
class HomeController: UIViewController {
    @IBOutlet var clockViewBackground: UIView!
    @IBOutlet var connectButton: UIButton!
    @IBOutlet var stopScan: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        clockTimerView.frame = CGRectMake(0, 0, self.view.frame.width-40, 350)
        clockTimerView.center = CGPointMake(clockViewBackground.frame.width/2.0, clockViewBackground.frame.height/2.0)
        clockTimerView.title = "Nevo"
        clockTimerView.borderColor = UIColor(red: 0.22, green: 0.78, blue: 0.22, alpha: 1.0);
        clockTimerView.borderWidth = 4.0;
        clockTimerView.currentTimer()
        clockViewBackground.addSubview(clockTimerView)

        let timer:NSTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector:"timerAction:", userInfo: nil, repeats: true);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func timerAction(NSTimer) {
        clockTimerView.currentTimer()
        //println("timer action")
    }

    @IBAction func managerButtonAction(sender: UIButton) {
        if sender == connectButton {
            NSLog("connectButton");
        }

        if sender == stopScan {
            NSLog("stopScan");
        }
    }
}
