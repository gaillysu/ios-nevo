//
//  Utility.swift
//  Nevo
//
//  Created by supernova on 15/2/4.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import Foundation


struct DFUResponse
{
    var responseCode:UInt8;
    var requestedCode:UInt8;
    var responseStatus:UInt8;
}

enum  enumFileExtension: UInt8 {
    case hex,zip,bin
}

enum  enumPacketOption: Int{
    case packets_NOTIFICATION_INTERVAL = 10,
    packet_SIZE = 20
}

enum DfuOperations :UInt8 {
    case start_DFU_REQUEST = 0x01,
    initialize_DFU_PARAMETERS_REQUEST = 0x02,
    receive_FIRMWARE_IMAGE_REQUEST = 0x03,
    validate_FIRMWARE_REQUEST = 0x04,
    activate_AND_RESET_REQUEST = 0x05,
    reset_SYSTEM = 0x06,
    packet_RECEIPT_NOTIFICATION_REQUEST = 0x08,
    response_CODE = 0x10,
    packet_RECEIPT_NOTIFICATION_RESPONSE = 0x11
    
}

enum DfuOperationStatus:UInt8{
    case operation_SUCCESSFUL_RESPONSE = 0x01,
    operation_INVALID_RESPONSE = 0x02,
    operation_NOT_SUPPORTED_RESPONSE = 0x03,
    data_SIZE_EXCEEDS_LIMIT_RESPONSE = 0x04,
    crc_ERROR_RESPONSE = 0x05,
    operation_FAILED_RESPONSE = 0x06
    
}

enum DFUControllerState:Int
{
    case inittialize = 0,
    discovering,
    idle,
    send_NOTIFICATION_REQUEST,
    send_START_COMMAND,
    send_RECEIVE_COMMAND,
    send_FIRMWARE_DATA,
    send_VALIDATE_COMMAND,
    send_RESET,
    wait_RECEIPT,
    finished,
    canceled,
    send_RECONNECT
}

enum DfuFirmwareTypes:UInt8{
    case  softdevice = 0x01,
    bootloader = 0x02,
    softdevice_AND_BOOTLOADER = 0x03,
    application = 0x04
}

func Bytes2NSData(_ bytes:[UInt8]) -> Data
{
  return Data(bytes: UnsafePointer<UInt8>(bytes), count: bytes.count)
}
func NSData2Bytes(_ data:Data) -> [UInt8]
{
    let bytes = UnsafeBufferPointer<UInt8>(start: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count), count:data.count)
    
    var ret:[UInt8] = []
    for  byte in bytes {
        ret.append(byte)
    }
    return ret
}


func NSData2NSString(_ data:Data) -> NSString {
    let str:NSMutableString = NSMutableString()
    let bytes = UnsafeBufferPointer<UInt8>(start: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count), count:data.count)
    for byte in bytes {
        str.appendFormat("%02hhx", byte)
    }
    return str
}

/**
transfer GMT NSDate to locale NSDate
*/
func GmtNSDate2LocaleNSDate(_ gmtDate:Date) ->Date
{
    let sourceTimeZone:TimeZone = TimeZone(identifier: "UTC")!
    let destinationTimeZone:TimeZone = TimeZone.autoupdatingCurrent
    let sourceGMTOffset:Int = sourceTimeZone.secondsFromGMT(for: gmtDate)
    let destinationGMTOffset:Int = destinationTimeZone.secondsFromGMT(for: gmtDate)
    let interval:TimeInterval = TimeInterval(destinationGMTOffset) - TimeInterval(sourceGMTOffset)
    let destinationDateNow:Date = Date(timeInterval: interval, since: gmtDate)
    return destinationDateNow
}

