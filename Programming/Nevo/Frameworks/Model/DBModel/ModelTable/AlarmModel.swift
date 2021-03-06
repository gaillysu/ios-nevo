//
//  AlarmModel.swift
//  Nevo
//
//  Created by leiyuncun on 15/11/25.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit
import FMDB
import XCGLogger

class AlarmModel: UserDatabaseHelper {
    var timer:TimeInterval = 0.0
    var label:String = ""
    var status:Bool = false
    var repeatStatus:Bool = false
    var dayOfWeek:Int = 0
    var type:Int = 0

    override init() {

    }

    /**
     Static lookup function according to conditions

     @param criteria To find the condition
     @param returns Returns the find results
     */
    override class func getCriteria(_ criteria:String)->NSArray {
        let dbQueue:FMDatabaseQueue = AppDelegate.getAppDelegate().dbQueue
        let alarm:NSMutableArray = NSMutableArray()
        dbQueue.inDatabase { (db) -> Void in
            var tableName:String =  NSStringFromClass(self.classForCoder())
            tableName = tableName.replacingOccurrences(of: ".", with: "")
            let sql:String = "SELECT * FROM \(tableName) \(criteria)"
            do {
                let resultSet:FMResultSet = try db!.executeQuery(sql, values:[0,1,2,3])
                while (resultSet.next()) {
                    let model:AlarmModel = AlarmModel()
                    
                    for i:Int in 0 ..< model.columeNames.count {
                        let columeName:NSString = (model.columeNames.object(at: i) as! NSString)
                        let columeType:NSString = (model.columeTypes.object(at: i) as! NSString)
                        if (columeType.isEqual(to: SQLTEXT)) {
                            model.setValue(resultSet.string(forColumn: "\(columeName)"), forKey: "\(columeName)")
                        } else {
                            model.setValue(NSNumber(value: resultSet.longLongInt(forColumn: "\(columeName)") as Int64), forKey: "\(columeName)")
                        }
                    }
                    alarm.add(model)
                }
            }catch let error as NSError  {
                XCGLogger.default.debug("\(error)");
            }
 
        }
        return alarm;
    }

    /**
     Lookup table all field data

     :returns: Returns the query to the data
     */
    override class func getAll()->NSArray{
        let dbQueue:FMDatabaseQueue = AppDelegate.getAppDelegate().dbQueue
        let alarm:NSMutableArray = NSMutableArray()
        dbQueue.inDatabase { (db) -> Void in
            var tableName:NSString = NSStringFromClass(self.classForCoder()) as NSString
            tableName = tableName.replacingOccurrences(of: ".", with: "") as NSString
            let sql:String = "SELECT * FROM \(tableName)"
            let resultSet:FMResultSet = db!.executeQuery(sql, withArgumentsIn: nil)
            while (resultSet.next()) {
                let model:AlarmModel = AlarmModel()

                for i:Int in 0 ..< model.columeNames.count {
                    let columeName:NSString = model.columeNames.object(at: i) as! NSString
                    let columeType:NSString = model.columeTypes.object(at: i) as! NSString
                    if (columeType.isEqual(to: SQLTEXT)) {
                        model.setValue(resultSet.string(forColumn: "\(columeName)"), forKey: "\(columeName)")
                    } else {
                        model.setValue(NSNumber(value: resultSet.longLongInt(forColumn: "\(columeName)") as Int64), forKey: "\(columeName)")
                    }
                }
                alarm.add(model)
            }
            
        }
        return alarm;
    }

    override class func isExistInTable()->Bool {
        var res:Bool = false
        let dbQueue:FMDatabaseQueue = AppDelegate.getAppDelegate().dbQueue
        dbQueue.inDatabase { (db) -> Void in
            var tableName:NSString = NSStringFromClass(self.classForCoder()) as NSString
            tableName = tableName.replacingOccurrences(of: ".", with: "") as NSString
            res = (db?.tableExists("\(tableName)"))!
        }
        return res
    }

    /**
     * update Table
     * succes return true, failure return false
     */
    override class func updateTable()->Bool {
        let db:FMDatabase = FMDatabase(path: AppDelegate.dbPath())
        if(!db.open()) {
            NSLog("数据库打开失败!数据库路径:\(AppDelegate.dbPath())");
            return false;
        }

        var tableName:NSString = NSStringFromClass(self.classForCoder()) as NSString
        tableName = tableName.replacingOccurrences(of: ".", with: "") as NSString
        let columns:NSMutableArray = NSMutableArray()
        let resultSet:FMResultSet = db.getTableSchema(tableName as String)
        while (resultSet.next()) {
            let column:NSString = resultSet.string(forColumn: "name") as NSString
            columns.add(column)
        }

        let dict:NSDictionary = self.getAllProperties();
        let properties:NSArray = dict.object(forKey: "name") as! NSArray
        let filterPredicate:NSPredicate = NSPredicate(format: "NOT (SELF IN %@)",columns)
        //过滤数组
        let resultArray:NSArray = properties.filtered(using: filterPredicate) as NSArray

        for column in resultArray {
            let index:Int = properties.index(of: column)
            let proType:String = (dict.object(forKey: "type") as! NSArray).object(at: index) as! String
            let fieldSql:String = "\(column) \(proType)"
            //[NSString stringWithFormat:@"%@ %@",column,proType];
            let sql:String = String(format: "ALTER TABLE %@ ADD COLUMN %@ ",tableName,fieldSql)
            let args:CVaListPointer = getVaList([0,1,2,3,4,5,6,7]);
            if (db.executeUpdate(sql, withVAList: args)) {
                //db.close();
                return false;
            }
        }
        db.close();
        return true
    }

}
