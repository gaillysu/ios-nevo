//
//  StepsUpdateRequest.swift
//  Drone
//
//  Created by Karl-John Chow on 1/11/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import SwiftyJSON
class MEDStepsUpdateRequest: MEDBasePutRequest {
    
    init(id:Int, uid:Int, steps:String, date:String, activeTime:Int, calories:Int, distance:Double, responseBlock: @escaping (_ success:Bool, _ id:JSON?, _ error:Error?) -> Void) {
        super.init(response: responseBlock)
        self.url = "/steps/update"
//        self.parameters["params"] = ["steps": ["id":"\(id)","uid": "\(uid)","steps": "\(steps)","date": "\(date)","active_time":activeTime]]
        self.parameters["params"] = ["steps":["id":id, "uid":uid, "steps":steps, "date":date, "calories":calories, "active_time":activeTime, "distance":distance]]
    }
}
