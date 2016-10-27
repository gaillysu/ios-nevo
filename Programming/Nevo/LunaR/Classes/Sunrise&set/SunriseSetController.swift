//
//  Sunrise&set.swift
//  Nevo
//
//  Created by Quentin on 25/10/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import Foundation
import Timepiece

class SunriseSetController: PublicClassController {
    lazy var newView:SunriseSetView = {
        let newView = Bundle.main.loadNibNamed("SunriseSetView", owner: nil, options: nil)?.first as! SunriseSetView
        newView.frame = UIScreen.main.bounds
        return newView
    }()
    
    override func viewDidLoad() {
        view.addSubview(newView)
        
        let now:Date = Date()
        let cal:Calendar = Calendar.current
        let dd:DateComponents = (cal as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day ,NSCalendar.Unit.hour, NSCalendar.Unit.minute, NSCalendar.Unit.second,], from: now);
        
        /// Usages
        newView.setDialTime(dateComponents: dd)
        
        newView.setTime(weekday: NSLocalizedString("Yesterday", comment: ""), date: Date.yesterday().stringFromFormat("EEEE,dd,MMMM,yyyy"))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        newView.worldClocksReload()
    }
}
