//
//  MEDSleepUpdateRequest.swift
//  Nevo
//
//  Created by Quentin on 3/11/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import Foundation
import SwiftyJSON

class MEDSleepUpdateRequest: MEDBasePutRequest {
    /*
     "token":"SU9gPy5e1d1t7W8FG2fQ6MuT06cY95MB",
     "params":{
     "sleep":{
     "id":1,
     "deep_sleep":"[112312323,1231,12,12]",
     "light_sleep":"[123,123,12,12]",
     "wake_time":"[123,123,12,12]",
     "date":"2016-05-27"
     }
     }
     */
    init(id:Int, deepSleep:String, lightSleep:String, wakeTime:String, date:String, responseBlock: @escaping (_ success:Bool, _ id:JSON?, _ error:Error?) -> Void) {
        super.init(response: responseBlock)
        self.url = "/sleep/update"
        self.parameters["params"] = ["sleep": ["id":id, "deep_sleep":deepSleep,"light_sleep":lightSleep, "wake_time":wakeTime, "date":date]]
    }
}
