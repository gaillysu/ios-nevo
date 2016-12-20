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

class HomeClockController: PublicClassController {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        navigationItem.title = NSLocalizedString("Home City", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshClockView()
    }
}
 
extension HomeClockController {
    func setUpView() {
        if let city = city {
            cityNameLabel.text = "\(city.name), \(city.country)"
            
            calculateHomeTime()
            
            todayLabel.text = isPastOrComing(date: homeTime)
            dateLabel.text = homeTime.stringFromFormat(formaterString)
            return
        } else {
            todayLabel.text = NSLocalizedString("today", comment: "")
            cityNameLabel.text = "Shenzhen, China"
            dateLabel.text = Date().stringFromFormat(formaterString)
            
            let addCityController: AddWorldClockViewController = AddWorldClockViewController()
            addCityController.didSeletedCityDelegate = self
            addCityController.hidesBottomBarWhenPushed = true
            let navigationController: UINavigationController = UINavigationController(rootViewController: addCityController)
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    func refreshClockView() {
        for v in self.dialView.subviews {
            if v is ClockView {
                v.removeFromSuperview()
            }
        }
        
        let hourImage = AppTheme.GET_RESOURCES_IMAGE("wacth_hour")
        let minuteImage = AppTheme.GET_RESOURCES_IMAGE("wacth_mint")
        let dialImage = AppTheme.GET_RESOURCES_IMAGE("wacth_dial")
        
        clockView = ClockView(frame: CGRect(x: 0, y: 0, width: dialView.bounds.width, height: dialView.bounds.width), hourImage: hourImage, minuteImage: minuteImage, dialImage: dialImage)
        
        setDialTime(hour: homeTime.hour, minute: homeTime.minute, seconds: homeTime.second)
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

extension HomeClockController: WorldClockDidSelectedDelegate {
    func didSelectedLocalTimeZone(_ cityId:Int) {
//        if AppDelegate.getAppDelegate().isConnected() {
//            let setWordClock:SetWorldClockRequest = SetWorldClockRequest(offset: homeTime.hour)
//            AppDelegate.getAppDelegate().sendRequest(setWordClock)
//        }
    }
}
