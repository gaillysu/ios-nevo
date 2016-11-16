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

class SunriseSetController: PublicClassController {
    
    @IBOutlet weak var dailImageView: UIImageView!
    @IBOutlet weak var cityNameLable: UILabel!
    @IBOutlet weak var sunriseSetCollectionView: UICollectionView!
    
    weak var clockView:ClockView? = nil
    var sunRiseSetTimeArrar:[String] = ["06:00 AM", "18:00 PM"]
    let WorldClockCellReuseID = "WorldClockCellReuseID"
    
//    init() {
//        super.init(nibName: "SunriseSetController", bundle: Bundle.main)
//    }
//    
//    required convenience init?(coder aDecoder: NSCoder) {
//        self.init()
//    }
    
    override func viewDidLoad() {
        addClockView()
        
        self.view.backgroundColor = UIColor.getGreyColor()
        
        self.sunriseSetCollectionView.dataSource = self
        self.sunriseSetCollectionView.delegate = self
        
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100.0, height: 100.0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        self.sunriseSetCollectionView.collectionViewLayout = UICollectionViewFlowLayout()
        
        self.sunriseSetCollectionView.register(UINib(nibName:"NewWorldClockCell", bundle: nil), forCellWithReuseIdentifier: WorldClockCellReuseID)

        let now:Date = Date()
        let cal:Calendar = Calendar.current
        let dd:DateComponents = (cal as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day ,NSCalendar.Unit.hour, NSCalendar.Unit.minute, NSCalendar.Unit.second,], from: now);
        
        setDialTime(dateComponents: dd)
    }
    
    public func setDialTime(dateComponents:DateComponents) {
        clockView?.setWorldTime(dateConponents: dateComponents)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            self.view.backgroundColor = UIColor.getGreyColor()
        }
        
        self.clockView?.center = CGPoint(x: self.dailImageView.frame.width / 2.0, y: self.dailImageView.frame.height / 2.0)
        
        (self.sunriseSetCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSize(width: UIScreen.main.bounds.width / 2.0 - 40, height: self.sunriseSetCollectionView.frame.height - 20)
    }
    
}

// MARK: - collectionview
extension SunriseSetController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: NewWorldClockCell = collectionView.dequeueReusableCell(withReuseIdentifier: WorldClockCellReuseID, for: indexPath) as! NewWorldClockCell
        
        let realm = try! Realm()

        let citiesArray:[City] = Array(realm.objects(City.self).filter("selected = true"))
        if citiesArray.count>0 {
            let city = citiesArray[0]
            
            let solar = Solar(latitude: city.lat,longitude: city.lng)
            let sunrise = solar!.sunrise
            let sunset = solar!.sunset
            
            let sunriseString:String = sunrise!.stringFromFormat("HH:mm a")
            let sunsetString:String = sunset!.stringFromFormat("HH:mm a")
            
            self.sunRiseSetTimeArrar = [sunriseString, sunsetString]
        }

        if indexPath.row == 0 {
            cell.iconImageView.image = UIImage(named: "sunrise")
            cell.titleLable.text = "Sunrise"
            cell.subTitleLabel.text = self.sunRiseSetTimeArrar[0]
        } else {
            cell.iconImageView.image = UIImage(named: "sunset")
            cell.titleLable.text = "Sunset"
            cell.subTitleLabel.text = self.sunRiseSetTimeArrar[1]
        }
        
        return cell
    }
}

extension SunriseSetController {
    fileprivate func addClockView() {
        let hourImage = AppTheme.GET_RESOURCES_IMAGE("lunar_hour")
        let minuteImage = AppTheme.GET_RESOURCES_IMAGE("lunar_Minute")
        let dialImage = AppTheme.GET_RESOURCES_IMAGE("lunar_dial")
        
        let dialViewHeight = 250
        
        let clockV:ClockView = ClockView(frame: CGRect(x: 0, y: 0, width: dialViewHeight, height: dialViewHeight), hourImage: hourImage, minuteImage: minuteImage, dialImage: dialImage)
        
        dailImageView.addSubview(clockV)
        
        clockView = clockV
    }
}
