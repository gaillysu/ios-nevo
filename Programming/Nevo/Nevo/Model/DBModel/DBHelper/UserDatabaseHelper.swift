
//
//  UserDatabaseHelper.swift
//  Nevo
//
//  Created by leiyuncun on 15/11/18.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit


class UserDatabaseHelper: NevoDBModel,BaseEntryDatabaseHelper {

    /**
     Insert a table fields

     :returns: Insert results，YES or NO
     */
    func add()->Bool{
        var tableName:NSString = NSStringFromClass(self.classForCoder);
        tableName = tableName.stringByReplacingOccurrencesOfString(".", withString: "")
        let keyString:NSMutableString = NSMutableString()
        let valueString:NSMutableString = NSMutableString()
        let insertValues:NSMutableArray = NSMutableArray()
        for (var i:Int = 0; i < self.columeNames.count; i++) {
            let proname:NSString = self.columeNames.objectAtIndex(i) as! NSString
            if (proname.isEqualToString(primaryId)) {
                continue;
            }
            keyString.appendFormat("%@,", proname)
            valueString.appendString("?,")

            var value = self.valueForKey("\(proname)")
            if (value == nil) {
                value = "";
            }
            insertValues.addObject(value!)
        }

        keyString.deleteCharactersInRange(NSMakeRange(keyString.length - 1, 1))
        valueString.deleteCharactersInRange(NSMakeRange(valueString.length - 1, 1))

        let nevoDB:NevoDBHelper = NevoDBHelper.shareInstance()
        var res:Bool = false
        nevoDB.dbQueue.inDatabase { (db) -> Void in
            let sql:NSString = NSString(format: "INSERT INTO %@(%@) VALUES (%@);", tableName, keyString, valueString)
            res = db.executeUpdate("\(sql)", withArgumentsInArray: insertValues as [AnyObject])
            self.pk = res ? NSNumber(longLong: db.lastInsertRowId()).intValue : 0
            NSLog("\(res ? "Insert success" : "Insert failed")");
        }
        return res;
    }

    /**
     Based updating a table has a primary key field

     :returns: update the result ，YES or NO
     */
    override func update()->Bool{
        let nevoDB:NevoDBHelper = NevoDBHelper.shareInstance();
        var res:Bool = false;
        nevoDB.dbQueue.inDatabase { (let db) -> Void in
            var tableName:NSString = NSStringFromClass(self.classForCoder);
            tableName = tableName.stringByReplacingOccurrencesOfString(".", withString: "")
            let primaryValue = self.valueForKey(primaryId)
            if ((primaryValue == nil) || (primaryValue as! Int) <= 0) {
                return ;
            }
            let keyString:NSMutableString = NSMutableString()
            let updateValues:NSMutableArray = NSMutableArray()
            for (var i:Int = 0; i < self.columeNames.count; i++) {
                let proname:NSString = self.columeNames.objectAtIndex(i) as! NSString
                if (proname.isEqualToString(primaryId)) {
                    continue;
                }
                keyString.appendFormat(" %@=?,", proname)
                var value = self.valueForKey(proname as String)
                if (value == nil) {
                    value = "";
                }
                updateValues.addObject(value!)
            }
            keyString.deleteCharactersInRange(NSMakeRange(keyString.length - 1, 1))
            let sql:NSString = NSString(format: "UPDATE %@ SET %@ WHERE %@ = ?;", tableName, keyString, primaryId)
            updateValues.addObject(primaryValue!)
            res = db.executeUpdate(sql as String, withArgumentsInArray: updateValues as [AnyObject])
            NSLog("\(res ? "Update Success" : "Update failed")");
        }
        return res
    }

    /**
     Delete all of the fields but reserved table

     @param returns Delete the result
     */
    func remove()->Bool{
        let nevoDB:NevoDBHelper = NevoDBHelper.shareInstance()
        var res:Bool = false
        nevoDB.dbQueue.inDatabase { (db) -> Void in
            var tableName:NSString = NSStringFromClass(self.classForCoder);
            tableName = tableName.stringByReplacingOccurrencesOfString(".", withString: "")
            let primaryValue = self.valueForKey(primaryId)
            if (primaryValue == nil || (primaryValue as! Int) <= 0) {
                return ;
            }
            let sql:String = "DELETE FROM \(tableName) WHERE \(primaryId) = ?"
            res = db.executeUpdate(sql, withArgumentsInArray: [primaryValue!])
            NSLog("\(res ? "Delete the success" : "Delete failed")");
        }
        return res;
    }

    /**
     Static lookup function according to conditions

     @param criteria To find the condition
     @param returns Returns the find results
     */
     class func getCriteria(criteria:String)->NSArray {
        let nevoDB:NevoDBHelper = NevoDBHelper.shareInstance()
        let users:NSMutableArray = NSMutableArray()
        nevoDB.dbQueue.inDatabase { (db) -> Void in
            var tableName:String =  NSStringFromClass(self.classForCoder())
            tableName = tableName.stringByReplacingOccurrencesOfString(".", withString: "")
            let sql:String = "SELECT * FROM \(tableName) \(criteria)"
            let resultSet:FMResultSet = db.executeQuery(sql, withArgumentsInArray: nil)
            while (resultSet.next()) {
                let classType: AnyObject.Type = self.classForCoder()
                let nsobjectype : NevoDBModel.Type = classType as! NevoDBModel.Type
                let model:NevoDBModel = nsobjectype.init()

                for (var i:Int = 0; i < model.columeNames.count; i++) {
                    let columeName:NSString = (model.columeNames.objectAtIndex(i) as! NSString)
                    let columeType:NSString = (model.columeTypes.objectAtIndex(i) as! NSString)
                    if (columeType.isEqualToString(SQLTEXT)) {
                        model.setValue(resultSet.stringForColumn("\(columeName)"), forKey: "\(columeName)")
                    } else {
                        model.setValue(NSNumber(longLong: Int64(columeName.integerValue)), forKey: "\(columeName)")
                    }
                }
                users.addObject(model)
            }
        }
        return users;
    }

    /**
     Lookup table all field data

     :returns: Returns the query to the data
     */
    class func getAll()->NSArray{
        let nevoDB:NevoDBHelper = NevoDBHelper.shareInstance()
        let users:NSMutableArray = NSMutableArray()
        nevoDB.dbQueue.inDatabase { (db) -> Void in
            var tableName:NSString = NSStringFromClass(self.classForCoder())
            tableName = tableName.stringByReplacingOccurrencesOfString(".", withString: "")
            let sql:String = "SELECT * FROM \(tableName)"
            let resultSet:FMResultSet = db.executeQuery(sql, withArgumentsInArray: nil)
            while (resultSet.next()) {
                let classType: AnyObject.Type = self.classForCoder()
                let nsobjectype : NevoDBModel.Type = classType as! NevoDBModel.Type
                let model:NevoDBModel = nsobjectype.init()

                for (var i:Int = 0; i < model.columeNames.count; i++) {
                    let columeName:NSString = model.columeNames.objectAtIndex(i) as! NSString
                    let columeType:NSString = model.columeTypes.objectAtIndex(i) as! NSString
                    if (columeType.isEqualToString(SQLTEXT)) {
                        model.setValue(resultSet.stringForColumn("\(columeName)"), forKey: "\(columeName)")
                    } else {
                        model.setValue(NSNumber(longLong: Int64(columeName.integerValue)), forKey: "\(columeName)")
                    }
                }
                users.addObject(model)
            }

        }
        return users;
    }
}
