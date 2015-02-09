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
    let mTestHomeController : HomeController
    
    init(controller : HomeController) {

        mTestHomeController = controller
        
        mConnectionController = ConnectionControllerImpl.sharedInstance
        
        mConnectionController?.setDelegate(self)
        
        mConnectionController?.connect()
    }
    
    func setGoal(goal:Goal) {
        mConnectionController?.sendRequest(SetGoalRequest(goal: goal))
    }
    
    func packetReceived(packet:RawPacket) {
        var alert = UIAlertController(title: "Received", message: "Message : "+hexString(packet.getRawData()), preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
        mTestHomeController.presentViewController(alert, animated: true, completion: nil)
    }
    
    func connectionStateChanged(isConnected : Bool) {
        
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