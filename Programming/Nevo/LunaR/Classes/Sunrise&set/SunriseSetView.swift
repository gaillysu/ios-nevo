//
//  SunriseSetBgView.swift
//  Nevo
//
//  Created by Quentin on 25/10/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import Solar
import RealmSwift
import Timepiece

/// see the document commn
class SunriseSetView:UIView {
    @IBOutlet weak var weekdayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dialView: UIView!
    @IBOutlet weak var dialImageView: UIImageView!
    @IBOutlet weak var worldClocksTableView: UITableView!
    
    var worldClocks:[WorldClockItem] = [] {
        willSet {
        }
        didSet {
            worldClocksTableView.reloadData()
        }
    }
    
    let WorldClockCellReuseID = "WorldClockCellReuseID"
    
    weak var clockView:ClockView? = nil
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor =  UIColor.getGreyColor()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addClockView()
        
        worldClocksTableView.delegate = self
        worldClocksTableView.dataSource = self
        
        worldClocksTableView.backgroundColor = UIColor.getGreyColor()
        worldClocksTableView.allowsSelection = false
        worldClocksTableView.isScrollEnabled = false
        worldClocksTableView.separatorStyle = .none
        
        worldClocksTableView.register(UINib(nibName: "WorldClockCell",bundle:nil), forCellReuseIdentifier: WorldClockCellReuseID)
    }
    
    public func setDialTime(dateComponents:DateComponents) {
        clockView?.setWorldTime(dateConponents: dateComponents)
    }
    
    public func setTime(weekday:String, date:String) {
        weekdayLabel.text = weekday
        dateLabel.text = date
    }
    
    func worldClocksReload() {
        worldClocksTableView.reloadData()
    }
}

extension SunriseSetView:UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:WorldClockCell = tableView.dequeueReusableCell(withIdentifier: WorldClockCellReuseID, for: indexPath) as! WorldClockCell
        let realm = try! Realm()
        if indexPath.row == 1 {
            let citiesArray:[City] = Array(realm.objects(City.self).filter("selected = true"))
            if citiesArray.count>0 {
                let city = citiesArray[0]
                
                let solar = Solar(latitude: city.lat,longitude: city.lng)
                let sunrise = solar!.sunrise
                let sunset = solar!.sunset
                
                let sunriseString:String = sunrise!.stringFromFormat("HH:mm a")
                let sunsetString:String = sunset!.stringFromFormat("HH:mm a")
                
                cell.setTime(worldTime: city.name, sunriseTime: sunriseString, sunsetTime: sunsetString)
            }
            
        }else{
            
            let solar = Solar(latitude: AppDelegate.getAppDelegate().getLatitude(),longitude: AppDelegate.getAppDelegate().getLongitude())
            let sunrise = solar!.sunrise
            let sunset = solar!.sunset
            
            let sunriseString:String = sunrise!.stringFromFormat("HH:mm a")
            let sunsetString:String = sunset!.stringFromFormat("HH:mm a")
            
            let now = Date()
            let timeZoneNameData = now.timeZone.name.characters.split{$0 == "/"}.map(String.init)
            if timeZoneNameData.count >= 2 {
                cell.setTime(worldTime: timeZoneNameData[1].replacingOccurrences(of: "_", with: " "), sunriseTime: sunriseString, sunsetTime: sunsetString)
            }
            
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension SunriseSetView {
    fileprivate func addClockView() {
        let hourImage = AppTheme.GET_RESOURCES_IMAGE("lunar_hour")
        let minuteImage = AppTheme.GET_RESOURCES_IMAGE("lunar_Minute")
        let dialImage = AppTheme.GET_RESOURCES_IMAGE("lunar_dial")
        
        // 
        let dialViewHeight = (UIScreen.main.bounds.height - 121 - 64 - 49) / 2
        
        let clockV:ClockView = ClockView(frame: CGRect(x: 0, y: 0, width: dialViewHeight, height: dialViewHeight), hourImage: hourImage, minuteImage: minuteImage, dialImage: dialImage)
        
        dialImageView.addSubview(clockV)
        
        clockView = clockV
    }
}


