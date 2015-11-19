
//
//  UserDatabaseHelper.swift
//  Nevo
//
//  Created by leiyuncun on 15/11/18.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit


class UserDatabaseHelper: NevoDBModel,BaseEntryDatabaseHelper {

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
            NSLog("\(res ? "插入成功 " : "插入失败")");
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
            //删除最后那个逗号
            keyString.deleteCharactersInRange(NSMakeRange(keyString.length - 1, 1))
            let sql:NSString = NSString(format: "UPDATE %@ SET %@ WHERE %@ = ?;", tableName, keyString, primaryId)
            updateValues.addObject(primaryValue!)
            res = db.executeUpdate(sql as String, withArgumentsInArray: updateValues as [AnyObject])
            NSLog("\(res ? "更新成功" : "更新失败")");
        }
        return res
    }

    /**
     To delete a table

     :returns: Delete the result
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
            NSLog("\(res ? "删除成功" : "删除失败")");
        }
        return res;
    }

    func get(criteria:String)->NSArray {
        return NSArray();
    }

    func getAll()->NSArray{
        return NSArray()
    }
}
