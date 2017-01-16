//
//  HomeClockUtil.swift
//  Nevo
//
//  Created by Quentin on 19/12/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import RealmSwift
import CoreLocation

fileprivate let _shared = HomeClockUtil()
public let primaryKeyByLocating = -191216

class HomeClockUtil {
    
    private var homeCity: City?
    private lazy var realm: Realm = {
        return try! Realm()
    }()
    
    static var shared: HomeClockUtil = HomeClockUtil()
    
    fileprivate init() {
        
    }
    
    func getHomeCityWithSelectedFlag() -> City? {
        return realm.objects(City.self).filter("selected = true").first
    }
    
    func getHomeCityWithLocatingKey() -> City? {
        return realm.objects(City.self).filter("id = \(primaryKeyByLocating)").first
    }
    
    func saveHomeCity(city: City) {
        if let lastCity = getHomeCityWithSelectedFlag() {
            try! realm.write {
                lastCity.selected = false
            }
        }
        
        try! realm.write {
            city.selected = true
        }
    }
    
    func saveHomeCityWithLocatingKey(city: City) {
        if let lastCity = getHomeCityWithSelectedFlag() {
            try! realm.write {
                lastCity.selected = false
            }
        }
        
        if let lastCity = getHomeCityWithLocatingKey() {
            try! realm.write {
                realm.delete(lastCity)
            }
        }
        
        let homeCity = City()
        homeCity.country = city.country
        homeCity.name = city.name
        homeCity.lat = city.lat
        homeCity.lng = city.lng
        homeCity.timezoneId = city.timezoneId
        homeCity.selected = true
        
        homeCity.id = primaryKeyByLocating
        
        try! realm.write {
            realm.add(homeCity, update: true)
        }
    }
    
    func getTimezoneWithCity(city: City) -> Timezone? {
        if let city = getHomeCityWithSelectedFlag() {
            if let timezone = realm.objects(Timezone.self).filter("id = \(city.timezoneId)").first {
                return timezone
            }
        }
        return nil
    }
    
    func getLocation(closure: @escaping (City?) ->Void) {
        
        let geoCoder:CLGeocoder = CLGeocoder()
        
        //TODO: Can be better, NEED to write a LocationKit for this!
        if AppDelegate.getAppDelegate().getLatitude() == 0 && AppDelegate.getAppDelegate().getLongitude() == 0 {
            closure(nil)
        }
        
        let location:CLLocation = CLLocation(latitude: AppDelegate.getAppDelegate().getLatitude(), longitude: AppDelegate.getAppDelegate().getLongitude())
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placeMarks, error) in

            if let placeMark = placeMarks?.first, let country = placeMark.country {
                let city = City()
                city.country = country
                city.lng = AppDelegate.getAppDelegate().getLongitude()
                city.lat = AppDelegate.getAppDelegate().getLatitude()
                
                let currentTimezone = TimeZone.current
                let gmtOffset = currentTimezone.secondsFromGMT() / 60
                if let timezoneID = self.realm.objects(Timezone.self).filter("gmtTimeOffset = \(gmtOffset)").first?.id {
                    city.timezoneId = timezoneID
                }
                
                if let locality = placeMark.locality {
                    city.name = locality
                } else if let administrativeArea = placeMark.administrativeArea {
                    city.name = administrativeArea
                } else {
                    closure(nil)
                }
                closure(city)
            } else {
                closure(nil)
            }
        })
    }
    
    func getHomeTime() -> Date? {
        if let city = getHomeCityWithSelectedFlag(), let timezone = getTimezoneWithCity(city: city) {
            return calculateHomeTimeWithTimezone(timezone, useTranslatedDate: true)
        }
        
        return nil
    }
    
    
    func calculateHomeTimeWithTimezone(_ timezone: Timezone, useTranslatedDate: Bool) -> Date {
        let gmtOffset = timezone.gmtTimeOffset * 60 // seconds from gmt
        
        var homeTime = Date(timeInterval: TimeInterval(gmtOffset), since: Date())   // time from gmt
        
        let dstBeginTime = WorldClockUtil.getStartDateForDST(timezone)
        let dstEndTime = WorldClockUtil.getStopDateForDST(timezone)
        
        if timezone.dstTimeOffset > 0 && homeTime > dstBeginTime && homeTime < dstEndTime {
            homeTime = Date(timeInterval: TimeInterval(timezone.dstTimeOffset * 60), since: homeTime)
        }
        
        if useTranslatedDate {
            let format = "yyyyMMdd HHmmSS"
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            let dateString = formatter.string(from: homeTime)
            
            if let date = dateString.dateFromFormat(format, locale: DateFormatter().locale) {
                homeTime = date
            }
        }
        
        return homeTime
    }
}
