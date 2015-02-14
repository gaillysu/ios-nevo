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
    
    //Put all UI operation HomeView inside
    let clockTimerView = ClockView(frame:CGRectMake(0, 0, UIScreen.mainScreen().bounds.width-60, UIScreen.mainScreen().bounds.width-60), hourImage:  UIImage(named: "clockViewHour")!, minuteImage: UIImage(named: "clockViewMinute")!, dialImage: UIImage(named: "clockView600")!);//init "ClockView" ,Use the code relative layout

    func bulidHomeView() {

        clockTimerView.currentTimer()
        self.addSubview(clockTimerView)
        clockTimerView.center = CGPointMake(self.frame.width/2.0, self.frame.height/2.0-80);//Using the center property determines the location of the ClockView
    }
    
}