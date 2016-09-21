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
    var created:TimeInterval = Date().timeIntervalSince1970
    var email:String = ""

    fileprivate var profileModel:NevoProfileModel = NevoProfileModel()

    init(keyDict:NSDictionary) {
        super.init()
        keyDict.enumerateKeysAndObjects(options: NSEnumerationOptions.concurrent) { (key, value, stop) in
            self.setValue(value, forKey: key as! String)
        }
    }

    func add(_ result:@escaping ((_ id:Int?,_ completion:Bool?) -> Void)){
        if NevoProfileModel.isExistInTable() {
            _ = NevoProfileModel.updateTable()
        }
        let keyName:NSArray = UserProfile.getPropertys().object(forKey: "name") as! NSArray
        for value in keyName {
            let key:String = value as! String
            profileModel.setValue(self.value(forKey: key), forKey: key)
        }
        profileModel.add { (id, completion) -> Void in
            result(id, completion)
        }
    }

    func update()->Bool{
        if NevoProfileModel.isExistInTable() {
           _ = NevoProfileModel.updateTable()
        }
        let keyName:NSArray = UserProfile.getPropertys().object(forKey: "name") as! NSArray
        for value in keyName {
            let key:String = value as! String
            profileModel.setValue(self.value(forKey: key), forKey: key)
        }
        return profileModel.update()
    }

    func remove()->Bool{
        profileModel.id = id
        return profileModel.remove()
    }

    class func removeAll()->Bool{
        return NevoProfileModel.removeAll()
    }

    class func getCriteria(_ criteria:String)->NSArray{
        let modelArray:NSArray = NevoProfileModel.getCriteria(criteria)
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let userProfileModel:NevoProfileModel = model as! NevoProfileModel
            let keyName:NSArray = NevoProfileModel.getAllProperties().object(forKey: "name") as! NSArray
            var keyDict:[String:AnyObject] = [:]
            for value in keyName {
                let key:String = value as! String
                keyDict[key] = userProfileModel.value(forKey: key) as AnyObject?
            }
            
            let presets:UserProfile = UserProfile(keyDict: keyDict as NSDictionary)
            allArray.add(presets)
        }
        return allArray
    }

    class func getAll()->NSArray{
        let modelArray:NSArray = NevoProfileModel.getAll()
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let userProfileModel:NevoProfileModel = model as! NevoProfileModel
            let keyName:NSArray = NevoProfileModel.getAllProperties().object(forKey: "name") as! NSArray
            var keyDict:[String:AnyObject] = [:]
            for value in keyName {
                let key:String = value as! String
                keyDict[key] = userProfileModel.value(forKey: key) as AnyObject?
            }
            
            let presets:UserProfile = UserProfile(keyDict: keyDict as NSDictionary)
            allArray.add(presets)
        }
        return allArray
    }

    class func isExistInTable()->Bool {
        return NevoProfileModel.isExistInTable()
    }

    /**
     When it is the first time you install and use must be implemented
     *在用户第一次安装使用的时候必须实现
     */
    class func defaultProfile(){
        let array = UserProfile.getAll()
        if(array.count == 0){
            let uesrProfile:UserProfile = UserProfile(keyDict: ["id":0,"first_name":"First name","last_name":"Last name","birthday":"2000-01-01","gender":false,"age":25,"weight":60,"length":168,"metricORimperial":false,"created":Date().timeIntervalSince1970])
            uesrProfile.add({ (id, completion) -> Void in

            })
        }
    }
    
    class func getPropertys()->NSDictionary {
        let proNames:NSMutableArray = NSMutableArray()
        let proTypes:NSMutableArray = NSMutableArray()
        let theTransients:NSArray = NSArray()
        var outCount:UInt32 = 0, _:UInt32 = 0;
        let properties:UnsafeMutablePointer = class_copyPropertyList(self,&outCount)
        for i in 0 ..< outCount{
            let property:objc_property_t = properties[Int(i)]!;
            //获取属性名
            let propertyName:NSString = NSString(cString: property_getName(property), encoding: String.Encoding.utf8.rawValue)!
            if (theTransients.contains(propertyName)) {
                continue;
            }
            proNames.add(propertyName)
            //获取属性类型等参数
            let propertyType:NSString = NSString(cString: property_getAttributes(property), encoding: String.Encoding.utf8.rawValue)!
            /*
             c char         C unsigned char
             i int          I unsigned int
             l long         L unsigned long
             s short        S unsigned short
             d double       D unsigned double
             f float        F unsigned float
             q long long    Q unsigned long long
             B BOOL
             @ 对象类型 //指针 对象类型 如NSString 是@“NSString”
             
             
             64位下long 和long long 都是Tq
             SQLite 默认支持五种数据类型TEXT、INTEGER、REAL、BLOB、NULL
             */
            if (propertyType.hasPrefix("T@")) {
                proTypes.add(SQLTEXT)
            } else if (propertyType.hasPrefix("Ti")||propertyType.hasPrefix("TI")||propertyType.hasPrefix("Ts")||propertyType.hasPrefix("TS")||propertyType.hasPrefix("TB")) {
                proTypes.add(SQLINTEGER)
            } else {
                proTypes.add(SQLREAL)
            }
        }
        free(properties)
        return NSDictionary(dictionary: ["name":proNames,"type":proTypes])
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {}
}
