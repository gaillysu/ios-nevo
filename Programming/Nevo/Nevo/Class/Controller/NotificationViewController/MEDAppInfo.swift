//
//  MEDAppInfo.swift
//  Nevo
//
//  Created by Quentin on 28/11/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class MEDAppInfo: Object {
    dynamic var artworkUrl60 = ""
    dynamic var artworkUrl512 = ""
    dynamic var artworkUrl100 = ""
    dynamic var trackName = ""
    dynamic var trackCensoredName = ""
    dynamic var bundleId = ""
    
    class func medAppInfoWith(json: JSON) -> MEDAppInfo? {
        let info = MEDAppInfo()
        if let artworkUrl60 = json["artworkUrl60"].string, let artworkUrl100 = json["artworkUrl100"].string, let artworkUrl512 = json["artworkUrl512"].string, let trackName = json["trackName"].string, let trackCensoredName = json["trackCensoredName"].string, let bundleId = json["bundleId"].string {
            info.artworkUrl60 = artworkUrl60
            info.artworkUrl100 = artworkUrl100
            info.artworkUrl512 = artworkUrl512
            info.trackName = trackName
            info.trackCensoredName = trackCensoredName
            info.bundleId = bundleId
        } else {
            #if DEBUG
                fatalError("json 格式解析有问题")
            #else
                return nil
            #endif
        }
        
        return info
    }
    
    override class func primaryKey() -> String? {
        return "bundleId"
    }
}
