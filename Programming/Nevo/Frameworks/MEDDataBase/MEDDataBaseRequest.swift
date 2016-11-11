//
//  MEDDataBaseRequest.swift
//  Nevo
//
//  Created by Cloud on 2016/11/8.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import RealmSwift
import XCGLogger

protocol MEDDataBaseRequest {
    func add(request:MEDBaseModel)->Bool
    func update(request:MEDBaseModel)->Bool
    func remove(request:MEDBaseModel)->Bool
    static func removeAll(request:MEDBaseModel.Type)->Bool
    static func getFilter(_ criteria:String,request:MEDBaseModel.Type)->[MEDBaseModel]
    static func getAll(request:MEDBaseModel.Type)->[MEDBaseModel]
}

class MEDDataBaseRequestImpl:Object {
    var key:String = ""
    
    override static func primaryKey() -> String? {
        return "key"
    }
    
    func add()->Bool {
        let realm = try! Realm()
        try! realm.write {
            realm.add(self, update: true)
        }
        return true
    }
    
    func update()->Bool{
        let realm = try! Realm()
        do {
            try realm.write {
                realm.add(self, update: true)
            }
        } catch let error {
            XCGLogger.default.debug("write database error:\(error)")
            return false
        }
        return true
    }
    
    func remove()->Bool{
        let realm = try! Realm()
        do {
            try realm.write {
                realm.delete(self)
            }
        } catch let error {
            XCGLogger.default.debug("write database error:\(error)")
            return false
        }
        return true
    }
    
    class func removeAll()->Bool{
        let realm = try! Realm()
        let selfObject = realm.objects(self)
        for object in selfObject {
            do {
                try realm.write {
                    realm.delete(object)
                }
            } catch let error {
                XCGLogger.default.debug("write database error:\(error)")
                return false
            }
        }
        return true
    }
    
    class func getFilter(_ criteria:String)->[Any]{
        let realm = try! Realm()
        let selfObject = realm.objects(self).filter(criteria)
        var value:[Any] = []
        for object in selfObject {
            value.append(object)
        }
        return value
    }
    
    class func getAll()->[Any]{
        let realm = try! Realm()
        let selfObject = realm.objects(self)
        var value:[Any] = []
        for object in selfObject {
            value.append(object)
        }
        return value
    }
}
