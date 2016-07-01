//
//  PresetsModel.swift
//  Nevo
//
//  Created by leiyuncun on 15/11/25.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit
import FMDB

class PresetsModel: UserDatabaseHelper {
    var steps:Int = 0
    var label:String = ""
    var status:Bool = false

    override init() {

    }

    /**
     Static lookup function according to conditions

     @param criteria To find the condition
     @param returns Returns the find results
     */
    override class func getCriteria(criteria:String)->NSArray {
        let dbQueue:FMDatabaseQueue = AppDelegate.getAppDelegate().dbQueue
        let goal:NSMutableArray = NSMutableArray()
        dbQueue.inDatabase { (db) -> Void in
            var tableName:String =  NSStringFromClass(self.classForCoder())
            tableName = tableName.stringByReplacingOccurrencesOfString(".", withString: "")
            let sql:String = "SELECT * FROM \(tableName) \(criteria)"
            let resultSet:FMResultSet = db.executeQuery(sql, withArgumentsInArray: nil)
            while (resultSet.next()) {
                let model:PresetsModel = PresetsModel()
                for i in 0 ..< model.columeNames.count{
                    let columeName:NSString = (model.columeNames.objectAtIndex(i) as! NSString)
                    let columeType:NSString = (model.columeTypes.objectAtIndex(i) as! NSString)
                    if (columeType.isEqualToString(SQLTEXT)) {
                        model.setValue(resultSet.stringForColumn("\(columeName)"), forKey: "\(columeName)")
                    } else {
                        model.setValue(NSNumber(longLong: resultSet.longLongIntForColumn("\(columeName)")), forKey: "\(columeName)")
                    }
                }
                goal.addObject(model)
            }
        }
        return goal;
    }

    /**
     Lookup table all field data

     :returns: Returns the query to the data
     */
    override class func getAll()->NSArray{
        let dbQueue:FMDatabaseQueue = AppDelegate.getAppDelegate().dbQueue
        let goal:NSMutableArray = NSMutableArray()
        dbQueue.inDatabase { (db) -> Void in
            var tableName:NSString = NSStringFromClass(self.classForCoder())
            tableName = tableName.stringByReplacingOccurrencesOfString(".", withString: "")
            let sql:String = "SELECT * FROM \(tableName)"
            let resultSet:FMResultSet = db.executeQuery(sql, withArgumentsInArray: nil)
            while (resultSet.next()) {
                let model:PresetsModel = PresetsModel()

                for i in 0 ..< model.columeNames.count{
                    let columeName:NSString = model.columeNames.objectAtIndex(i) as! NSString
                    let columeType:NSString = model.columeTypes.objectAtIndex(i) as! NSString
                    if (columeType.isEqualToString(SQLTEXT)) {
                        model.setValue(resultSet.stringForColumn("\(columeName)"), forKey: "\(columeName)")
                    } else {
                        model.setValue(NSNumber(longLong: resultSet.longLongIntForColumn("\(columeName)")), forKey: "\(columeName)")
                    }
                }
                goal.addObject(model)
            }

        }
        return goal;
    }

    override class func isExistInTable()->Bool {
        var res:Bool = false
        let dbQueue:FMDatabaseQueue = AppDelegate.getAppDelegate().dbQueue
        dbQueue.inDatabase { (db) -> Void in
            var tableName:NSString = NSStringFromClass(self.classForCoder())
            tableName = tableName.stringByReplacingOccurrencesOfString(".", withString: "")
            res = db.tableExists("\(tableName)")
        }
        return res
    }

}