//
//  User.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/4.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class UserProfile: NSObject {
    var id:Int = 0
    var first_name:String = ""
    var last_name:String = ""
    var birthday:String = "" //2016-06-07
    var gender:Bool = false // true = male || false = female
    var weight:Int = 0 //KG
    var length:Int = 0 //CM
    var metricORimperial:Bool = false
    var created:NSTimeInterval = NSDate().timeIntervalSince1970
    var email:String = ""

    private var profileModel:NevoProfileModel = NevoProfileModel()

    init(keyDict:NSDictionary) {
        super.init()
        keyDict.enumerateKeysAndObjectsUsingBlock { (key, value, stop) in
            self.setValue(value, forKey: key as! String)
        }
    }

    func add(result:((id:Int?,completion:Bool?) -> Void)){
        profileModel.id = id
        profileModel.first_name = first_name
        profileModel.last_name = last_name
        profileModel.birthday = birthday
        profileModel.gender = gender
        profileModel.weight = weight
        profileModel.length = length
        profileModel.metricORimperial = metricORimperial
        profileModel.created = created
        profileModel.email = email
        profileModel.add { (id, completion) -> Void in
            result(id: id, completion: completion)
        }
    }

    func update()->Bool{
        profileModel.id = id
        profileModel.first_name = first_name
        profileModel.last_name = last_name
        profileModel.birthday = birthday
        profileModel.gender = gender
        profileModel.weight = weight
        profileModel.length = length
        profileModel.metricORimperial = metricORimperial
        profileModel.created = created
        profileModel.email = email
        return profileModel.update()
    }

    func remove()->Bool{
        profileModel.id = id
        return profileModel.remove()
    }

    class func removeAll()->Bool{
        return NevoProfileModel.removeAll()
    }

    class func getCriteria(criteria:String)->NSArray{
        let modelArray:NSArray = NevoProfileModel.getCriteria(criteria)
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let userProfileModel:NevoProfileModel = model as! NevoProfileModel

            let profile:UserProfile = UserProfile(keyDict: ["id":userProfileModel.id,"first_name":userProfileModel.first_name,"last_name":"\(userProfileModel.last_name)","birthday":userProfileModel.birthday,"gender":userProfileModel.gender,"weight":userProfileModel.weight,"length":userProfileModel.length,"metricORimperial":userProfileModel.metricORimperial,"created":userProfileModel.created,"email":userProfileModel.email])
            allArray.addObject(profile)
        }
        return allArray
    }

    class func getAll()->NSArray{
        let modelArray:NSArray = NevoProfileModel.getAll()
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let userProfileModel:NevoProfileModel = model as! NevoProfileModel
            let profile:UserProfile = UserProfile(keyDict: ["id":userProfileModel.id,"first_name":userProfileModel.first_name,"last_name":"\(userProfileModel.last_name)","birthday":userProfileModel.birthday,"gender":userProfileModel.gender,"weight":userProfileModel.weight,"length":userProfileModel.length,"metricORimperial":userProfileModel.metricORimperial,"created":userProfileModel.created,"email":userProfileModel.email])
            allArray.addObject(profile)
        }
        return allArray
    }

    class func isExistInTable()->Bool {
        return NevoProfileModel.isExistInTable()
    }

    class func updateTable()->Bool {
        return NevoProfileModel.updateTable()
    }

    /**
     When it is the first time you install and use must be implemented
     *在用户第一次安装使用的时候必须实现
     */
    class func defaultProfile(){
        let array = UserProfile.getAll()
        if(array.count == 0){
            let uesrProfile:UserProfile = UserProfile(keyDict: ["id":0,"first_name":"First name","last_name":"Last name","birthday":"2000-01-01","gender":false,"age":25,"weight":60,"length":168,"metricORimperial":false,"created":NSDate().timeIntervalSince1970])
            uesrProfile.add({ (id, completion) -> Void in

            })
        }
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
}
