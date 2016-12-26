//
//  DashBoardController.swift
//  Nevo
//
//  Created by Quentin on 21/12/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import SnapKit
import Timepiece
import SwiftyTimer

class DashBoardController: UIViewController {
    let dashMargin: CGFloat = 10
    let dashGap: CGFloat = 7
    var dashViewWidth: CGFloat {
        return UIScreen.main.bounds.width - 2 * self.dashMargin
    }
    
    var dashElementWidth: CGFloat {
        return (self.dashViewWidth - 2 * self.dashGap) / 4
    }
    var dashViewHeight: CGFloat {
        return self.dashElementWidth * 2 + self.dashGap
    }
    
    weak var chargingView: DashBoardChargingView?
    weak var sunriseView: DashBoardSunriseView?
    weak var homeClockView: DashBoardHomeClockView?
    weak var sleepHistoryView: DashBoardChargingView?
    weak var centerDashView: UIView?
    
    lazy var dashView: UIView = {
        
        let dashView = UIView()
        self.view.addSubview(dashView)
        
        dashView.snp.makeConstraints { (v) in
            v.leading.equalToSuperview().offset(10)
            v.bottom.equalToSuperview().offset(-30)
            v.width.equalTo(self.dashViewWidth)
            v.height.equalTo(self.dashViewHeight)
        }
        
        return dashView
    }()
    
    lazy var dialView: UIView = {
        
        let dialView = UIView()
        self.view.addSubview(dialView)
        
        dialView.snp.makeConstraints { (v) in
            v.leading.equalToSuperview()
            v.trailing.equalToSuperview()
            v.top.equalToSuperview().offset(40)
            v.bottom.equalTo(self.dashView.snp.top).offset(-40)
        }
        
        return dialView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        Timer.every(30) {
            self.refreshDateForDashView()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        refreshDialView()
    }
}

// MARK: - Setup views
extension DashBoardController {
    
    func setupView() {
        view.backgroundColor = UIColor.getLightBaseColor()
        dashView.backgroundColor = UIColor.clear
        dialView.backgroundColor = UIColor.clear
        
        setupDashView()
    }
    
    func setupDashView() {
        let chargingView = DashBoardChargingView.factory()
        addToDashView(view: chargingView, position: .topLeft)
        self.chargingView = chargingView
        
        let sunriseView = DashBoardSunriseView.factory()
        addToDashView(view: sunriseView, position: .bottomRight)
        self.sunriseView = sunriseView
        
        let homeClockView = DashBoardHomeClockView.factory()
        addToDashView(view: homeClockView, position: .topRight)
        self.homeClockView = homeClockView
        
        let sleepHistoryView = DashBoardChargingView.factory()
        addToDashView(view: sleepHistoryView, position: .bottomLeft)
        self.sleepHistoryView = sleepHistoryView
        sleepHistoryView.imageView.image = UIImage(named: "moon")
        sleepHistoryView.titleLabel.text = NSLocalizedString("inactivity", comment: "")
        sleepHistoryView.contentLabel.text = "7h 0m"
        
        let centerDashView = UIView()
        dashView.addSubview(centerDashView)
        self.centerDashView = centerDashView
        centerDashView.frame = CGRect(x: dashElementWidth + dashGap, y: 0, width: 2 * dashElementWidth, height: dashViewHeight)
        
        
        let scrollView = UIScrollView(frame: centerDashView.bounds)
        centerDashView.addSubview(scrollView)
        
        scrollView.contentSize = CGSize(width: centerDashView.bounds.width, height: centerDashView.bounds.height)
        
        let caloriseView = DashBoardCalorieView.factory()
        scrollView.addSubview(caloriseView)
        caloriseView.frame = centerDashView.bounds
        caloriseView.backgroundColor = UIColor.getGreyColor()
        
        let circleView = MEDCircleView()
        caloriseView.insertSubview(circleView, at: 0)
        circleView.viewColor = UIColor.getGreyColor()
        circleView.frame = CGRect(x: 0, y: 0, width: caloriseView.frame.width - 20, height: caloriseView.frame.width - 20)
        circleView.center = caloriseView.center
        circleView.value = 0.7
    }
}

// MARK: - Refresh data
extension DashBoardController {
    
    func refreshDialView() {
        for view in dialView.subviews {
            if view is ClockView {
                view.removeFromSuperview()
            }
        }
        
        let width = dialView.bounds.height
        let clockView = ClockView(frame:CGRect(x: 0, y: 0, width: width, height: width), hourImage:  UIImage(named: "wacth_hour")!, minuteImage: UIImage(named: "wacth_mint")!, dialImage: UIImage(named: "wacth_dial")!)
        clockView.center.x = dialView.center.x
        
        dialView.addSubview(clockView)
    }
    
    func refreshDateForDashView() {
        
        // TODO: refresh charging status view
        // TODO: refresh sleep history view
        
        /// refersh sunrise
        HomeClockUtil.shared.getLocation { (city) in
            self.sunriseView?.cityLabel.text = city?.name
        }
        let sunriseAndSet = AppDelegate.getAppDelegate().getSunriseAndSunsetTime()
        if let sunrise = sunriseAndSet.sunriseDate, let sunset = sunriseAndSet.sunsetDate {
            let now = Date()
            
            if now < sunrise {
                setSunriseView(view: sunriseView, date: sunrise, riseOrSet: "sunrise")
            } else if now > sunrise && now < sunset {
                setSunriseView(view: sunriseView, date: sunset, riseOrSet: "sunset")
            } else {
                let sunriseAndSet = AppDelegate.getAppDelegate().getSunriseAndSunsetTime(date: Date.tomorrow())
                if let sunrise = sunriseAndSet.sunriseDate {
                    setSunriseView(view: sunriseView, date: sunrise, riseOrSet: "sunrise")
                } else {
                    sunriseView?.imageView.image = UIImage(named: "sunrise")
                    sunriseView?.titleLabel.text = NSLocalizedString("sunrise", comment: "")
                    sunriseView?.timeLabel.text = sunriseAndSet.additionString
                }
            }
        } else {
            sunriseView?.imageView.image = UIImage(named: "sunrise")
            sunriseView?.titleLabel.text = NSLocalizedString("sunrise", comment: "")
            sunriseView?.timeLabel.text = sunriseAndSet.additionString
        }
        
        /// refresh homecity
        if let city = HomeClockUtil.shared.getHomeCityWithSelectedFlag() {
            homeClockView?.cityLabel.text = city.name
            homeClockView?.countryLabel.text = city.country
        }
        if let hometime = HomeClockUtil.shared.getHomeTime() {
            homeClockView?.timeLabel.text = hometime.stringFromFormat("hh:mm a")
        }
    }
}


// MARK: - Private function
extension DashBoardController {
    func addToDashView(view: UIView, position: UIRectCorner) {
        view.backgroundColor = UIColor.getGreyColor()
        
        dashView.addSubview(view)
        
        switch position {
        case UIRectCorner.topLeft:
            view.frame = CGRect(x: 0, y: 0, width: dashElementWidth, height: dashElementWidth)
            
        case UIRectCorner.topRight:
            view.frame = CGRect(x: dashViewWidth - dashElementWidth, y: 0, width: dashElementWidth, height: dashElementWidth)
            
        case UIRectCorner.bottomLeft:
            view.frame = CGRect(x: 0, y: dashViewHeight - dashElementWidth, width: dashElementWidth, height: dashElementWidth)
            
        case UIRectCorner.bottomRight:
            view.frame = CGRect(x: dashViewWidth - dashElementWidth, y: dashViewHeight - dashElementWidth, width: dashElementWidth, height: dashElementWidth)
            
        default:
            break
        }
        
        (view as! DashBoardElementViewCornerable).maskRoundCorner(positions: position, radius: 5)
    }
    
    func setSunriseView(view: DashBoardSunriseView?, date: Date, riseOrSet: String) {
        view?.titleLabel.text = NSLocalizedString(riseOrSet, comment: "")
        view?.imageView.image = UIImage(named: riseOrSet)
        view?.timeLabel.text = date.stringFromFormat("hh:mm a")
    }
}

