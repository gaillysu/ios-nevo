//
//  HomeView.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation
import UIkit

class HomeView: UIView {
     @IBOutlet var connectButton: UIButton!
    
    //Put all UI operation HomeView inside
    let clockTimerView = ClockView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width-60, UIScreen.mainScreen().bounds.width-60));//init "ClockView" ,Use the code relative layout

    func bulidHomeView() {

        connectButton.setTitle(NSLocalizedString("scanAndConnect", comment:"scanAndConnect button title"), forState: UIControlState.Normal)

        clockTimerView.borderColor = UIColor(red: 188/255.0, green: 187/255.0, blue: 185/255, alpha: 1.0);
        clockTimerView.borderWidth = 4.0;
        clockTimerView.currentTimer()
        self.addSubview(clockTimerView)
        clockTimerView.center = CGPointMake(self.frame.width/2.0, self.frame.height/2.0-80);//Using the center property determines the location of the ClockView
    }
    
}