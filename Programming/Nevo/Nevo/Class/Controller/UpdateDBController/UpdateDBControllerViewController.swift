//
//  UpdateDBControllerViewController.swift
//  Nevo
//
//  Created by Cloud on 2016/11/11.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class UpdateDBControllerViewController: UIViewController {

    fileprivate var updateArray:[Any] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        let alarmArray:NSArray = AlarmModel.getAll()
        if alarmArray.count>0 {
            updateArray.append([NSStringFromClass(AlarmModel.self):alarmArray])
        }

        let profileArray:NSArray = NevoProfileModel.getAll()
        if profileArray.count>0 {
            updateArray.append([NSStringFromClass(NevoProfileModel.self):profileArray])
        }
        
        let notificationArray:NSArray = NotificationModel.getAll()
        if notificationArray.count>0 {
            updateArray.append([NSStringFromClass(NotificationModel.self):notificationArray])
        }
        
        let goalArray:NSArray = PresetsModel.getAll()
        if goalArray.count>0 {
            updateArray.append([NSStringFromClass(PresetsModel.self):goalArray])
        }
        
        let sleepArray:NSArray = SleepModel.getAll()
        if sleepArray.count>0 {
            updateArray.append([NSStringFromClass(SleepModel.self):sleepArray])
        }
        
        let stepsArray:NSArray = StepsModel.getAll()
        if stepsArray.count>0 {
            updateArray.append([NSStringFromClass(StepsModel.self):sleepArray])
        }
        
        for (index,value) in updateArray.enumerated() {
            let valueDict:[String:NSArray] = value as! [String:NSArray]
            let keyString:String = valueDict.keys.first!
            if keyString ==  NSStringFromClass(AlarmModel.self){
                let array:NSArray = value as! NSArray
                for alarm in array {
                    let oldAlarm:AlarmModel = alarm as! AlarmModel
                    let medAlarm:MEDUserAlarm = MEDUserAlarm()
                    medAlarm.timer = oldAlarm.timer
                    medAlarm.label = oldAlarm.label
                    medAlarm.status = oldAlarm.status
                    medAlarm.alarmWeek = oldAlarm.dayOfWeek
                    medAlarm.type = oldAlarm.type
                    _ = medAlarm.add()
                }
                
            }
            
            if keyString ==  NSStringFromClass(NevoProfileModel.self){
                
            }
            
            if keyString ==  NSStringFromClass(NotificationModel.self){
                
            }
            
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
