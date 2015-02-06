//
//  NevoOTARequest.swift
//  Nevo
//
//  Created by supernova on 15/2/4.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import Foundation
import UIKit

/**

this file include all  OTA request class
*/

//class NevoOTARequest: Request {
//
//}


class SetOTAModeRequest : Request {
    
    let values :[UInt8] = [0x80,0x72,0xA0,0x8A,0x7D,0xDE,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    
    func getTargetProfile() -> Profile {
        return NevoOTAModeProfile()
    }
    
    func getRawData() -> NSData {
        return NSData(bytes: values, length: values.count)
    }
}


class StartOTARequest: Request {
    
    let values :[UInt8] = [DfuOperations.START_DFU_REQUEST.rawValue,DfuFirmwareTypes.APPLICATION.rawValue]
    
    func getTargetProfile() -> Profile {
        return NevoOTAControllerProfile()
    }
    
    func getRawData() -> NSData {
        return NSData(bytes: values, length: values.count)
    }
}

class StartOTAOldRequest: Request {
    
    let values :[UInt8] = [DfuOperations.START_DFU_REQUEST.rawValue,DfuFirmwareTypes.APPLICATION.rawValue]
    
    func getTargetProfile() -> Profile {
        return NevoOTAControllerProfile()
    }
    
    func getRawData() -> NSData {
        return NSData(bytes: values, length: values.count)
    }
}

class writeFileSizeRequest: Request {
    
    var mFilelength:Int?
    
    init(filelength: Int)
    {
        mFilelength = filelength
    }
    func getTargetProfile() -> Profile {
        return NevoOTAPacketProfile()
    }
    
    func getRawData() -> NSData {
        var fileSizeCollection :[UInt32] = [0,0,UInt32(mFilelength!)];
        
        return NSData(bytes: fileSizeCollection, length: fileSizeCollection.count * sizeof(UInt32))
    }
}

class writeFileSizeOldRequest: Request {
    
    var mFilelength:Int?
    
    init(filelength: Int)
    {
        mFilelength = filelength
    }
    func getTargetProfile() -> Profile {
        return NevoOTAPacketProfile()
    }
    
    func getRawData() -> NSData {
        var fileSizeCollection :[UInt32] = [0,0,UInt32(mFilelength!)];
        
        return NSData(bytes: fileSizeCollection, length: fileSizeCollection.count * sizeof(UInt32))
    }
}


class ResetSystemRequest:Request {
    
    let values :[UInt8] = [DfuOperations.RESET_SYSTEM.rawValue]
    
    func getTargetProfile() -> Profile {
        return NevoOTAControllerProfile()
    }
    
    func getRawData() -> NSData {
        return NSData(bytes: values, length: values.count)
    }
}

class EnablePacketNotifyRequest:Request {
    
    let values :[UInt8] = [DfuOperations.PACKET_RECEIPT_NOTIFICATION_REQUEST.rawValue, UInt8(enumPacketOption.PACKETS_NOTIFICATION_INTERVAL.rawValue),0]
    
    func getTargetProfile() -> Profile {
        return NevoOTAControllerProfile()
    }
    
    func getRawData() -> NSData {
        return NSData(bytes: values, length: values.count)
    }
}

class ReceiveFirmwareImageRequest:Request {
    
    let values :[UInt8] = [DfuOperations.RECEIVE_FIRMWARE_IMAGE_REQUEST.rawValue]
    
    func getTargetProfile() -> Profile {
        return NevoOTAControllerProfile()
    }
    
    func getRawData() -> NSData {
        return NSData(bytes: values, length: values.count)
    }
}

class ValidateFirmwareRequest:Request {
    
    let values :[UInt8] = [DfuOperations.VALIDATE_FIRMWARE_REQUEST.rawValue]
    
    func getTargetProfile() -> Profile {
        return NevoOTAControllerProfile()
    }
    
    func getRawData() -> NSData {
        return NSData(bytes: values, length: values.count)
    }
}

class ActivateAndResetRequest:Request {
    
    let values :[UInt8] = [DfuOperations.ACTIVATE_AND_RESET_REQUEST.rawValue]
    
    func getTargetProfile() -> Profile {
        return NevoOTAControllerProfile()
    }
    
    func getRawData() -> NSData {
        return NSData(bytes: values, length: values.count)
    }
}

class OnePacketRequest: Request {
    
    var mPacketData:NSData?
    
    init(packetdata: NSData)
    {
        mPacketData = NSData(data: packetdata)
    }
    func getTargetProfile() -> Profile {
        return NevoOTAPacketProfile()
    }
    
    func getRawData() -> NSData {
        
        return mPacketData!
    }
}