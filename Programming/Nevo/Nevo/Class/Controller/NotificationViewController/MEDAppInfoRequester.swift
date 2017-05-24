//
//  MEDAppInfoRequester.swift
//  Nevo
//
//  Created by Quentin on 28/11/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift

class MEDAppInfoRequester {
    static let baseURL = "https://itunes.apple.com/lookup?bundleId="
    
    enum ResponseError: Error {
        case illegalBundleID
    }
    
    class func requestAppInfoWith(bundleId: String, resultHandle: @escaping (Swift.Error?, MEDAppInfo?) -> Void) {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "bundleId = %@", bundleId)
        if let info = realm.objects(MEDAppInfo.self).filter(predicate).first {
            resultHandle(nil, (info.copy() as! MEDAppInfo))
            return
        }
        
        if let url: URL = URL(string: baseURL + bundleId) {
            Alamofire.request(url).responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(let data):
                    let json = JSON(data)
                    
                    if json.count == 0 {
                        resultHandle(ResponseError.illegalBundleID, nil)
                    } else {
                        if let info = MEDAppInfo.medAppInfoWith(json: json["results"][0]) {
                            let realm = try! Realm()
                            try! realm.write {
                                realm.add(info, update: true)
                            }
                            resultHandle(nil, info)
                        }
                    }
                case .failure(let error):
                    resultHandle(error, nil)
                }
            })
        }
    }
}
