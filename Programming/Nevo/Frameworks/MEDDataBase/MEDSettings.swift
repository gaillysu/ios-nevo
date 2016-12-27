//
//  MEDSettings.swift
//  Nevo
//
//  Created by Quentin on 27/12/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import Foundation
import RealmSwift

/// Usage is just the same as `UseDefault.standard`, with a little difference! Have fun!
class MEDSettings: MEDBaseModel {
    dynamic var key: String = ""
    
    let boolValue = RealmOptional<Bool>()
    let intValue = RealmOptional<Int>()
    let floatValue = RealmOptional<Float>()
    let doubleValue = RealmOptional<Double>()
    dynamic var stringValue: String?
    dynamic var dataValue: Data?
    dynamic var dateValue: Date?
    
    override class func primaryKey() -> String? {
        return "key"
    }
}

// MARK: - Mainly APIs
extension MEDSettings {
    static var realm: Realm {
        return try! Realm()
    }
    
    static func setValue(_ value: Bool?, forKey key: String) {
        let setting = MEDSettings()
        setting.key = key
        setting.boolValue.value = value
        
        try! self.realm.write {
            self.realm.add(setting, update: true)
        }
    }
    
    static func setValue(_ value: Int?, forKey key: String) {
        let setting = MEDSettings()
        setting.key = key
        setting.intValue.value = value
        
        try! self.realm.write {
            self.realm.add(setting, update: true)
        }
    }
    
    static func setValue(_ value: Float?, forKey key: String) {
        let setting = MEDSettings()
        setting.key = key
        setting.floatValue.value = value
        
        try! self.realm.write {
            self.realm.add(setting, update: true)
        }
    }
    
    static func setValue(_ value: Double?, forKey key: String) {
        let setting = MEDSettings()
        setting.key = key
        setting.doubleValue.value = value
        
        try! self.realm.write {
            self.realm.add(setting, update: true)
        }
    }
    
    static func setStringValue(_ value: String?, forKey key: String) {
        let setting = MEDSettings()
        setting.key = key
        setting.stringValue = value
        
        try! self.realm.write {
            self.realm.add(setting, update: true)
        }
    }
    
    static func setDataValue(_ value: Data?, forKey key: String) {
        let setting = MEDSettings()
        setting.key = key
        setting.dataValue = value
        
        try! self.realm.write {
            self.realm.add(setting, update: true)
        }
    }
    
    static func setDateValue(_ value: Date?, forKey key: String) {
        let setting = MEDSettings()
        setting.key = key
        setting.dateValue = value
        
        try! self.realm.write {
            self.realm.add(setting, update: true)
        }
    }
    
    static func bool(forKey key: String) -> Bool? {
        return self.realm.objects(MEDSettings.self).filter("key == '\(key)'").first?.boolValue.value
    }
    
    static func int(forKey key: String) -> Int? {
        return self.realm.objects(MEDSettings.self).filter("key == '\(key)'").first?.intValue.value
    }
    
    static func float(forKey key: String) -> Float? {
        return self.realm.objects(MEDSettings.self).filter("key == '\(key)'").first?.floatValue.value
    }
    
    static func double(forKey key: String) -> Double? {
        return self.realm.objects(MEDSettings.self).filter("key == '\(key)'").first?.doubleValue.value
    }
    
    static func string(forKey key: String) -> String? {
        return self.realm.objects(MEDSettings.self).filter("key == '\(key)'").first?.stringValue
    }
    
    static func data(forKey key: String) -> Data? {
        return self.realm.objects(MEDSettings.self).filter("key == '\(key)'").first?.dataValue
    }
    
    static func date(forKey key: String) -> Date? {
        return self.realm.objects(MEDSettings.self).filter("key == '\(key)'").first?.dateValue
    }
}
