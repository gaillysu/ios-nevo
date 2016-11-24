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

class SunriseSetController: PublicClassController {
    
    @IBOutlet weak var dailImageView: UIImageView!
    @IBOutlet weak var cityNameLable: UILabel!
    @IBOutlet weak var cityDateLabel: UILabel!
    @IBOutlet weak var sunriseSetCollectionView: UICollectionView!
    @IBOutlet weak var button: UIButton!
    
    var solar:Solar? = nil
    var city:City? = nil
    
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
            let sunrise = solar!.sunrise
            let sunset = solar!.sunset
            
            let sunriseString:String = sunrise!.stringFromFormat("HH:mm a")
            let sunsetString:String = sunset!.stringFromFormat("HH:mm a")
            
            self.sunRiseSetTimeArrar = [sunriseString, sunsetString]
        } else {
            let solar = Solar(latitude: AppDelegate.getAppDelegate().getLatitude(), longitude: AppDelegate.getAppDelegate().getLongitude())
            let sunrise = solar?.sunrise
            let sunset = solar?.sunset
            
            let sunriseString = sunrise!.stringFromFormat("HH:mm a")
            let sunsetString = sunset!.stringFromFormat("HH:mm a")
            
            self.sunRiseSetTimeArrar = [sunriseString, sunsetString]
            
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
        if let solarValue = solar {
            self.cityDateLabel.text = solar!.date.stringFromFormat("d MMM, yyyy")
            let now:Date = self.solar!.date
            let cal:Calendar = Calendar.current
            let dd:DateComponents = (cal as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day ,NSCalendar.Unit.hour, NSCalendar.Unit.minute, NSCalendar.Unit.second,], from: now);
            
            setDialTime(dateComponents: dd)
        }        
    }
    
    public func setDialTime(dateComponents:DateComponents) {
        clockView?.setWorldTime(dateConponents: dateComponents)
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
        let realm = try! Realm()
        let citiesArray:[City] = Array(realm.objects(City.self).filter("selected = true"))
        let city = citiesArray[0]
        
        let solar = Solar(latitude: city.lat,
                          longitude: city.lng)
        let sunrise = solar!.sunrise
        let sunset = solar!.sunset
        
        let sunriseString:String = sunrise!.stringFromFormat("HH:mm a")
        let sunsetString:String = sunset!.stringFromFormat("HH:mm a")
        self.sunRiseSetTimeArrar = [sunriseString, sunsetString]
        self.sunriseSetCollectionView.reloadData()
        
        let now:Date = solar!.date
        let cal:Calendar = Calendar.current
        let dd:DateComponents = (cal as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day ,NSCalendar.Unit.hour, NSCalendar.Unit.minute, NSCalendar.Unit.second,], from: now);
        setDialTime(dateComponents: dd)
        
        self.cityNameLable.text = city.name + ", " + city.country
        self.cityDateLabel.text = solar!.date.stringFromFormat("d MMM, yyyy")
        
        let offset = String(format: "%.0f", (sunrise!.timeIntervalSince1970-sunset!.timeIntervalSince1970)/3600)
        if AppDelegate.getAppDelegate().isConnected() {
            let setWordClock:SetWorldClockRequest = SetWorldClockRequest(offset: offset.toInt())
            AppDelegate.getAppDelegate().sendRequest(setWordClock)
        }
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
            cell.subTitleLabel.text = "local time"
        } else {
            cell.iconImageView.image = UIImage(named: "sunset")
            cell.titleLable.text = self.sunRiseSetTimeArrar[1]
            cell.subTitleLabel.text = "local time"
        }
        
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
    }
}
