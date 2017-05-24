//
//  MEDSleepCreateRequest.swift
//  Nevo
//
//  Created by Quentin on 3/11/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import Foundation
import SwiftyJSON

class MEDSleepCreateRequest: MEDBasePostRequest {
    
    init(uid:Int, deepSleep:String, lightSleep:String, wakeTime:String, date:String, responseBlock: @escaping (_ bool:Bool, _ json:JSON?, _ error:Error?) -> Void) {
        super.init(response: responseBlock)
        self.url = "/sleep/create"
        self.parameters["params"] = ["sleep": ["uid": uid, "deep_sleep":deepSleep, "light_sleep":lightSleep, "wake_time":wakeTime, "date":date]]
    }
}
