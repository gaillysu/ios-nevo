//
//  MEDStepsDeleteRequest.swift
//  Nevo
//
//  Created by Quentin on 3/11/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import Foundation
import SwiftyJSON

class MEDStepsDeleteRequest: MEDBaseDeleteRequest {
    
    init(uid:Int, id:Int, responseBlock: @escaping (_ bool:Bool, _ json:JSON?, _ error:Error?) -> Void) {
        super.init(response: responseBlock)
        self.url = "/steps/delete"
        self.parameters["params"] = ["steps": ["uid": uid, "id": id]]
    }
}
