//
//  Profile.swift
//  Nevo
//
//  Created by Karl-John Chow on 18/10/2016.
//  Copyright © 2016 Nevo. All rights reserved.
//

import UIKit
import RealmSwift

class Profile: Object {

    dynamic var firstName = ""
    
    dynamic var lastName = ""
    
    dynamic var birthday:NSDate? = nil
    
    // true = male || false = female
    dynamic var gender:Bool = true

    dynamic var weight:Double = 0.0 //KG

    dynamic var length:Double = 0.0 //CM

    // true = metric || false = imperial
    dynamic var metricImperial:Bool = false

    dynamic var created = NSDate()

    dynamic var email:String = ""
    
    func fromUserProfile(nevoProfileModel:NevoProfileModel){
        self.firstName = nevoProfileModel.first_name
        self.lastName = nevoProfileModel.last_name
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y-M-d h:m:s.000000"
        if let date = dateFormatter.date(from: nevoProfileModel.birthday){
            self.birthday = date as NSDate?
        }else{
            self.birthday = NSDate()
        }
        self.gender = nevoProfileModel.gender
        self.weight = Double(nevoProfileModel.weight)
        self.length = Double(nevoProfileModel.length)
        self.metricImperial = nevoProfileModel.metricORimperial
        self.created = NSDate(timeIntervalSince1970: nevoProfileModel.created)
        self.email = nevoProfileModel.email
        
        
        
    }
}
