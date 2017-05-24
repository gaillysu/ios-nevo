//
//  MEDSleepNetworkManager.swift
//  Nevo
//
//  Created by Quentin on 3/11/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import Foundation
class MEDSleepNetworkManager: NSObject {
    /*
     "uid":1,
     "deep_sleep":"[123,123,12,12]",
     "light_sleep":"[123,123,12,12]",
     "wake_time":"[123,123,12,12]",
     "date":"2016-05-27"
     */
    class func createSleep(uid:Int, deepSleep:String, lightSleep:String, wakeTime:String, date: String, completion:@escaping ((_ created:Bool) -> Void)){
        MEDNetworkManager.execute(request: MEDSleepCreateRequest(uid: uid, deepSleep: deepSleep, lightSleep: lightSleep, wakeTime: wakeTime, date: date, responseBlock: { (success, optionalJson, optionalError) in
            if success, let _ = optionalJson {
                completion(true)
            }else{
                completion(false)
            }
        }))
    }
}
