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
    let dashMargin: CGFloat = 20
    let dashGap: CGFloat = 10
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
            v.leading.equalToSuperview().offset(20)
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
            v.top.equalToSuperview().offset(50)
            v.bottom.equalTo(self.dashView.snp.top).offset(-50)
        }
        
        return dialView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        Timer.every(5) {
            self.refreshDateForDashView()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        refreshDialView()
        
        chargingView?.maskRoundCorner(positions: .topLeft, radius: 5)
        sunriseView?.maskRoundCorner(positions: .bottomRight, radius: 5)
        homeClockView?.maskRoundCorner(positions: .topRight, radius: 5)
        sleepHistoryView?.maskRoundCorner(positions: .bottomLeft, radius: 5)
        
        setupCenterDashView()
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
        sleepHistoryView.titleLabel.text = "INACTIVITY"
        sleepHistoryView.contentLabel.text = "7h 0m"
        
        let centerDashView = UIView()
        dashView.addSubview(centerDashView)
        self.centerDashView = centerDashView
        centerDashView.snp.makeConstraints { (v) in
            v.top.equalToSuperview()
            v.bottom.equalToSuperview()
            v.leading.equalTo(chargingView.snp.trailing).offset(self.dashGap)
            v.trailing.equalTo(homeClockView.snp.leading).offset(0 - self.dashGap)
        }
        
        setupCenterDashView()
    }
    
    func setupCenterDashView() {
        for view in centerDashView!.subviews {
            if view.isKind(of: UIScrollView.self) {
                view.removeFromSuperview()
            }
        }
        
        let scrollView = UIScrollView(frame: centerDashView!.bounds)
        centerDashView?.addSubview(scrollView)
        
        scrollView.contentSize = CGSize(width: centerDashView!.bounds.width, height: centerDashView!.bounds.height)
        
        let caloriseView = DashBoardCalorieView.factory()
        scrollView.addSubview(caloriseView)
        caloriseView.frame = centerDashView!.bounds
        caloriseView.backgroundColor = UIColor.getGreyColor()
        
        let circleView = MEDCircleView()
        caloriseView.insertSubview(circleView, at: 0)
        circleView.backgroundColor = UIColor.getGreyColor()
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
        
        /// refersh sunrise view
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
                    sunriseView?.titleLabel.text = "sunrise"
                    sunriseView?.timeLabel.text = sunriseAndSet.additionString
                }
            }
        } else {
            sunriseView?.imageView.image = UIImage(named: "sunrise")
            sunriseView?.titleLabel.text = "sunrise"
            sunriseView?.timeLabel.text = sunriseAndSet.additionString
        }
        
        /// refresh homecity viwe
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
        view.snp.makeConstraints { (v) in
            v.height.equalTo(dashElementWidth)
            v.width.equalTo(dashElementWidth)
            
            switch position {
            case UIRectCorner.topLeft:
                v.top.equalToSuperview()
                v.leading.equalToSuperview()
            case UIRectCorner.topRight:
                v.top.equalToSuperview()
                v.trailing.equalToSuperview()
            case UIRectCorner.bottomLeft:
                v.bottom.equalToSuperview()
                v.leading.equalToSuperview()
            case UIRectCorner.bottomRight:
                v.bottom.equalToSuperview()
                v.trailing.equalToSuperview()
            default:
                break
            }
        }
    }
    
    func setSunriseView(view: DashBoardSunriseView?, date: Date, riseOrSet: String) {
        view?.titleLabel.text = riseOrSet
        view?.imageView.image = UIImage(named: riseOrSet)
        view?.timeLabel.text = date.stringFromFormat("hh:mm a")
    }
}

