//
//  MEDDataBaseManager.swift
//  Nevo
//
//  Created by Cloud on 2016/11/11.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import RealmSwift
import XCGLogger

class MEDDataBaseManager: MEDDataBaseRequest {


    func add(request:MEDBaseModel)->Bool {
        let realm = try! Realm()
        try! realm.write {
            realm.add(request, update: true)
        }
        return true
    }
    
    func update(request:MEDBaseModel)->Bool{
        let realm = try! Realm()
        do {
            try realm.write {
                realm.add(request, update: true)
            }
        } catch let error {
            XCGLogger.default.debug("write database error:\(error)")
            return false
        }
        return true
    }
    
    func remove(request:MEDBaseModel)->Bool{
        let realm = try! Realm()
        do {
            try realm.write {
                realm.delete(request)
            }
        } catch let error {
            XCGLogger.default.debug("write database error:\(error)")
            return false
        }
        return true
    }
    
    class func removeAll(request:MEDBaseModel.Type)->Bool{
        let realm = try! Realm()
        let selfObject = realm.objects(request)
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
    
    class func getFilter(_ criteria:String,request:MEDBaseModel.Type)->[MEDBaseModel]{
        let realm = try! Realm()
        let selfObject = realm.objects(request).filter(criteria)
        var value:[MEDBaseModel] = []
        for object in selfObject {
            value.append(object)
        }
        return value
    }
    
    class func getAll(request:MEDBaseModel.Type)->[MEDBaseModel]{
        let realm = try! Realm()
        let selfObject = realm.objects(request)
        var value:[MEDBaseModel] = []
        for object in selfObject {
            value.append(object)
        }
        return value
    }
}
