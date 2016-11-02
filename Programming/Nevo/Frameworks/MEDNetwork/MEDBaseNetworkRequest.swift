 //
//  BaseNetworkRequest.swift
//  Drone
//
//  Created by Karl-John Chow on 28/10/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
 
class MEDBaseNetworkRequest: MEDNetworkRequest {
    
    var response: (_ bool:Bool, _ json:JSON?, _ error:Error?) -> Void
    var parameters: Parameters
    var url: String? = ""
    var encoding: ParameterEncoding?
    var method: HTTPMethod?
    var headers: HTTPHeaders? = [:]
    
    init(response: @escaping (_ bool:Bool, _ json:JSON?, _ error:Error?) -> Void){
        if let authorizationHeader = Alamofire.Request.authorizationHeader(user: "apps", password: "med_app_development") {
            headers?[authorizationHeader.key] = authorizationHeader.value
        }
        
        let token: String = AppTheme.isTargetLunaR_OR_Nevo() ? "SU9gPy5e1d1t7W8FG2fQ6MuT06cY95MB" : "Sfz1Nk9Qt3J0dt7jNOLX0x7VHaT83V8h"
        
        self.parameters = ["token":token]
        self.response = response
    }
}
