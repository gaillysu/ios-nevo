//
//  HomeClockController.swift
//  Nevo
//
//  Created by Quentin on 19/12/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import Timepiece
import RealmSwift

class HomeClockController: UIViewController {

    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var dialView: UIView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var city: City? {
        return HomeClockUtil.shared.getHomeCityWithSelectedFlag()
    }
    
    var clockView: ClockView?
    
    var homeTime = Date()
    let formaterString = "d MMM, yyyy"
    
    lazy var noCityLabel: UILabel = {
        self.view.addSubview($0)
        
        $0.frame = UIScreen.main.bounds
        $0.font = UIFont(name: "Helvetica-Light", size: 25.0)
        $0.textColor = UIColor.white
        $0.backgroundColor = UIColor.getLightBaseColor()
        $0.text = NSLocalizedString("none_homecity", comment: "")
        $0.textAlignment = .center
        $0.lineBreakMode = .byWordWrapping
        $0.numberOfLines = 10
        
        $0.isHidden = false
        
        return $0
    }(UILabel())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AppDelegate.getAppDelegate().startConnect(false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpView()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshClockView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
 
extension HomeClockController {
    func setUpView() {
        navigationItem.title = NSLocalizedString("Home City", comment: "")
        todayLabel.text = NSLocalizedString("home_time2", comment: "")
        
        if let city = city {
            noCityLabel.isHidden = true
            
            let cityNameValue:String = "\(city.name), \(city.country)"
            if let name = cityNameLabel.text {
                if name != cityNameValue {
                    if let city = HomeClockUtil.shared.getHomeCityWithSelectedFlag(), let timezone = HomeClockUtil.shared.getTimezoneWithCity(city: city) {
                        let cityZone = timezone.gmtTimeOffset
                        let localZone = Date.getLocalOffSet()
                        let offset = 23-abs((localZone-cityZone)/60)
                        let setWordClock:SetWorldClockRequest = SetWorldClockRequest(offset: offset)
                        AppDelegate.getAppDelegate().sendRequest(setWordClock)
                    }else{
                        let setWordClock:SetWorldClockRequest = SetWorldClockRequest(offset: 0)
                        AppDelegate.getAppDelegate().sendRequest(setWordClock)
                    }

                }
            }
            cityNameLabel.text = cityNameValue
            
            calculateHomeTime()
            
            dateLabel.text = isPastOrComing(date: homeTime) + "" + homeTime.stringFromFormat(formaterString)
            return
        } else {
            noCityLabel.isHidden = false
        }
    }
    
    func refreshClockView() {
        for v in dialView.subviews {
            if v is ClockView {
                v.removeFromSuperview()
            }
        }
        
        let hourImage = AppTheme.GET_RESOURCES_IMAGE("wacth_hour")
        let minuteImage = AppTheme.GET_RESOURCES_IMAGE("wacth_mint")
        let dialImage = AppTheme.GET_RESOURCES_IMAGE("wacth_dial")
        
        let clockWidth = dialView.frame.height
        
        clockView = ClockView(frame: CGRect(x: 0, y: 0, width: clockWidth, height: clockWidth), hourImage: hourImage, minuteImage: minuteImage, dialImage: dialImage)
        setDialTime(hour: homeTime.hour, minute: homeTime.minute, seconds: homeTime.second)
        
        clockView?.center.x = dialView.frame.width / 2.0
        
        dialView.addSubview(clockView!)
    }
    
    func setDialTime(hour: Int,minute: Int,seconds: Int) {
        clockView?.setWorldTime(hour: hour,minute: minute,seconds: seconds)
    }
}

extension HomeClockController {
    func isPastOrComing(date: Date) -> String {
        if isSameDay(lhs: Date(), rhs: date){
            return NSLocalizedString("today", comment: "")
        }
        
        if isSameDay(lhs: Date.yesterday(), rhs: date) {
            return NSLocalizedString("Yesterday", comment: "")
        }
        
        if isSameDay(lhs: Date.tomorrow(), rhs: date) {
            return NSLocalizedString("tomorrow", comment: "")
        }
        
        return "unknown date"
    }
    
    func isSameDay(lhs: Date, rhs: Date) -> Bool {
        if lhs.year == rhs.year && lhs.month == rhs.month && lhs.day == rhs.day {
            return true
        } else {
            return false
        }
    }
    
    func calculateHomeTime() {
        /// self's city must be non-nil now
        if let timezone = HomeClockUtil.shared.getTimezoneWithCity(city: city!) {
            let gmtOffset = timezone.gmtTimeOffset * 60 // Second as unit
            homeTime = Date.convertGMTToLocalDateFormat(gmtOffset)
        }
    }
}

