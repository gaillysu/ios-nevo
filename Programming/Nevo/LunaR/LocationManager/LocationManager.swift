//
//  LocationManager.swift
//  Nevo
//
//  Created by Cloud on 2016/10/25.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import CoreLocation

let LOCATION_MANAGER:LocationManager = LocationManager()
class LocationManager: NSObject {
    fileprivate var _locationManager : CLLocationManager?
    
    typealias  didUpdateLocationsCallBack=(_ locationArray :[CLLocation])->Void
    typealias  didFailWithErrorCallBack=(_ error: Error)->Void
    typealias  didChangeAuthorizationCallBack=(_ status: CLAuthorizationStatus)->Void
    
    var didUpdateLocations:didUpdateLocationsCallBack?
    var didFailWithError:didFailWithErrorCallBack?
    var didChangeAuthorization:didChangeAuthorizationCallBack?
    var gpsAuthorizationStatus:Int {
        let state:CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        switch state {
        case CLAuthorizationStatus.notDetermined:
            return Int(CLAuthorizationStatus.notDetermined.rawValue)
        case CLAuthorizationStatus.restricted:
            return Int(CLAuthorizationStatus.restricted.rawValue)
        case CLAuthorizationStatus.denied:
            return Int(CLAuthorizationStatus.denied.rawValue)
        case CLAuthorizationStatus.authorizedAlways:
            return Int(CLAuthorizationStatus.authorizedAlways.rawValue)
        case CLAuthorizationStatus.authorizedWhenInUse:
            return Int(CLAuthorizationStatus.authorizedWhenInUse.rawValue)
        default:
            return -1
        }
    }
    
    override init() {
        super.init()
        if CLLocationManager.headingAvailable() {
            _locationManager = CLLocationManager()
            _locationManager?.delegate = self
            _locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            _locationManager?.distanceFilter = kCLLocationAccuracyKilometer
            _locationManager?.requestAlwaysAuthorization()
            _locationManager?.requestWhenInUseAuthorization()
        }else{
            let alert:ActionSheetView = ActionSheetView(title: "GPS use of infor", message: "GPS devices do not available", preferredStyle: UIAlertControllerStyle.alert)
            let action:UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    func startLocation() {
        if CLLocationManager.locationServicesEnabled() {
            _locationManager?.startUpdatingLocation()
        }else{
            let alert:ActionSheetView = ActionSheetView(title: nil, message: "Location services is not open", preferredStyle: UIAlertControllerStyle.alert)
            let action:UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    func stopLocation() {
        _locationManager?.stopUpdatingLocation()
    }
}

extension LocationManager:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        didFailWithError?(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        didUpdateLocations?(locations);
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        didChangeAuthorization?(status)
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion){
    
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion){
    
    }
}
