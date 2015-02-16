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
 
    let mConnectionController : ConnectionController?
    //TODO by Hugo remove
    let mTestHomeController : UIViewController
    private var packetsbuffer:[NSData]
    
    init(controller : UIViewController,forceScan :Bool) {

        mTestHomeController = controller
        packetsbuffer = []
        mConnectionController = ConnectionControllerImpl.sharedInstance
        
        mConnectionController?.setDelegate(self)
        
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
        
        if( isConnected )
        {
         //  NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("setRTC"), userInfo: nil, repeats: false)
            var dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                self.setRTC()
            })
            
        }
    }

    //TODO by Hugo remove
    func sendRawPacket() {
        var inputTextField:UITextField?
        
        var alert = UIAlertController(title: "Send", message: " ", preferredStyle: UIAlertControllerStyle.Alert)
        
        
        
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler:
       
            { (action) -> Void in
                // Now do whatever you want with inputTextField (remember to unwrap the optional)
                
                // Do something witht he inputTextField.text
                
                self.mConnectionController!.sendRequest(TestQuery(hex: inputTextField!.text))
                
            }
        
        ))
        
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Enter text:"
            inputTextField = textField
        })
        mTestHomeController.presentViewController(alert, animated: true, completion: nil)
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

//TODO by Hugo remove
class TestQuery : Request {
    var mString:NSString
    
    init (hex:NSString) {
    mString = hex
    }
    
    func getTargetProfile() -> Profile {
        return NevoProfile()
    }
    func getRawData() -> NSData {
       return self.dataFromHexadecimalString()!
    }
    func getRawDataEx() -> NSArray {
        return NSArray()
    }
    func dataFromHexadecimalString() -> NSData? {
        let trimmedString = mString.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<> ")).stringByReplacingOccurrencesOfString(" ", withString: "")
        
        // make sure the cleaned up string consists solely of hex digits, and that we have even number of them
        
        var error: NSError?
        let regex = NSRegularExpression(pattern: "^[0-9a-f]*$", options: .CaseInsensitive, error: &error)
        let found = regex?.firstMatchInString(trimmedString, options: nil, range: NSMakeRange(0, countElements(trimmedString)))
        if found == nil || found?.range.location == NSNotFound || countElements(trimmedString) % 2 != 0 {
            return nil
        }
        
        // everything ok, so now let's build NSData
        
        let data = NSMutableData(capacity: countElements(trimmedString) / 2)
        
        for var index = trimmedString.startIndex; index < trimmedString.endIndex; index = index.successor().successor() {
            let byteString = trimmedString.substringWithRange(Range<String.Index>(start: index, end: index.successor().successor()))
            let num = Byte(byteString.withCString { strtoul($0, nil, 16) })
            data?.appendBytes([num] as [Byte], length: 1)
        }
        
        return data
    }
}


protocol SyncControllerDelegate {

    /**
    Called when a peripheral connects or disconnects
    */
    func connectionStateChanged(isConnected : Bool)
}