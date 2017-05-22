//
//  LocalNotificationManager.swift
//  Nevo
//
//  Created by ideas on 15/3/24.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit
import XCGLogger

class LocalNotificationManager: NSObject {
    fileprivate var mConnectedLocalMsg:[UILocalNotification] = []
    fileprivate var mDisconnectedLocalMsg:[UILocalNotification] = []
    fileprivate var mIsSendLocalMsg:Bool = false
    fileprivate let mIsSendLocalMsgKey:String = "IsSendLocalMsg"
    
    struct Const {
        static var connectedTime:Int?
        static var disconnectTime:Int?
        static let maxReconnectTime:Double = 20
        enum connectionStatus:String {
            case connected = "Connected"
            case disconnected = "Disconnect"
        }
        enum connectionLocalMsgType:String {
            case connected = "Connected"
            case disconnected = "Disconnected"
            case all = "All"
        }
        static let isShowBeforeMsg = false
    }
    
    /**
    A classic singelton pattern
    */
    class var sharedInstance : LocalNotificationManager {
        struct Singleton {
            static let instance = LocalNotificationManager()
        }
        return Singleton.instance
    }
    
    /**
    No initialisation outside of this class, this is a singleton
    */
    fileprivate override init() {
        super.init()
        mIsSendLocalMsg = getIsSendLocalMsg()
    }
    
    /**
    get mIsSendLocalMsg
    
    :returns: <#return value description#>
    */
    func getIsSendLocalMsg() -> Bool {
        let userDefaults = UserDefaults.standard
        var val:Bool = false
        if let isOpen: AnyObject = userDefaults.object(forKey: mIsSendLocalMsgKey) as AnyObject? {
            val = isOpen as! Bool
        }
        return val
    }
    
    /**
    set mIsSendLocalMsg
    
    :param: val bool
    */
    func setIsSendLocalMsg(_ val:Bool){
        let userDefaults = UserDefaults.standard
        userDefaults.set(val,forKey:mIsSendLocalMsgKey)
        userDefaults.synchronize()
    }
    
    /**
    set the connected time
    
    :param: timeInter timeIntervalSince1970
    */
    func setConnectedTime(_ timeInter:Int) {
        //remove all connected msg before
        removeAllConnectionMsgBefore()
        let nowTime = Int(Date().timeIntervalSince1970)
        LocalNotificationManager.Const.connectedTime = timeInter
        
        if LocalNotificationManager.Const.connectedTime != nil {
            //if disconnecttime and connectedtime not more than 20 seconds, not show the connected msg
            if let preDisconnectTime = LocalNotificationManager.Const.disconnectTime {
                if nowTime - preDisconnectTime > Int(LocalNotificationManager.Const.maxReconnectTime) {
                    XCGLogger.default.debug("show the connected msg")
                    let connectedMsg = LocalNotificationManager.LocalNotificationBody(NSLocalizedString(LocalNotificationManager.Const.connectionStatus.connected.rawValue,comment: "") as NSString)
                    mConnectedLocalMsg.append(connectedMsg)
                }
            }
        }
        
        
        //if disconnecttime and connectedtime not more than 20 seconds, cancel the disconnect msg
        if let preDisconnectedTime = LocalNotificationManager.Const.disconnectTime {
            XCGLogger.default.debug("checkConnectSendNotification connected time \(nowTime) offset: \(nowTime - preDisconnectedTime)")
            if nowTime - preDisconnectedTime < Int(LocalNotificationManager.Const.maxReconnectTime) {
                var arrayIndex = 0
                for disMsg in mDisconnectedLocalMsg {
                    let disMsgTimer:Date = disMsg.fireDate!
                    XCGLogger.default.debug("cancel disconnect msg \(disMsgTimer.timeIntervalSince1970)")
                    //if the msg is not show , cancel it
                    if Date().timeIntervalSince1970 - disMsgTimer.timeIntervalSince1970 < 0 {
                        UIApplication.shared.cancelLocalNotification(disMsg)
                        mDisconnectedLocalMsg.remove(at: arrayIndex)
                    }
                    arrayIndex+=1
                }
            }
            
        }
        
    }
    
    /**
    remove all connection msg before, so we only see one msg
    */
    func removeAllConnectionMsgBefore(_ type:Const.connectionLocalMsgType = Const.connectionLocalMsgType.all) {
        if LocalNotificationManager.Const.isShowBeforeMsg == false {
            if type == Const.connectionLocalMsgType.all || type == Const.connectionLocalMsgType.connected {
                for cmsgTimer in mConnectedLocalMsg {
                    UIApplication.shared.cancelLocalNotification(cmsgTimer)
                }
                mConnectedLocalMsg = []
            }
            if type == Const.connectionLocalMsgType.all || type == Const.connectionLocalMsgType.disconnected {
                for dmsgTimer in mDisconnectedLocalMsg {
                    UIApplication.shared.cancelLocalNotification(dmsgTimer)
                }
                mDisconnectedLocalMsg = []
            }
            
        }
    }
    
    /**
    set the disconnect time
    
    :param: timeInter timeIntervalSince1970
    */
    func setDisconnectTime(_ timeInter:Int) {
        removeAllConnectionMsgBefore(LocalNotificationManager.Const.connectionLocalMsgType.disconnected)
        LocalNotificationManager.Const.disconnectTime = timeInter
        if let connectedTime = LocalNotificationManager.Const.connectedTime {
            XCGLogger.default.debug("checkConnectSendNotification disconnected time \(timeInter) offset: \(timeInter - connectedTime)")
        }
        let disconnectMsg = LocalNotificationManager.LocalNotificationBody(NSLocalizedString(LocalNotificationManager.Const.connectionStatus.disconnected.rawValue,comment: "") as NSString, delay: LocalNotificationManager.Const.maxReconnectTime)
        mDisconnectedLocalMsg.append(disconnectMsg)
    }

    
    /**
    check the connection and send local notification if necessary
    
    :param: type ConnectionManager.Const.connectionStatus
    */
    func checkConnectSendNotification(_ type:LocalNotificationManager.Const.connectionStatus){
        //if not open the send local notification , not go on
        if getIsSendLocalMsg() == false {
            XCGLogger.default.debug("checkConnectSendNotification local notification not open")
            return
        }
        let nowTime = Int(Date().timeIntervalSince1970)
        switch type {
        case .connected:
            XCGLogger.default.debug("checkConnectSendNotification connected time \(nowTime)")
            setConnectedTime(nowTime)
        case .disconnected:
            XCGLogger.default.debug("checkConnectSendNotification disconnected time \(nowTime)")
            setDisconnectTime(nowTime)
        }
    }
    
    /**
     Local notifications
     
     :param: string Inform the content
     */
    class func LocalNotificationBody(_ string:NSString, delay:Double=0) -> UILocalNotification {
        if (UIDevice.current.systemVersion as NSString).floatValue >= 8.0 {
            let categorys:UIMutableUserNotificationCategory = UIMutableUserNotificationCategory()
            categorys.identifier = "alert";
            //UIUserNotificationType.Badge|UIUserNotificationType.Sound|UIUserNotificationType.Alert
            let localUns:UIUserNotificationSettings = UIUserNotificationSettings(types: [UIUserNotificationType.badge,UIUserNotificationType.sound,UIUserNotificationType.alert], categories: Set(arrayLiteral: categorys))
            UIApplication.shared.registerUserNotificationSettings(localUns)
        }
        
        
        let notification:UILocalNotification=UILocalNotification()
        notification.timeZone = TimeZone.current
        notification.fireDate = Date().addingTimeInterval(delay)
        notification.alertBody=string as String;
        notification.applicationIconBadgeNumber = 0;
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.category = "invite"
        UIApplication.shared.scheduleLocalNotification(notification)
        return notification
    }

}
