//
//  UserDefaults+Extension.swift
//  Nevo
//
//  Created by Karl-John Chow on 3/5/2017.
//  Copyright © 2017 Nevo. All rights reserved.
//

import Foundation

extension UserDefaults{
    
    // MARK: - Firmware Version
    func getFirmwareVersion() -> Int{
        return integer(forKey: getFirmwareKey())
    }
    
    func setFirmwareVersion(version:Int){
        set(version, forKey: getFirmwareKey())
        synchronize()
    }
    
    private func getFirmwareKey() -> String{
        return "FIRMWARE_VERSION_KEY"
    }

    // MARK: - Software Version
    func getSoftwareVersion() -> Int{
        return integer(forKey: getSoftwareKey())
    }
    
    func setSoftwareVersion(version:Int){
        set(version, forKey: getSoftwareKey())
        synchronize()
    }
    
    private func getSoftwareKey() -> String{
        return "SOFTWARE_VERSION_KEY"
    }

    // MARK: - DURATION SEARCH
    func getDurationSearch() -> Int{
        return integer(forKey: getDurationSearchKey())
    }
    
    func setDurationSearch(version:Int){
        set(version, forKey: getDurationSearchKey())
        synchronize()
    }
    
    private func getDurationSearchKey() -> String{
        return "DURATION_SEARCH_KEY"
    }



}
