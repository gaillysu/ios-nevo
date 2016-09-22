//
//  HttpPostRequest.swift
//  Nevo
//
//  Created by Karl-John on 31/12/2015.
//  Copyright © 2015 Nevo. All rights reserved.
//

import UIKit
import Alamofire
import XCGLogger

class HttpPostRequest: NSObject {

    class  func LunaRPostRequest(_ url: String, data:Dictionary<String,AnyObject>, completion:@escaping (_ result:NSDictionary) -> Void){
        var finalData: Dictionary<String,AnyObject> = ["token":"SU9gPy5e1d1t7W8FG2fQ6MuT06cY95MB" as AnyObject]
        finalData["params"] = data as AnyObject?;
        XCGLogger.default.debug("\(finalData)")
        
        let urls = URL(string: url)!
        let parameters: Parameters = data
        let encode:ParameterEncoding = JSONEncoding.default
        
        Alamofire.request(urls, method: .post, parameters: parameters, encoding: encode, headers: ["Authorization": "Basic YXBwczptZWRfYXBwX2RldmVsb3BtZW50","Content-Type":"application/json"]).responseJSON { (response) in
            if response.result.isSuccess {
                XCGLogger.default.debug("getJSON: \(response.result.value)")
                completion(response.result.value as! NSDictionary)
            }else if (response.result.isFailure){
                if (response.result.value == nil) {
                    completion(NSDictionary(dictionary: ["error" : "request error"]))
                }else{
                    completion(response.result.value as! NSDictionary)
                }
            }
        }
    }
    
    class  func postRequest(_ url: String, data:Dictionary<String,AnyObject>, completion:@escaping (_ result:NSDictionary) -> Void){
        var finalData: Dictionary<String,AnyObject> = ["token":"SU9gPy5e1d1t7W8FG2fQ6MuT06cY95MB" as AnyObject]
        finalData["params"] = data as AnyObject?;
        XCGLogger.default.debug("\(finalData)")
        
        let urls = URL(string: url)!
        let parameters: Parameters = data
        let encode:ParameterEncoding = JSONEncoding.default
        
        Alamofire.request(urls, method: .post, parameters: parameters, encoding: encode, headers: ["Authorization": "Basic YXBwczptZWRfYXBwX2RldmVsb3BtZW50","Content-Type":"application/json"]).responseJSON { (response) in
            if response.result.isSuccess {
                XCGLogger.default.debug("getJSON: \(response.result.value)")
                completion(response.result.value as! NSDictionary)
            }else if (response.result.isFailure){
                if (response.result.value == nil) {
                    completion(NSDictionary(dictionary: ["error" : "request error"]))
                }else{
                    completion(response.result.value as! NSDictionary)
                }
            }
        }
    }

    class  func putRequest(_ url: String, data:Dictionary<String,AnyObject>, completion:@escaping (_ result:NSDictionary) -> Void){
        var finalData: Dictionary<String,AnyObject> = ["token":"SU9gPy5e1d1t7W8FG2fQ6MuT06cY95MB" as AnyObject]
        finalData["params"] = data as AnyObject?;
        XCGLogger.default.debug("\(finalData)")
        
        let urls = URL(string: url)!
        let parameters: Parameters = data
        let encode:ParameterEncoding = JSONEncoding.default
        
        Alamofire.request(urls, method: .put, parameters: parameters, encoding: encode, headers: ["Authorization": "Basic YXBwczptZWRfYXBwX2RldmVsb3BtZW50","Content-Type":"application/json"]).responseJSON { (response) in
            if response.result.isSuccess {
                XCGLogger.default.debug("getJSON: \(response.result.value)")
                completion(response.result.value as! NSDictionary)
            }else if (response.result.isFailure){
                print(response.result.description)
                print(response.result.debugDescription)
                if (response.result.value == nil) {
                    completion(NSDictionary(dictionary: ["error" : "request error"]))
                }else{
                    completion(response.result.value as! NSDictionary)
                }
            }
        }

    }
    
}
