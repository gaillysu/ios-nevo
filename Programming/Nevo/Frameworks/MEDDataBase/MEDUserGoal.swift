//
//  MEDUserGoal.swift
//  Nevo
//
//  Created by Cloud on 2016/11/3.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class MEDUserGoal: MEDBaseModel {
    dynamic var stepsGoal:Int = 0
    dynamic var label:String = ""
    dynamic var status:Bool = false
    dynamic var key:String = Date().stringFromFormat("yyyyMMddHHmmss", locale: DateFormatter().locale)
    
    override static func primaryKey() -> String? {
        return "key"
    }
    
    /**
     When it is the first time you install and use must be implemented
     *在用户第一次安装使用的时候必须实现
     */
    class func defaultUserGoal() {
        //Start the logo for the first time
        if(!UserDefaults.standard.bool(forKey: "DefaultUserGoalLaunched")){
            let presetGoal:[Int] = [7000, 10000, 20000]
            let labelArray:[String] = ["Light","Moderate","Heavy"]
            for (index,value) in presetGoal.enumerated() {
                let userGoal:MEDUserGoal = MEDUserGoal()
                userGoal.stepsGoal = value
                userGoal.label = labelArray[index]
                userGoal.status = true
                _ = userGoal.add()
            }
            
            UserDefaults.standard.set(true, forKey: "DefaultUserGoalLaunched")
            UserDefaults.standard.set(true, forKey: "firstDefaultUserGoal")
        }else{
            UserDefaults.standard.set(false, forKey: "firstDefaultUserGoal")
        }
    }
}
