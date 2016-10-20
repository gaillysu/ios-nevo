//
//  UserSteps.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/23.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class UserSteps: NSObject {
    var uid:Int = 0
    var id:Int = 0
    var steps:Int = 0
    var goalsteps:Int = 0
    var distance:Int = 0
    var hourlysteps:String = ""
    var hourlydistance:String = ""
    var calories:Double = 0
    var hourlycalories:String = ""
    var inZoneTime:Int = 0;
    var outZoneTime:Int = 0;
    var inactivityTime:Int = 0;
    var goalreach:Double = 0.0;
    var date:TimeInterval = 0
    var createDate:String = ""
    var walking_distance:Int = 0
    var walking_duration:Int = 0
    var walking_calories:Int = 0
    var running_distance:Int = 0
    var running_duration:Int = 0
    var running_calories:Int = 0
    var validic_id:String = ""
    
    fileprivate var stepsModel:StepsModel = StepsModel()

    // MARK: - NSCoding
    func encodeWithCoder(_ aCoder:NSCoder) {
        aCoder.encode(uid, forKey: "uid")
        aCoder.encode(steps, forKey: "steps")
        aCoder.encode(goalsteps, forKey: "goalsteps")
        aCoder.encode(distance, forKey: "distance")
        aCoder.encode(hourlysteps, forKey: "hourlysteps")
        aCoder.encode(hourlydistance, forKey: "hourlydistance")
        aCoder.encode(calories, forKey: "calories")
        aCoder.encode(hourlycalories, forKey: "hourlycalories")
        aCoder.encode(inZoneTime, forKey: "inZoneTime")
        aCoder.encode(outZoneTime, forKey: "outZoneTime")
        aCoder.encode(inactivityTime, forKey: "inactivityTime")
        aCoder.encode(goalreach, forKey: "goalreach")
        aCoder.encode(date, forKey: "date")
        aCoder.encode(createDate, forKey: "createDate")
        aCoder.encode(walking_distance, forKey: "walking_distance")
        aCoder.encode(walking_duration, forKey: "walking_distance")
        aCoder.encode(walking_calories, forKey: "walking_calories")
        aCoder.encode(running_distance, forKey: "running_distance")
        aCoder.encode(running_duration, forKey: "running_duration")
        aCoder.encode(running_calories, forKey: "running_calories")
    }

    init(aDecoder:NSCoder) {
        super.init()
        aDecoder.decodeObject( forKey: "uid")
        aDecoder.decodeObject(forKey: "steps")
        aDecoder.decodeObject(forKey: "goalsteps")
        aDecoder.decodeObject(forKey: "distance")
        aDecoder.decodeObject(forKey: "hourlysteps")
        aDecoder.decodeObject(forKey: "hourlydistance")
        aDecoder.decodeObject(forKey: "calories")
        aDecoder.decodeObject(forKey: "hourlycalories")
        aDecoder.decodeObject(forKey: "inZoneTime")
        aDecoder.decodeObject(forKey: "outZoneTime")
        aDecoder.decodeObject(forKey: "inactivityTime")
        aDecoder.decodeObject(forKey: "goalreach")
        aDecoder.decodeObject(forKey: "date")
        aDecoder.decodeObject(forKey: "createDate")
        aDecoder.decodeObject(forKey: "walking_distance")
        aDecoder.decodeObject(forKey: "walking_distance")
        aDecoder.decodeObject(forKey: "walking_calories")
        aDecoder.decodeObject(forKey: "running_distance")
        aDecoder.decodeObject(forKey: "running_duration")
        aDecoder.decodeObject(forKey: "running_calories")
    }

    init(keyDict:NSDictionary) {
        super.init()
        keyDict.enumerateKeysAndObjects(options: NSEnumerationOptions.reverse) { (key, value, stop) in
            self.setValue(value, forKey: key as! String)
        }
    }
    
    override init() {
        super.init()
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
    
    func add(_ result:@escaping ((_ id:Int?,_ completion:Bool?) -> Void)){
        if StepsModel.isExistInTable() {
            StepsModel.updateTable()
        }
        let keyName:NSArray = UserSteps.getPropertys().object(forKey: "name") as! NSArray
        for value in keyName {
            let key:String = value as! String
            stepsModel.setValue(self.value(forKey: key), forKey: key)
        }
        stepsModel.add { (id, completion) -> Void in
            result(id, completion)
        }
    }

    @discardableResult
    func update()->Bool{
        if StepsModel.isExistInTable() {
            StepsModel.updateTable()
        }
        let keyName:NSArray = UserSteps.getPropertys().object(forKey: "name") as! NSArray
        for value in keyName {
            let key:String = value as! String
            stepsModel.setValue(self.value(forKey: key), forKey: key)
        }
        return stepsModel.update()
    }

    @discardableResult
    func remove()->Bool{
        stepsModel.id = id
        return stepsModel.remove()
    }

    @discardableResult
    class func removeAll()->Bool{
        return StepsModel.removeAll()
    }

    class func getCriteria(_ criteria:String)->NSArray{
        let modelArray:NSArray = StepsModel.getCriteria(criteria)
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let stepsModel:StepsModel = model as! StepsModel
            let keyName:NSArray = StepsModel.getAllProperties().object(forKey: "name") as! NSArray
            var keyDict:[String:AnyObject] = [:]
            for value in keyName {
                let key:String = value as! String
                keyDict[key] = stepsModel.value(forKey: key) as AnyObject?
            }
            
            let presets:UserSteps = UserSteps(keyDict: keyDict as NSDictionary)
            allArray.add(presets)
        }
        return allArray
    }

    class func getAll()->NSArray{
        let modelArray:NSArray = StepsModel.getAll()
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let stepsModel:StepsModel = model as! StepsModel
            let keyName:NSArray = StepsModel.getAllProperties().object(forKey: "name") as! NSArray
            var keyDict:[String:AnyObject] = [:]
            for value in keyName {
                let key:String = value as! String
                keyDict[key] = stepsModel.value(forKey: key) as AnyObject?
            }
            
            let presets:UserSteps = UserSteps(keyDict: keyDict as NSDictionary)
            allArray.add(presets)
        }
        return allArray
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {}
}
