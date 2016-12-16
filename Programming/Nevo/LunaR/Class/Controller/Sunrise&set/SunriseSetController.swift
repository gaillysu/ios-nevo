//
//  Sunrise&set.swift
//  Nevo
//
//  Created by Quentin on 25/10/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import Foundation
import Timepiece
import RealmSwift
import Solar
import CoreLocation
import SnapKit
import XCGLogger

class SunriseSetController: PublicClassController {
    
    @IBOutlet weak var dailImageView: UIImageView!
    @IBOutlet weak var cityNameLable: UILabel!
    @IBOutlet weak var cityDateLabel: UILabel!
    @IBOutlet weak var sunriseSetCollectionView: UICollectionView!
    @IBOutlet weak var button: UIButton!
    
    var solar:Solar? = nil
    var city:City? = nil
    
    fileprivate var clockTimer:Timer?
    
    var clockView:ClockView?
    var sunRiseSetTimeArrar:[String] = ["6:00 AM", "18:00 PM"]
    let WorldClockCellReuseID = "WorldClockCellReuseID"
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.getGreyColor()
        
        self.sunriseSetCollectionView.dataSource = self
        self.sunriseSetCollectionView.delegate = self
        
        self.button.backgroundColor = UIColor.getBaseColor()
        
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100.0, height: 100.0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        self.sunriseSetCollectionView.collectionViewLayout = UICollectionViewFlowLayout()
        
        self.sunriseSetCollectionView.register(UINib(nibName:"NewWorldClockCell", bundle: nil), forCellWithReuseIdentifier: WorldClockCellReuseID)

        let realm = try! Realm()
        let citiesArray:[City] = Array(realm.objects(City.self).filter("selected = true"))
        if citiesArray.count>0 {
            self.city = citiesArray[0]
            self.solar = Solar(latitude: city!.lat,longitude: self.city!.lng)
        } else {
            let geoCoder:CLGeocoder = CLGeocoder()
            let location:CLLocation = CLLocation(latitude: AppDelegate.getAppDelegate().getLatitude(), longitude: AppDelegate.getAppDelegate().getLongitude())
            geoCoder.reverseGeocodeLocation(location, completionHandler: { (placeMarks, error) in
                if error != nil {
                    if let placeMark = placeMarks?.first {
                        let city: City = City()
                        city.country = placeMark.country!
                        city.name = placeMark.locality!
                        self.city = city
                    }
                }
            })
        }
        
        if let city = self.city {
            self.cityNameLable.text = city.name + ", " + city.country
        } else {
            self.cityNameLable.text = "Shenzhen" + ", " + "China"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let result = AppDelegate.getAppDelegate().getSunriseOrSunsetTime()
    
        if let sunrise = result.sunriseDate, let sunset = result.sunsetDate {
            let sunriseString:String = sunrise.stringFromFormat("HH:mm a")
            sunRiseSetTimeArrar[0] = sunriseString
            let sunsetString:String = sunset.stringFromFormat("HH:mm a")
            sunRiseSetTimeArrar[1] = sunsetString
        } else {
            sunRiseSetTimeArrar[0] = result.additionString
            sunRiseSetTimeArrar[1] = result.additionString
        }
        
        sunriseSetCollectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addClockView()
        
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            self.view.backgroundColor = UIColor.getGreyColor()
        }
        
        let isSmallScreen = AppTheme.GET_IS_iPhone4S() || AppTheme.GET_IS_iPhone5S()
        let offset: CGFloat = isSmallScreen ? 20 : 37
        (self.sunriseSetCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSize(width: UIScreen.main.bounds.size.width / 2.0 - 5, height: self.sunriseSetCollectionView.frame.height - offset)
    }
    
    @IBAction func changeCity(_ sender: Any) {
        let addWorldClock:AddWorldClockViewController = AddWorldClockViewController()
        addWorldClock.didSeletedCityDelegate = self
        addWorldClock.hidesBottomBarWhenPushed = true
        let nav:UINavigationController = UINavigationController(rootViewController: addWorldClock)
        self.present(nav, animated: true, completion: nil)
    }
}

extension SunriseSetController: WorldClockDidSelectedDelegate {
    func didSelectedLocalTimeZone(_ cityId:Int) {
        if AppDelegate.getAppDelegate().isConnected(), let date:Date = calculateWordClockDialTime(){
            let setWordClock:SetWorldClockRequest = SetWorldClockRequest(offset: date.hour)
            AppDelegate.getAppDelegate().sendRequest(setWordClock)
        }
    }
    
    func calculateWordClockDialTime()-> Date? {
        UserDefaults.standard.set(Date(), forKey: "SET_WORLD_CLOCK_TIME")
        UserDefaults.standard.synchronize()
        
        let realm               = try! Realm()
        let citiesArray:[City]  = Array(realm.objects(City.self).filter("selected = true"))
        var dateTime:Date?
        if citiesArray.count>0 {
            let city = citiesArray[0]
            let timeZone:Timezone   = city.timezone!;
            let gmtOffset:Float     = Float(timeZone.gmtTimeOffset)/60.0*3600.0
            
            dateTime = convertGMTToLocalDateFormat(Int(gmtOffset))
            
            setDialTime(hour:dateTime!.hour,minute:dateTime!.minute,seconds:dateTime!.second)
            
            self.cityNameLable.text = city.name + ", " + city.country
            self.cityDateLabel.text = dateTime!.stringFromFormat("d MMM, yyyy")
        }
        
        if clockTimer == nil {
            clockTimer = Timer.every(30.seconds) {
                let startDate:Date = UserDefaults.standard.object(forKey: "SET_WORLD_CLOCK_TIME") as! Date
                if Date().timeIntervalSince1970-startDate.timeIntervalSince1970 > 30 {
                    _ = self.calculateWordClockDialTime()
                }
            }
        }
        return dateTime
    }
    
    func setDialTime(hour:Int,minute:Int,seconds:Int) {
        clockView?.setWorldTime(hour:hour,minute:minute,seconds:seconds)
    }
    
    /**
     使用gmt Offset 来格式化所在地方的时间
     
     - parameter gmtOffset: Specify the time zone offset
     
     - returns: date format
     */
    func convertGMTToLocalDateFormat(_ gmtOffset:Int) -> Date {
        let zone:TimeZone       = TimeZone(secondsFromGMT: Int(gmtOffset))!
        let offtSecond:Int      = zone.secondsFromGMT()
        let nowDate:Date        = Date().addingTimeInterval(TimeInterval(offtSecond))
        
        let sourceTimeZone:TimeZone = TimeZone(abbreviation: "GMT")!//或UTC
        let formatter               = DateFormatter()
        formatter.dateFormat        = "yyyy-MM-dd,h:mm:ss"
        formatter.timeZone          = sourceTimeZone
        let dateString:String       = formatter.string(from: nowDate)
        let dateTime:Date           = dateString.dateFromFormat("yyyy-MM-dd,h:mm:ss", locale: DateFormatter().locale)!
        return dateTime
    }

}

// MARK: - collectionview
extension SunriseSetController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: NewWorldClockCell = collectionView.dequeueReusableCell(withReuseIdentifier: WorldClockCellReuseID, for: indexPath) as! NewWorldClockCell

        if indexPath.row == 0 {
            cell.iconImageView.image = UIImage(named: "sunrise")
            cell.titleLable.text = self.sunRiseSetTimeArrar[0]
        } else {
            cell.iconImageView.image = UIImage(named: "sunset")
            cell.titleLable.text = self.sunRiseSetTimeArrar[1]
        }
        
        cell.subTitleLabel.text = NSLocalizedString("local_time", comment: "")
        
        return cell
    }
}

extension SunriseSetController {
    fileprivate func addClockView() {
        for v in self.dailImageView.subviews {
            if v is ClockView {
                v.removeFromSuperview()
            }
        }

        let hourImage = AppTheme.GET_RESOURCES_IMAGE("wacth_hour")
        let minuteImage = AppTheme.GET_RESOURCES_IMAGE("wacth_mint")
        let dialImage = AppTheme.GET_RESOURCES_IMAGE("wacth_dial")
        
        clockView = ClockView(frame: CGRect(x: 0, y: 0, width: self.dailImageView.bounds.width, height: self.dailImageView.bounds.width), hourImage: hourImage, minuteImage: minuteImage, dialImage: dialImage)
        dailImageView.addSubview(clockView!)
        
        _ = calculateWordClockDialTime()
    }
}
