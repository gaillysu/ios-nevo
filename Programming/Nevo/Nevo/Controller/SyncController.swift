//
//  SyncController.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation
import UIKit

/*
The sync controller handles all the very high level connection workflow
It checks that the firmware is up to date, and handles every steps of the synchronisation process
*/

class SyncController: ConnectionControllerDelegate {
    
    var mDelegate:SyncControllerDelegate
 
    let mConnectionController : ConnectionController?
    //TODO by Hugo remove
    let mTestHomeController : UIViewController
    private var packetsbuffer:[NSData]
    
    init(controller : UIViewController,forceScan :Bool, delegate:SyncControllerDelegate) {

        mDelegate = delegate
        
        mTestHomeController = controller
        packetsbuffer = []
        mConnectionController = ConnectionControllerImpl.sharedInstance
        
        mConnectionController?.addDelegate(self)
        
        if forceScan
        {
            mConnectionController?.forgetSavedAddress()
        }
        mConnectionController?.connect()
    }
    
    //add new functions when  get connected Nevo
    func setRTC() {
        mConnectionController?.sendRequest(SetRTCRequest())
    }
    
    func SetProfile() {
        mConnectionController?.sendRequest(SetProfileRequest())
    }
    func SetCardio() {
        mConnectionController?.sendRequest(SetCardioRequest())
    }
    
    func WriteSetting() {
        mConnectionController?.sendRequest(WriteSettingRequest())
    }
    //end functions for connected to Nevo
    
    //below functions by UI
    func setGoal(goal:Goal) {
        mConnectionController?.sendRequest(SetGoalRequest(goal: goal))
    }
    
    func setAlarm(alarmhour:Int,alarmmin:Int,alarmenable:Bool) {
        mConnectionController?.sendRequest(SetAlarmRequest(hour:alarmhour,min: alarmmin,enable: alarmenable))
    }

    func SetNortification() {
        mConnectionController?.sendRequest(SetNortificationRequest())
    }
    //end functions by UI
    
    func packetReceived(packet:RawPacket) {
        
        packetsbuffer.append(packet.getRawData())
        if(NSData2Bytes(packet.getRawData())[0] == 0xFF)
        {
            /*
        var data:NSData!
        var message :String = ""
            
        for data in packetsbuffer
        {
            message = message + "\r\n"+hexString(data)
        }
            var alert = UIAlertController(title: "Received", message: "Message : "+message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
            mTestHomeController.presentViewController(alert, animated: true, completion: nil)
            */
            if(NSData2Bytes(packet.getRawData())[1] == 0x01)
            {
                self.SetProfile()
            }
            if(NSData2Bytes(packet.getRawData())[1] == 0x20)
            {
                self.WriteSetting()
            }
            
            if(NSData2Bytes(packet.getRawData())[1] == 0x21)
            {
                self.SetCardio()
            }
            
            packetsbuffer = []
        }
    }
    
    func connectionStateChanged(isConnected : Bool) {
        
        NSLog("State changed : \(isConnected) To delegate  : \(mDelegate)")
        
        mDelegate.connectionStateChanged(isConnected)
        
        if( isConnected )
        {
         //  NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("setRTC"), userInfo: nil, repeats: false)
            var dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                self.setRTC()
            })
            
        }
    }
    
    func connect() {
        self.mConnectionController?.connect()
    }
    
    func isConnected() -> Bool{
        if let connContr = mConnectionController {
            return connContr.isConnected()
        }
        return false
    }
    
    //TODO by Hugo remove
    private func hexString(data:NSData) -> NSString {
        var str = NSMutableString()
        let bytes = UnsafeBufferPointer<UInt8>(start: UnsafePointer(data.bytes), count:data.length)
        for byte in bytes {
            str.appendFormat("%02hhx", byte)
        }
        return str
    }
    
}


protocol SyncControllerDelegate {

    /**
    Called when a peripheral connects or disconnects
    */
    func connectionStateChanged(isConnected : Bool)
}