//
//  NevoAllKeys.swift
//  Nevo
//
//  Created by leiyuncun on 16/3/29.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class NevoAllKeys: NSObject {

    class func LocalStartSportKey()->String {
        return "START_SPORT_KEY"
    }

    class func LocalEndSportKey()->String {
        return "END_SPORT_KEY"
    }
    
    class func MEDAvatarKeyBeforeSave()->String {
        return "MEDAvatarKeyBeforeSave" + (MEDUserProfile.getAll().first as! MEDUserProfile).email
    }
    class func MEDAvatarKeyAfterSave()->String {
        return "MEDAvatarKeyAfterSave" + (MEDUserProfile.getAll().first as! MEDUserProfile).email
    }
}
