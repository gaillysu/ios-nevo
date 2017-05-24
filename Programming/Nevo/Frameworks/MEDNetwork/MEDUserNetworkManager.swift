//
//  UserNetworkManager.swift
//  Drone
//
//  Created by Karl-John Chow on 31/10/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

public enum CREATE_USER_STATUS {
    case SIGNUP_FAILED
    case USER_EXIST
    case SUCCESS
}

class MEDUserNetworkManager: NSObject {
    class func createUser(firstName: String, lastName: String, email: String, password: String, birthday: String, length: String, weight: String, sex: Int, completion:@escaping (_ result:CREATE_USER_STATUS) -> Void) {
        
        MEDNetworkManager.execute(request: MEDUserCreateRequest(firstName: firstName, lastName: lastName, email: email, password: password, birthday: birthday, length: length, weight: weight, sex: sex, responseBlock: { (success, optionalJson, optionalError) in
            if let json = optionalJson {
                switch json["status"] {
                case 1:
                    completion(.SUCCESS)
                case -2:
                    completion(.USER_EXIST)
                default:
                    completion(.SIGNUP_FAILED)
                }
            }else{
                completion(.SIGNUP_FAILED)
            }
            
        }))
    }
    
    class func updateUser(profile:MEDUserProfile, completion:@escaping (_ created:Bool, _ profile:MEDUserProfile?) -> Void){
        MEDNetworkManager.execute(request: MEDUserUpdateRequest(profile: profile, responseBlock: { (success, optionalJson, optionalError) in
            if success, let json = optionalJson{
                let profile: MEDUserProfile = jsonToUser(user: json["user"])
                completion(true, profile)
            }else{
                completion(false, nil)
            }
        }))
    }
    
    class func login(email:String, password:String, completion:@escaping ( _
        loggedIn:Bool, _ user:MEDUserProfile?) -> Void){
        MEDNetworkManager.execute(request: MEDLoginRequest(email: email, password: password, responseBlock: { (success, optionalJson, optionalError) in
            if success, let json = optionalJson{
                let user:MEDUserProfile = jsonToUser(user: json["user"])
                completion(true, user)
            }else{
                completion(false, nil)
            }
        }))
    }
    
    class func requestPassword(email:String, completion:@escaping ( _ result:
        (success:Bool, token:String, id:Int)) -> Void) {
        MEDNetworkManager.execute(request: MEDRequestPasswordRequest(email: email, responseBlock: { (success, optionalJson, optionalError) in
            if success, let json = optionalJson{
                let token:String = json["user"]["password_token"].string!
                let id:Int = json["user"]["id"].intValue
                completion((success: true, token: token, id: id))
            }else{
                completion((success: false, token: "", id: -1))
            }
        }))
    }
    
    class func forgetPassword(email:String, password:String, id:Int, token:String, completion:@escaping ( _ changeSuccess:
        Bool) -> Void){
        MEDNetworkManager.execute(request: MEDForgetPasswordRequest(email: email, password: password, token: token, id: id, responseBlock: { (success, optionalJson, optionalError) in
            if success{
                completion(true)
            }else{
                completion(false)
            }
        }))
    }
    
    private class func jsonToUser(user:JSON) -> MEDUserProfile{
        let jsonBirthday = user["birthday"];
        let dateString: String = jsonBirthday["date"].stringValue
        var birthday:String = ""
        if !jsonBirthday.isEmpty || !dateString.isEmpty {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "y-M-d h:m:s.000000"
            let birthdayDate = dateFormatter.date(from: dateString)
            dateFormatter.dateFormat = "y-M-d"
            birthday = dateFormatter.string(from: birthdayDate!)
        }
        
        let userProfile = MEDUserProfile()
        userProfile.uid = user["id"].intValue
        userProfile.first_name = user["first_name"].stringValue
        userProfile.last_name = user["last_name"].stringValue
        userProfile.birthday = birthday
        userProfile.length = user["length"].intValue
        userProfile.weight = user["weight"].intValue
        userProfile.email = user["email"].stringValue
        
        return userProfile
    }
}
