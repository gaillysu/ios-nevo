//
//  UserSleep.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/23.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class UserSleep: NSObject,BaseEntryDatabaseHelper {

    var id:Int = 0
    var date:NSTimeInterval = 0
    var totalSleepTime:Int = 0;
    var hourlySleepTime:String = "";
    var totalWakeTime:Int = 0;
    var hourlyWakeTime:String = "";
    var totalLightTime:Int = 0;
    var hourlyLightTime:String = "";
    var totalDeepTime:Int = 0;
    var hourlyDeepTime:String = "";
    var _id:String = "0"
    private var sleepModel:SleepModel = SleepModel()

    override init() {
        
    }

    init(keyDict:NSDictionary) {
        super.init()
        keyDict.enumerateKeysAndObjectsUsingBlock { (key, value, stop) -> Void in
            self.setValue(value, forKey: key as! String)
        }
    }

    func add(result:((id:Int?,completion:Bool?) -> Void)){
        if SleepModel.isExistInTable() {
            SleepModel.updateTable()
        }
        let keyName:NSArray = UserSleep.getPropertys().objectForKey("name") as! NSArray
        for value in keyName {
            let key:String = value as! String
            sleepModel.setValue(self.valueForKey(key), forKey: key)
        }

        sleepModel.add { (id, completion) -> Void in
            result(id: id, completion: completion)
        }
    }

    func update()->Bool{
        if SleepModel.isExistInTable() {
            SleepModel.updateTable()
        }
        let keyName:NSArray = UserSleep.getPropertys().objectForKey("name") as! NSArray
        for value in keyName {
            let key:String = value as! String
            sleepModel.setValue(self.valueForKey(key), forKey: key)
        }
        return sleepModel.update()
    }

    func remove()->Bool{
        sleepModel.id = id
        return sleepModel.remove()
    }

    class func removeAll()->Bool{
        return SleepModel.removeAll()
    }

    class func getCriteria(criteria:String)->NSArray{
        let modelArray:NSArray = SleepModel.getCriteria(criteria)
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let stepsModel:SleepModel = model as! SleepModel
            let keyName:NSArray = SleepModel.getAllProperties().objectForKey("name") as! NSArray
            var keyDict:[String:AnyObject] = [:]
            for value in keyName {
                let key:String = value as! String
                keyDict[key] = stepsModel.valueForKey(key)
            }
            
            let presets:UserSleep = UserSleep(keyDict: keyDict)
            allArray.addObject(presets)
        }
        return allArray
    }

    class func getAll()->NSArray{
        let modelArray:NSArray = SleepModel.getAll()
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let stepsModel:SleepModel = model as! SleepModel
            let keyName:NSArray = SleepModel.getAllProperties().objectForKey("name") as! NSArray
            var keyDict:[String:AnyObject] = [:]
            for value in keyName {
                let key:String = value as! String
                keyDict[key] = stepsModel.valueForKey(key)
            }
            
            let presets:UserSleep = UserSleep(keyDict: keyDict)
            allArray.addObject(presets)
        }
        return allArray
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

}
