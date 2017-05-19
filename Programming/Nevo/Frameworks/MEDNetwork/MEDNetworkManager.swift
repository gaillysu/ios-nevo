
//
//  NetworkManager.swift
//  Drone
//
//  Created by Karl-John Chow on 28/10/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import UIKit
import Alamofire
import XCGLogger
import SwiftyJSON

class MEDNetworkManager: NSObject {
    enum NetworkType {
        case ethernetOrWiFi
        case wwan
        case unknown
    }
    
    static let manager = MEDNetworkManager()
    
    fileprivate static let baseUrl = "http://cloud.nevowatch.com"
    
    fileprivate let reachability = NetworkReachabilityManager(host: "cloud.nevowatch.com")

    var networkState:Bool {
        if let network = reachability  {
            return network.isReachable
        }
        
        return false
    }
    
    var networkType:NetworkType {
        if let wwan = reachability,wwan.isReachableOnWWAN {
            return NetworkType.wwan
        }
        
        if let wifi = reachability, wifi.isReachableOnEthernetOrWiFi {
            return NetworkType.ethernetOrWiFi
        }
        
        return NetworkType.unknown
    }
    
    
    fileprivate override init() {
        super.init()
    }
    
    class func execute(request :MEDNetworkRequest){
        if let urlPart = request.url, let encoding = request.encoding, let method = request.method {
            let url = MEDNetworkManager.baseUrl + urlPart
            Alamofire.request(url, method: method, parameters: request.parameters, encoding: encoding, headers: request.headers).responseJSON(completionHandler: { response in
                 let result = isValidResponse(response: response)
                request.response(result.success, result.json, result.error)
            })
            
        }else{
            XCGLogger.error("URL/METHOD/ENCODING IS WRONGLY/NOT SPECIFIED IN THE REQUEST. DID NOT EXECUTE NETWORK REQUEST!")
        }
    }
    
    class func isValidResponse(response:DataResponse<Any>) -> (success:Bool, json:JSON?, error:Error?) {
        switch response.result {
        case .success(let data):
            let json = JSON(data)
            if(json["status"] > 0){
                return (true, json, nil)
            }else{
                print("Request was successful but, status was smaller then 0.")
                return (false,json, nil)
            }
            
        case .failure(let error):
            print("Request was successful but, response wasn't good.")
            return (false,nil, error)
        }
//        return (false,nil, nil)
    }
}
