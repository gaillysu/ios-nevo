//
//  UserSteps.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/23.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class UserSteps: NSObject,BaseEntryDatabaseHelper {
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
    var date:NSTimeInterval = 0
    var createDate:String = ""
    var walking_distance:Int = 0
    var walking_duration:Int = 0
    var walking_calories:Int = 0
    var running_distance:Int = 0
    var running_duration:Int = 0
    var running_calories:Int = 0
    var validic_id:String = ""
    
    private var stepsModel:StepsModel = StepsModel()

    // MARK: - NSCoding
    func encodeWithCoder(aCoder:NSCoder) {
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(steps, forKey: "steps")
        aCoder.encodeObject(goalsteps, forKey: "goalsteps")
        aCoder.encodeObject(distance, forKey: "distance")
        aCoder.encodeObject(hourlysteps, forKey: "hourlysteps")
        aCoder.encodeObject(hourlydistance, forKey: "hourlydistance")
        aCoder.encodeObject(calories, forKey: "calories")
        aCoder.encodeObject(hourlycalories, forKey: "hourlycalories")
        aCoder.encodeObject(inZoneTime, forKey: "inZoneTime")
        aCoder.encodeObject(outZoneTime, forKey: "outZoneTime")
        aCoder.encodeObject(inactivityTime, forKey: "inactivityTime")
        aCoder.encodeObject(goalreach, forKey: "goalreach")
        aCoder.encodeObject(date, forKey: "date")
        aCoder.encodeObject(createDate, forKey: "createDate")
        aCoder.encodeObject(walking_distance, forKey: "walking_distance")
        aCoder.encodeObject(walking_duration, forKey: "walking_distance")
        aCoder.encodeObject(walking_calories, forKey: "walking_calories")
        aCoder.encodeObject(running_distance, forKey: "running_distance")
        aCoder.encodeObject(running_duration, forKey: "running_duration")
        aCoder.encodeObject(running_calories, forKey: "running_calories")
    }

    init(aDecoder:NSCoder) {
        super.init()
        aDecoder.decodeObjectForKey( "id")
        aDecoder.decodeObjectForKey("steps")
        aDecoder.decodeObjectForKey("goalsteps")
        aDecoder.decodeObjectForKey("distance")
        aDecoder.decodeObjectForKey("hourlysteps")
        aDecoder.decodeObjectForKey("hourlydistance")
        aDecoder.decodeObjectForKey("calories")
        aDecoder.decodeObjectForKey("hourlycalories")
        aDecoder.decodeObjectForKey("inZoneTime")
        aDecoder.decodeObjectForKey("outZoneTime")
        aDecoder.decodeObjectForKey("inactivityTime")
        aDecoder.decodeObjectForKey("goalreach")
        aDecoder.decodeObjectForKey("date")
        aDecoder.decodeObjectForKey("createDate")
        aDecoder.decodeObjectForKey("walking_distance")
        aDecoder.decodeObjectForKey("walking_distance")
        aDecoder.decodeObjectForKey("walking_calories")
        aDecoder.decodeObjectForKey("running_distance")
        aDecoder.decodeObjectForKey("running_duration")
        aDecoder.decodeObjectForKey("running_calories")
    }

    init(keyDict:NSDictionary) {
        super.init()
        keyDict.enumerateKeysAndObjectsUsingBlock { (key, value, stop) -> Void in
            self.setValue(value, forKey: key as! String)
        }
    }

    class func getPropertys()->NSDictionary {
        let proNames:NSMutableArray = NSMutableArray()
        let proTypes:NSMutableArray = NSMutableArray()
        let theTransients:NSArray = NSArray()
        var outCount:UInt32 = 0, _:UInt32 = 0;
        let properties:UnsafeMutablePointer = class_copyPropertyList(self,&outCount)
        for i in 0 ..< outCount{
            let property:objc_property_t = properties[Int(i)];
            //获取属性名
            let propertyName:NSString = NSString(CString: property_getName(property), encoding: NSUTF8StringEncoding)!
            if (theTransients.containsObject(propertyName)) {
                continue;
            }
            proNames.addObject(propertyName)
            //获取属性类型等参数
            let propertyType:NSString = NSString(CString: property_getAttributes(property), encoding: NSUTF8StringEncoding)!
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
                proTypes.addObject(SQLTEXT)
            } else if (propertyType.hasPrefix("Ti")||propertyType.hasPrefix("TI")||propertyType.hasPrefix("Ts")||propertyType.hasPrefix("TS")||propertyType.hasPrefix("TB")) {
                proTypes.addObject(SQLINTEGER)
            } else {
                proTypes.addObject(SQLREAL)
            }
        }
        free(properties)
        return NSDictionary(dictionary: ["name":proNames,"type":proTypes])
    }
    
    func add(result:((id:Int?,completion:Bool?) -> Void)){
        if StepsModel.isExistInTable() {
            StepsModel.updateTable()
        }
        let keyName:NSArray = UserSteps.getPropertys().objectForKey("name") as! NSArray
        for value in keyName {
            let key:String = value as! String
            stepsModel.setValue(self.valueForKey(key), forKey: key)
        }
        stepsModel.add { (id, completion) -> Void in
            result(id: id, completion: completion)
        }
    }

    func update()->Bool{
        if StepsModel.isExistInTable() {
            StepsModel.updateTable()
        }
        let keyName:NSArray = UserSteps.getPropertys().objectForKey("name") as! NSArray
        for value in keyName {
            let key:String = value as! String
            stepsModel.setValue(self.valueForKey(key), forKey: key)
        }
        return stepsModel.update()
    }

    func remove()->Bool{
        stepsModel.id = id
        return stepsModel.remove()
    }

    class func removeAll()->Bool{
        return StepsModel.removeAll()
    }

    class func getCriteria(criteria:String)->NSArray{
        let modelArray:NSArray = StepsModel.getCriteria(criteria)
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let stepsModel:StepsModel = model as! StepsModel
            let keyName:NSArray = StepsModel.getAllProperties().objectForKey("name") as! NSArray
            var keyDict:[String:AnyObject] = [:]
            for value in keyName {
                let key:String = value as! String
                keyDict[key] = stepsModel.valueForKey(key)
            }
            
            let presets:UserSteps = UserSteps(keyDict: keyDict)
            allArray.addObject(presets)
        }
        return allArray
    }

    class func getAll()->NSArray{
        let modelArray:NSArray = StepsModel.getAll()
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let stepsModel:StepsModel = model as! StepsModel
            let keyName:NSArray = StepsModel.getAllProperties().objectForKey("name") as! NSArray
            var keyDict:[String:AnyObject] = [:]
            for value in keyName {
                let key:String = value as! String
                keyDict[key] = stepsModel.valueForKey(key)
            }
            
            let presets:UserSteps = UserSteps(keyDict: keyDict)
            allArray.addObject(presets)
        }
        return allArray
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
}
