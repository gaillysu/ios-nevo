//
//  StepsModel.swift
//  Nevo
//
//  Created by leiyuncun on 15/11/18.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit
import FMDB

class StepsModel: UserDatabaseHelper {

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
    
    override init() {

    }

    /**
     Static lookup function according to conditions

     @param criteria To find the condition
     @param returns Returns the find results
     */
    override class func getCriteria(criteria:String)->NSArray {
        let dbQueue:FMDatabaseQueue = AppDelegate.getAppDelegate().dbQueue
        let steps:NSMutableArray = NSMutableArray()
        dbQueue.inDatabase { (db) -> Void in
            var tableName:String =  NSStringFromClass(self.classForCoder())
            tableName = tableName.stringByReplacingOccurrencesOfString(".", withString: "")
            let sql:String = "SELECT * FROM \(tableName) \(criteria)"
            let resultSet:FMResultSet = db.executeQuery(sql, withArgumentsInArray: nil)
            while (resultSet.next()) {
                let model:StepsModel = StepsModel()
                for i in 0 ..< model.columeNames.count{
                    let columeName:NSString = (model.columeNames.objectAtIndex(i) as! NSString)
                    let columeType:NSString = (model.columeTypes.objectAtIndex(i) as! NSString)
                    if (columeType.isEqualToString(SQLTEXT)) {
                        model.setValue(resultSet.stringForColumn("\(columeName)"), forKey: "\(columeName)")
                    } else {
                        model.setValue(NSNumber(longLong: resultSet.longLongIntForColumn("\(columeName)")), forKey: "\(columeName)")
                    }
                }
                steps.addObject(model)
            }
        }
        return steps;
    }

    /**
     Lookup table all field data

     :returns: Returns the query to the data
     */
    override class func getAll()->NSArray{
        let dbQueue:FMDatabaseQueue = AppDelegate.getAppDelegate().dbQueue
        let steps:NSMutableArray = NSMutableArray()
        dbQueue.inDatabase { (db) -> Void in
            var tableName:NSString = NSStringFromClass(self.classForCoder())
            tableName = tableName.stringByReplacingOccurrencesOfString(".", withString: "")
            let sql:String = "SELECT * FROM \(tableName)"
            let resultSet:FMResultSet = db.executeQuery(sql, withArgumentsInArray: nil)
            while (resultSet.next()) {
                let model:StepsModel = StepsModel()

                for i in 0 ..< model.columeNames.count{
                    let columeName:NSString = model.columeNames.objectAtIndex(i) as! NSString
                    let columeType:NSString = model.columeTypes.objectAtIndex(i) as! NSString
                    if (columeType.isEqualToString(SQLTEXT)) {
                        model.setValue(resultSet.stringForColumn("\(columeName)"), forKey: "\(columeName)")
                    } else {
                        model.setValue(NSNumber(double: resultSet.doubleForColumn("\(columeName)")), forKey: "\(columeName)")
                    }
                }
                steps.addObject(model)
            }
            
        }
        return steps;
    }
}