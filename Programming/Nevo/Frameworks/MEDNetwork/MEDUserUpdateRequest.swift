//
//  UserUpdateRequest.swift
//  Drone
//
//  Created by Karl-John Chow on 1/11/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import UIKit
import SwiftyJSON

class MEDUserUpdateRequest: MEDBasePutRequest {

    init(profile:MEDUserProfile, responseBlock: @escaping (_ success:Bool, _ id:JSON?, _ error:Error?) -> Void) {
        super.init(response: responseBlock)
        self.url = "/user/update"
        self.parameters["params"] = ["user":["id":profile.uid,"first_name":profile.first_name,"last_name":profile.last_name,"email":profile.email,"length":profile.length,"birthday":profile.birthday,"weight":profile.weight]]
    }

}
