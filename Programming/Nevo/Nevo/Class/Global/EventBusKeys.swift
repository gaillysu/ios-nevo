//
//  Keys.swift
//  Drone
//
//  Created by leiyuncun on 16/3/15.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import Foundation

/// Cases: SwiftEventBus.post(RAWPACKET_DATA_KEY, sender:packet as! RawPacketImpl)
let EVENT_BUS_RAWPACKET_DATA_KEY:String = "EVENT_BUS_RAWPACKET_DATA_KEY"
/// Cases: SwiftEventBus.post(CONNECTION_STATE_CHANGED_KEY, sender:Bool<Bluetooth state>)
let EVENT_BUS_CONNECTION_STATE_CHANGED_KEY:String = "EVENT_BUS_CONNECTION_STATE_CHANGED_KEY"
/// Cases: SwiftEventBus.post(FIRMWARE_VERSION_RECEIVED_KEY, sender:whichfirmware==DfuFirmwareTypes.APPLICATION ? ["BLE":Received the firmware version]:["MCU":Received the firmware version])
let EVENT_BUS_FIRMWARE_VERSION_RECEIVED_KEY:String = "EVENT_BUS_FIRMWARE_VERSION_RECEIVED_KEY"
/// Cases: SwiftEventBus.post(RECEIVED_RSSI_VALUE_KEY, sender:<bluetooth signal value format:NSNumber>)
let EVENT_BUS_RECEIVED_RSSI_VALUE_KEY:String = "EVENT_BUS_RECEIVED_RSSI_VALUE_KEY"
/// Cases: SwiftEventBus.post(GET_SYSTEM_STATUS_KEY, sender:packet as! RawPacketImpl)
let EVENT_BUS_GET_SYSTEM_STATUS_KEY:String = "EVENT_BUS_GET_SYSTEM_STATUS_KEY"
/// Cases: SwiftEventBus.post(GOAL_COMPLETED, sender:nil)
let EVENT_BUS_GOAL_COMPLETED:String = "EVENT_BUS_GOAL_COMPLETED"
///get watch the data  Cases:let bigData:[String:Int] = ["timerInterval":timerInterval,"dailySteps":dailySteps] SwiftEventBus.post(BIG_SYNCACTIVITY_DATA, sender:bigData)
let EVENT_BUS_BIG_SYNCACTIVITY_DATA:String = "EVENT_BUS_BIG_SYNCACTIVITY_DATA"
///Will be big sync activity data. Cases: SwiftEventBus.post(BEGIN_BIG_SYNCACTIVITY, sender:nil)
let EVENT_BUS_BEGIN_BIG_SYNCACTIVITY:String = "EVENT_BUS_BEGIN_BIG_SYNCACTIVITY"
///end big sync activity data. Cases: SwiftEventBus.post(END_BIG_SYNCACTIVITY, sender:nil)
let EVENT_BUS_END_BIG_SYNCACTIVITY:String = "EVENT_BUS_END_BIG_SYNCACTIVITY"
///Will be small sync activity data. Cases: SwiftEventBus.post(BEGIN_SMALL_SYNCACTIVITY, sender:nil)
let EVENT_BUS_BEGIN_SMALL_SYNCACTIVITY:String = "EVENT_BUS_BEGIN_SMALL_SYNCACTIVITY" //Will be small sync activity data
///get small the data  Cases:let stepsDict:[String:Int] = ["dailySteps":dailySteps,"goal":goal] SwiftEventBus.post(SMALL_SYNCACTIVITY_DATA, sender:bigData)
let EVENT_BUS_SMALL_SYNCACTIVITY_DATA:String = "EVENT_BUS_SMALL_SYNCACTIVITY_DATA"
///Battery change prompts Cases: SwiftEventBus.post(BATTERY_STATUS_CHANGED, sender:<battery value>)
let EVENT_BUS_BATTERY_STATUS_CHANGED:String = "EVENT_BUS_BATTERY_STATUS_CHANGED"
let EVENT_BUS_RSSI_VALUE:String = "EVENT_BUS_RSSI_VALUE"

/// Cases:
let EVENT_BUS_WATCHID_DIDCHANGE_KEY:String = "EVENT_BUS_WATCHID_DIDCHANGE_KEY"

let TODAY_DATE_CACHE = "TODAY_DATE_CACHE"
