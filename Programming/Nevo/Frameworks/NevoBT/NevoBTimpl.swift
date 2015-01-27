//
//  NevoBT.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation
import CoreBluetooth

/*
See NevoBT protocol
🚧🚧🚧Backbone Class : Modify with care🚧🚧🚧
*/
class NevoBTImpl : NSObject, NevoBT, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    /**
    The scanning time is 10 sec
    */
    let SCANNING_DURATION : NSTimeInterval = 10.000
    
    /**
    Gets notified when a periphare connects/disconnects and when we receive data
    */
    private let mDelegate : NevoBTDelegate
    
    /**
    The central manager, we have to save it
    */
    private let mManager : CBCentralManager?
    
    /**
    The connected peripheral
    only one peripheral can be connected at a time
    */
    private var mPeripheral : CBPeripheral?
    
    /**
    The GATT profile we are looking for
    */
    private let mProfile : Profile
    
    /**
    The Stop scan timer
    */
    private var mTimer : NSTimer?
    
    
    
    /**
    Basic constructor, just a Delegate handsake
    */
    init(externalDelegate : NevoBTDelegate, acceptableDevice : Profile) {
        
        mDelegate = externalDelegate
        
        mProfile = acceptableDevice
        
        super.init()
        
        mManager=CBCentralManager(delegate:self, queue:nil)
        
        mManager?.delegate = self
        
        
    }
    
    /**
    See NevoBT protocol
    */
    func scanAndConnect() {
        
        if(self.isLECapableHardware()) {
            
            var services:[AnyObject] = [mProfile.CONTROL_SERVICE]
            
            //No address was specified, we'll search for devices with the right profile.
    
            //We'll try to connect to both known and nearby devices
    
            
            //Here we search for all nearby devices
            //We can't just search for all services, because that's not allowed when the app is in the background
            mManager?.scanForPeripheralsWithServices(services,options:nil)
            
            NSLog("Scan started.")
            
            
            //The scan will stop X sec later
            //We scehduele or re-schdeuele the stop scanning
            mTimer?.invalidate()
            
            mTimer = NSTimer.scheduledTimerWithTimeInterval(SCANNING_DURATION, target: self, selector: Selector("stopScan"), userInfo: nil, repeats: false)
            
            
            
            //Here, we search for known devices
            var systemConnected = mManager?.retrieveConnectedPeripheralsWithServices(services) as [CBPeripheral]
            
            
            for peripheral in systemConnected {
                
                if (peripheral.state == CBPeripheralState.Disconnected) {
                    
                    //The given devices are known to the system and disconnected
                    //With a bit of luck the device is nearby and available
                    self.matchingPeripheralFound(peripheral)
                    
                }
            }

    
        }

    }
    
    /**
    See NevoBT protocol
    */
    func connectToAddress(peripheralAddress : String) {
      //TODO
    }
    
    /**
    Stops the current scan
    */
    func stopScan() {
        mManager?.stopScan()
        
        NSLog("Scan stopped.")
        
        mDelegate.scanStopped()
        
    }
    
    /**
    Invoked whenever the central manager's state is updated.
    */
    func centralManagerDidUpdateState(central : CBCentralManager) {
        self.isLECapableHardware()
    }
    
    /**
    Invoked when the central discovers a compatible device while scanning.
    */
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
    
        self.matchingPeripheralFound(peripheral)
    
    }
    
    /**
    This peripheral is a good candidate, it has the right Services and hence we try to connect to it
    */
    private func matchingPeripheralFound( aPeripheral : CBPeripheral ){

        NSLog("Connecting to :\(aPeripheral.description)")
        
        //If it's not connected already, let's connect to it
        if(aPeripheral.state==CBPeripheralState.Disconnected){

            mManager?.connectPeripheral(aPeripheral,options:[CBConnectPeripheralOptionNotifyOnDisconnectionKey:true])
            
        }
    
    }
        
    /**
    Invoked whenever a connection is succesfully created with the peripheral.
    Discover available services on the peripheral and notifies our delegate
    */
    func centralManager(_ central: CBCentralManager!, didConnectPeripheral aPeripheral: CBPeripheral!) {
        
        NSLog("Peripheral connected : \(aPeripheral.name)")
        
        //First, we forget the previous peripheral
        mPeripheral?.delegate = nil
        
        aPeripheral.delegate = self
        aPeripheral.discoverServices(nil)
        
        mPeripheral = aPeripheral
        
        mDelegate.connectionStateChanged(true)
        
    }

    /*
    Invoked upon completion of a -[discoverServices:] request.
    Discover available characteristics on interested services
    */
    func peripheral(_ aPeripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
    
        //Our aim is to subscribe to the callback characteristic, so we'll have to find it in the control service
    
        for aService:CBService in aPeripheral.services as [CBService] {
            NSLog("Service found with UUID : \(aService.UUID.UUIDString)")
    
            if (aService.UUID == mProfile.CONTROL_SERVICE) {
                aPeripheral.discoverCharacteristics(nil,forService:aService)
            }
        }
    }
    
    /*
    Invoked upon completion of a -[discoverCharacteristics:forService:] request.
    Perform appropriate operations on interested characteristics
    */
    func peripheral(aPeripheral:CBPeripheral!, didDiscoverCharacteristicsForService service:CBService!, error error :NSError!) {
    
        NSLog("Service : \(service.UUID.description)")
    
        for aChar:CBCharacteristic in service.characteristics as [CBCharacteristic] {
            
            if(aChar==mProfile.CALLBACK_CHARACTERISTIC ) {
                mPeripheral?.setNotifyValue(true,forCharacteristic:aChar)
            
                NSLog("Callback char : \(aChar.UUID.UUIDString)")
            }
            
        }
      
    
    }
    
    /*
    Invoked upon completion of a -[readValueForCharacteristic:] request or on the reception of a notification/indication.
    */
    func peripheral(aPeripheral:CBPeripheral!, didUpdateValueForCharacteristic characteristic:CBCharacteristic!, error error :NSError!) {
        
        //We received a value, if it did came from the calllback char, let's return it
        if (characteristic.UUID==mProfile.CALLBACK_CHARACTERISTIC)
        {
            
            if error == nil && characteristic.value != nil && aPeripheral.identifier != nil {
                NSLog("Received : \(characteristic.UUID.UUIDString) \(hexString(characteristic.value))")
                
                /* It is valid data, let's return it to our delegate */
                mDelegate.packetReceived( RawPacketImpl(data: characteristic.value , address: aPeripheral.identifier , profile: mProfile) )
            }
        }
    

    }
    
    /*
    Invoked upon completion of a -[writeValueForCharacteristic:] request
    */
    func peripheral(_peripheral:CBPeripheral!, didWriteValueForCharacteristic characteristic:CBCharacteristic!, error error :NSError!) {
    
        if (error != nil) {
            NSLog("Failed to write value for characteristic \(characteristic), reason: \(error)")
        } else {
            NSLog("Did write value for characterstic \(characteristic), new value: \(characteristic.value)")
        }

    }
    
    /**
    See NevoBT protocol
    */
    func sendRequest(request:Request) {

        if( mPeripheral != nil ){
            
            if( mProfile.CALLBACK_CHARACTERISTIC != request.getTargetProfile().CALLBACK_CHARACTERISTIC ) {
                //We didn't subscribe to this profile's CallbackCharacteristic, there have to be a mistake somewhere
                NSLog("The target profile is incompatible with the profile given on this NevoBT's initalisation.")
                return ;
            }
    
            //Let's assume that you have already discovered the services
            for service:CBService in mPeripheral!.services as [CBService] {
                
                if(service.UUID == request.getTargetProfile().CONTROL_SERVICE) {
                    
                    for charac:CBCharacteristic in service.characteristics as [CBCharacteristic] {
                        
                        if(charac.UUID == request.getTargetProfile().CONTROL_CHARACTERISTIC) {
    
                            NSLog("Request raw data :\(request.getRawData())")

                            mPeripheral?.writeValue(request.getRawData(),forCharacteristic:charac,type:CBCharacteristicWriteType.WithoutResponse)
                        }
                    }
                }
            }

        }
    }
    
    /**
    See NevoBT protocol
    */
    func disconnect() {

        mPeripheral?.delegate = nil
        
        mManager?.cancelPeripheralConnection(mPeripheral)

        mPeripheral = nil
    }

    /**
    Invoked whenever an existing connection with the peripheral is torn down.
    Reset local variables and notifies our delegate
    */
    func centralManager(_ central: CBCentralManager!, didDisconnectPeripheral aPeripheral: CBPeripheral!, error error : NSError!) {
    
        NSLog("Peripheral disconnected : \(aPeripheral.name)")
    
        if(error != nil) {
            NSLog("Error : \(error.localizedDescription) for peripheral : \(aPeripheral.name)")
        }
    

        mPeripheral?.delegate = nil

    
        mPeripheral = nil
    
        mDelegate.connectionStateChanged(false)
    
    }
    
    /**
    See NevoBT protocol
    */
    func isConnected() -> Bool {
        //TODO
        return true
    }

    /**
    Uses CBCentralManager to check whether the current platform/hardware supports Bluetooth LE. An alert is raised if Bluetooth LE is not enabled or is not supported.
    */
    private func isLECapableHardware() -> Bool {
        if(mManager == nil) {
            return false
        }
        
        switch (mManager!.state)
        {
        
        case CBCentralManagerState.PoweredOn:
            return true
        
        case CBCentralManagerState.Unsupported:
            NSLog("The platform/hardware doesn't support Bluetooth Low Energy.")
            break
        
        case CBCentralManagerState.Unauthorized:
            NSLog("The app is not authorized to use Bluetooth Low Energy.")
            break
        
        case CBCentralManagerState.PoweredOff:
            NSLog("Bluetooth is currently powered off.")
            break
        
        default:
            NSLog("Unknown device state")
            break
        
        }
    
    
        return false
    }
    
    /**
    Converts a binary value to HEX
    */
    private func hexString(data:NSData) -> NSString {
        var str = NSMutableString()
        let bytes = UnsafeBufferPointer<UInt8>(start: UnsafePointer(data.bytes), count:data.length)
        for byte in bytes {
            str.appendFormat("%02hhx", byte)
        }
        return str
    }

}