//
//  NevoOtaController.swift
//  Nevo
//
//  Created by supernova on 15/2/3.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

/**

this file is main OTA controller
usage: 
var mNevoOtaController : NevoOtaController?
mNevoOtaController = NevoOtaController(controller: self)


*/

import Foundation


class NevoOtaController : ConnectionControllerDelegate {
    let mDelegate : NevoOtaControllerDelegate?
    let mConnectionController : ConnectionController?
    var isOTAmode : Bool = false
    var dfuFirmwareType : DfuFirmwareTypes = DfuFirmwareTypes.APPLICATION
    private var mPacketsbuffer:[NSData]=[]
    private var binFileSize:Int = 0
    private var uploadTimeInSeconds:Int = 0
    private var firmwareFile :NSURL?
    private var dfuResponse:DFUResponse
    
    private var binFileData:NSData?
    private var numberOfPackets:Int = 0
    private var bytesInLastPacket:Int = 0
    private var writingPacketNumber :Int = 0
    
    //added for MCU OTA
    
    /**
    MCU page struct: total 5 packets, as below:
    
    app --> BLE
    0071................... header
    0171................... 18 bytes from firmware
    0271................... 18 bytes from firmware
    0371................... 18 bytes from firmware
    FF71...........00000000 10 bytes from firmware
    
    BLE --> app
    0071
    FF71
    */
    let DFUCONTROLLER_MAX_PACKET_SIZE = 18
    let DFUCONTROLLER_PAGE_SIZE = 64
    //one page has 5 packets
    let notificationPacketInterval = 5
    private var state:DFUControllerState = DFUControllerState.IDLE
    private var firmwareDataBytesSent:Int = 0
    private var progress = 0.0
    private var curpage:Int = 0
    private var totalpage:Int = 0
    private  var checksum:Int = 0
    //end added
    
    init(controller : NevoOtaViewController) {
        
        dfuResponse = DFUResponse(responseCode: 0,requestedCode: 0,responseStatus: 0)
        
        mDelegate = controller
        mConnectionController = ConnectionControllerImpl.sharedInstance
        
        mConnectionController?.setDelegate(self)
        
        mConnectionController?.connect()

    }
    private func openFile(fileURL:NSURL)
    {
        var selectedFileName:NSString  = fileURL.lastPathComponent!
        var filetype:NSString = selectedFileName.substringFromIndex(selectedFileName.length - 3)
        
        NSLog("selected file extension is \(filetype)")
        
        if filetype == "hex"
        {
            var hexFileData :NSData = NSData(contentsOfURL: fileURL)!;
            if (hexFileData.length > 0) {
                convertHexFileToBin(hexFileData)
            }
            else {
                NSLog("Error: file is empty!");
                var errorMessage = "Error on openning file\n Message: file is empty or not exist";
                mDelegate?.onError(errorMessage)
            }
        }
        else
        {
            MCU_openfirmware(fileURL)
        }
    }
    
    private func convertHexFileToBin(hexFileData:NSData)
    {
    binFileData = IntelHex2BinConverter.convert(hexFileData)
    NSLog("HexFileSize: \(hexFileData.length) and BinFileSize: \(binFileData?.length)")
        
    numberOfPackets =  (binFileData?.length)! / enumPacketOption.PACKET_SIZE.rawValue
    
    bytesInLastPacket = ((binFileData?.length)! % enumPacketOption.PACKET_SIZE.rawValue);
    if (bytesInLastPacket == 0) {
        bytesInLastPacket = enumPacketOption.PACKET_SIZE.rawValue;
    }
    NSLog("Number of Packets \(numberOfPackets) Bytes in last Packet \(bytesInLastPacket)")
    writingPacketNumber = 0

    binFileSize = (binFileData?.length)!
    dfuFirmwareType = DfuFirmwareTypes.APPLICATION
    }
    
    private func writeNextPacket()
    {
    
    var percentage :Int = 0;
    for (var index:Int = 0; index<Int(enumPacketOption.PACKETS_NOTIFICATION_INTERVAL.rawValue); index++) {
    if (self.writingPacketNumber > self.numberOfPackets-2) {
        NSLog("writing last packet");
        var dataRange : NSRange = NSMakeRange(self.writingPacketNumber*enumPacketOption.PACKET_SIZE.rawValue, self.bytesInLastPacket);
        var nextPacketData : NSData = (binFileData?.subdataWithRange(dataRange))!
        
        NSLog("writing packet number %d ...",self.writingPacketNumber+1);
        NSLog("packet data: %@",nextPacketData);
        
        mConnectionController?.sendRequest(OnePacketRequest(packetdata: nextPacketData ))
        
        self.writingPacketNumber++;
        NSLog("DFUOperations: onAllPacketsTransfered");
        break;

    }
    var dataRange : NSRange = NSMakeRange(self.writingPacketNumber*enumPacketOption.PACKET_SIZE.rawValue, enumPacketOption.PACKET_SIZE.rawValue);
        
    var    nextPacketData : NSData  = (self.binFileData?.subdataWithRange(dataRange))!
    NSLog("writing packet number %d ...",self.writingPacketNumber+1);
    NSLog("packet data: %@",nextPacketData);
        
    mConnectionController?.sendRequest(OnePacketRequest(packetdata: nextPacketData ))
  
    percentage = Int(Double(self.writingPacketNumber * enumPacketOption.PACKET_SIZE.rawValue) / Double(self.binFileSize) * 100.0)
        
    NSLog("DFUOperations: onTransferPercentage %d",percentage);
    mDelegate?.onTransferPercentage(percentage)
    
    self.writingPacketNumber++;
    
    }
    
    }

    private func startSendingFile()
    {
        NSLog("DFUOperationsdetails enablePacketNotification");
        mConnectionController?.sendRequest(EnablePacketNotifyRequest())
        NSLog("DFUOperationsdetails receiveFirmwareImage");
        mConnectionController?.sendRequest(ReceiveFirmwareImageRequest())
  
        writeNextPacket()
        
        mDelegate?.onDFUStarted()
    }
    
    private func resetSystem()
    {
    NSLog("DFUOperationsDetails resetSystem");
    mConnectionController?.sendRequest(ResetSystemRequest())
    }
    
    private func validateFirmware()
    {
         NSLog("DFUOperationsDetails validateFirmware");
         mConnectionController?.sendRequest(ValidateFirmwareRequest())
    }
    private func activateAndReset()
    {
        NSLog("DFUOperationsDetails activateAndReset");
        mConnectionController?.sendRequest(ActivateAndResetRequest())

    }

    private func responseErrorMessage(errorCode:DfuOperationStatus.RawValue) ->NSString
    {
    switch (errorCode) {
    case DfuOperationStatus.OPERATION_FAILED_RESPONSE.rawValue:
    return NSString(string:"Operation Failed");
 
    case DfuOperationStatus.OPERATION_INVALID_RESPONSE.rawValue:
    return NSString(string:"Invalid Response");

    case DfuOperationStatus.OPERATION_NOT_SUPPORTED_RESPONSE.rawValue:
    return NSString(string:"Operation Not Supported");
  
    case DfuOperationStatus.DATA_SIZE_EXCEEDS_LIMIT_RESPONSE.rawValue:
    return NSString(string:"Data Size Exceeds");

    case DfuOperationStatus.CRC_ERROR_RESPONSE.rawValue:
    return NSString(string:"CRC Error");

    default:
    return NSString(string:"unknown Error");

    }
    }
    
    private func processRequestedCode()
    {
    NSLog("processsRequestedCode");
    switch (dfuResponse.requestedCode) {
    case DfuOperations.START_DFU_REQUEST.rawValue:
    NSLog("Requested code is StartDFU now processing response status");
    processStartDFUResponseStatus()
    break;
    case DfuOperations.RECEIVE_FIRMWARE_IMAGE_REQUEST.rawValue:
    NSLog("Requested code is Receive Firmware Image now processing response status");
    processReceiveFirmwareResponseStatus()
    break;
    case DfuOperations.VALIDATE_FIRMWARE_REQUEST.rawValue:
    NSLog("Requested code is Validate Firmware now processing response status");
    processValidateFirmwareResponseStatus()
    break;
    
    default:
    NSLog("invalid Requested code in DFU Response %d",dfuResponse.requestedCode);
    break;
    }
    }
    
    private func processStartDFUResponseStatus()
    {
    NSLog("processStartDFUResponseStatus");
    var errorMessage:NSString = "Error on StartDFU\n Message: \(responseErrorMessage(dfuResponse.responseStatus))"
    switch (dfuResponse.responseStatus) {
    case DfuOperationStatus.OPERATION_SUCCESSFUL_RESPONSE.rawValue:
    NSLog("successfully received startDFU notification");
    startSendingFile()
    break;
    case DfuOperationStatus.OPERATION_NOT_SUPPORTED_RESPONSE.rawValue:
       NSLog("device has old DFU. switching to old DFU ...");
       performOldDFUOnFile()
    break;
    
    default:
    NSLog("StartDFU failed, Error Status: \(responseErrorMessage(dfuResponse.responseStatus))");
    mDelegate?.onError(errorMessage)
    resetSystem()
    break;
    }
    }
    
    private func processReceiveFirmwareResponseStatus()
    {
    NSLog("processReceiveFirmwareResponseStatus");
    if (dfuResponse.responseStatus == DfuOperationStatus.OPERATION_SUCCESSFUL_RESPONSE.rawValue) {
    NSLog("successfully received notification for whole File transfer");
    validateFirmware()
    }
    else {
    NSLog("Firmware Image failed, Error Status: \(responseErrorMessage(dfuResponse.responseStatus))");
    var errorMessage = "Error on Receive Firmware Image\n Message: \(responseErrorMessage(dfuResponse.responseStatus))";
    mDelegate?.onError(errorMessage)
    resetSystem()
    }
    }
    
    private func processValidateFirmwareResponseStatus()
    {
        NSLog("processValidateFirmwareResponseStatus");
        if (dfuResponse.responseStatus == DfuOperationStatus.OPERATION_SUCCESSFUL_RESPONSE.rawValue) {
            NSLog("succesfully received notification for ValidateFirmware");
            activateAndReset()
            mDelegate?.onSuccessfulFileTranferred()
    }
    else {
        NSLog("Firmware validate failed, Error Status: \( responseErrorMessage(dfuResponse.responseStatus))");
        var errorMessage = "Error on Validate Firmware Request\n Message: \(responseErrorMessage(dfuResponse.responseStatus))";
        mDelegate?.onError(errorMessage)
        resetSystem()
    }
    }
    
    private func processPacketNotification()
    {
        NSLog("received Packet Received Notification");
        if (writingPacketNumber < numberOfPackets) {
            writeNextPacket()
        }
    }

    private func setDFUResponseStruct(data:[UInt8])
    {
        dfuResponse.responseCode = data[0]
        dfuResponse.requestedCode = data[1]
        dfuResponse.responseStatus = data[2]
    }
    
    private func processDFUResponse(data :[UInt8])
    {
        NSLog("processDFUResponse");
        setDFUResponseStruct(data)
        
        if (dfuResponse.responseCode == DfuOperations.RESPONSE_CODE.rawValue) {
            processRequestedCode()
        }
        else if(dfuResponse.responseCode == DfuOperations.PACKET_RECEIPT_NOTIFICATION_RESPONSE.rawValue) {
            processPacketNotification()
        }
    }
    
    /*
    see ConnectionControllerDelegate protocol
    */
    func packetReceived(packet:RawPacket) {
        
        if(dfuFirmwareType == DfuFirmwareTypes.APPLICATION)
        {
            processDFUResponse(NSData2Bytes(packet.getRawData()))
        }
        
        else if(dfuFirmwareType == DfuFirmwareTypes.SOFTDEVICE)
        {
            MCU_processDFUResponse(packet)
        }
    }
    /*
    see ConnectionControllerDelegate protocol
    */
    func connectionStateChanged(isConnected : Bool) {
        if isConnected
        {
            if !isOTAmode
            {
             mConnectionController?.sendRequest(SetOTAModeRequest())
            }
            else
            {
                //no need let view controller know connection change
                //mDelegate?.connectionStateChanged(true)
            }
        }
        else
        {
            if !isOTAmode
            {
            isOTAmode = true
            mConnectionController?.setOTAMode(true)

            //disconnect by entry OTA mode, again connect it,
            //    ConnectionControllerImpl.connectionStateChanged will auto called, so here
            //    not call connect()
           // mConnectionController?.connect()
            }
        }
    }
    
    func performDFUOnFile(firmwareURL:NSURL , firmwareType:DfuFirmwareTypes)
    {
        dfuFirmwareType = firmwareType
        firmwareFile = firmwareURL
        //Hex to bin and read it to buffer
        openFile(firmwareURL)
        //enable it done after doing discover service
        //[dfuRequests enableNotification];
        if(dfuFirmwareType == DfuFirmwareTypes.APPLICATION)
        {
        mConnectionController?.sendRequest(StartOTARequest())
        mConnectionController?.sendRequest(writeFileSizeRequest(filelength: binFileSize))
        }
        else if(dfuFirmwareType == DfuFirmwareTypes.SOFTDEVICE)
        {
            state = DFUControllerState.SEND_START_COMMAND
            mConnectionController?.sendRequest(Mcu_SetOTAModeRequest())
        }
    }
    
    private func performOldDFUOnFile()
    {
        if (self.dfuFirmwareType == DfuFirmwareTypes.APPLICATION)
        {
            openFile(firmwareFile!)
            mConnectionController?.sendRequest(StartOTAOldRequest())
            mConnectionController?.sendRequest(writeFileSizeOldRequest(filelength: binFileSize))
        }
        else
        {
            var errorMessage :NSString  = "Old DFU only supports Application upload"
            mDelegate?.onError(errorMessage)
            resetSystem()
        }
        
        
    }
    
    func cancelDFU()
    {
        NSLog("cancelDFU");
        
        if (self.dfuFirmwareType == DfuFirmwareTypes.APPLICATION)
        { resetSystem() }
        
        mDelegate?.onDFUCancelled()
    }

    //added for MCU OTA
    
    func MCU_openfirmware(firmwareURL:NSURL)
    {
    var locData:NSData = NSData(contentsOfURL: firmwareURL)!;
    //remove first 16K bytes, remain 48k bytes
    var currentRange :NSRange =  NSMakeRange(16*1024, locData.length - 16 * 1024);
    
    binFileData = locData.subdataWithRange(currentRange)
    binFileSize = binFileData!.length
    totalpage = binFileData!.length/DFUCONTROLLER_PAGE_SIZE;
    checksum = 0
    dfuFirmwareType = DfuFirmwareTypes.SOFTDEVICE
     
    let bytes = UnsafeBufferPointer<UInt8>(start: UnsafePointer(binFileData!.bytes), count:binFileData!.length)
        
    for  byte in bytes {
      checksum = checksum + Int(byte)
    }
    
    NSLog("Set firmware with size \(binFileData!.length), notificationPacketInterval: \(notificationPacketInterval), totalpage: \(totalpage),Checksum: \(checksum)")
    }
    
    func MCU_sendFirmwareChunk()
    {
    NSLog("sendFirmwareData");
        
    for var i:Int = 0; i < notificationPacketInterval && firmwareDataBytesSent < binFileSize; i++
    {
    var length = DFUCONTROLLER_MAX_PACKET_SIZE;
    var pagePacket : NSData;
    if( i == 0)
    {
    //LSB format
        var pagehead :[UInt8] = [
            00,0x71,
            UInt8(curpage & 0xFF),
            UInt8((curpage>>8) & 0xFF),
            UInt8(totalpage & 0xFF),
            UInt8((totalpage>>8) & 0xFF),
            00,00,00,00,00,00,00,00,00,00,00,00,00,00]
        
        pagePacket = NSData(bytes: pagehead, length: pagehead.count)
    }
    else
    {
    if( i != (notificationPacketInterval - 1))
    {
        length = DFUCONTROLLER_MAX_PACKET_SIZE;
    }
    else
    {
        length = DFUCONTROLLER_PAGE_SIZE%DFUCONTROLLER_MAX_PACKET_SIZE;
    }
    
    var currentRange:NSRange = NSMakeRange(self.firmwareDataBytesSent, length)
    
    var currentData:NSData =  binFileData!.subdataWithRange(currentRange)
   
    var fulldata:NSMutableData = NSMutableData()

    if i == self.notificationPacketInterval - 1
    {
        fulldata.appendBytes([0xFF,0x71] as [Byte], length: 2)
    }
    else
    {
        fulldata.appendBytes([UInt8(i),0x71] as [Byte], length: 2)
    }
        
    fulldata.appendData(currentData)
        
    //last packet of the page, remains 8 bytes,fill 0
    if(i == (notificationPacketInterval - 1))
    {
       fulldata.appendBytes([0,0,0,0,0,0,0,0] as [Byte], length: 8)
    }
    pagePacket = fulldata
    
    firmwareDataBytesSent += length;
    }
    
    mConnectionController?.sendRequest(Mcu_OnePacketRequest(packetdata: pagePacket ))
    
    }
    if(curpage < totalpage)
    {
        progress = 100.0*Double(firmwareDataBytesSent) / Double(binFileSize);
        mDelegate?.onTransferPercentage(Int(progress))
        NSLog("didWriteDataPacket");
        
        if (state == DFUControllerState.SEND_FIRMWARE_DATA)
        {
            curpage++
            state = DFUControllerState.WAIT_RECEIPT
        }
    
    }
    else
    {
    state = DFUControllerState.FINISHED;
    progress = 100.0
    mDelegate?.onTransferPercentage(Int(progress))
    mConnectionController?.sendRequest(Mcu_CheckSumPacketRequest(totalpage: totalpage, checksum: checksum))
    NSLog("sendEndPacket, totalpage =\(totalpage), checksum = \(checksum), checksum-Lowbyte = \(checksum&0xFF)")
        
    return
    }
    NSLog("Sent \(self.firmwareDataBytesSent) bytes, pageno: \(curpage).")
    
    }
    
    func MCU_processDFUResponse(packet:RawPacket)
    {
        NSLog("didReceiveReceipt")
        mPacketsbuffer.append(packet.getRawData())
        var databyte:[Byte] = NSData2Bytes(packet.getRawData())
        
        if(databyte[0] == 0xFF)
        {
            if( databyte[1] == 0x70)
            {
                //first Packet  as header get successful response!
                progress = Double(firmwareDataBytesSent) / Double(binFileSize)
                self.state = DFUControllerState.SEND_FIRMWARE_DATA
               
            }
            if( databyte[1] == 0x71 && self.state == DFUControllerState.FINISHED)
            {
                var databyte1:[Byte] = NSData2Bytes(mPacketsbuffer[0])
                
                if(databyte1[1] == 0x71
                    && databyte1[2] == 0xFF
                    && databyte1[3] == 0xFF
                    )
                {
                    var TotalPageLo:Byte = Byte(totalpage & 0xFF)
                    var TotalPageHi:Byte = Byte((totalpage>>8) & 0xFF)
                    
                    if (databyte1[4] == TotalPageLo
                        && databyte1[5] == TotalPageHi)
                    {
                        //Check sum match ,OTA over.
                        NSLog("Checksum match ,OTA get success!");
                        mDelegate?.onSuccessfulFileTranferred()
                    }
                    else
                    {
                        NSLog("Checksum error ,OTA get failure!");
                        mDelegate?.onError(NSString(string:"Checksum error ,OTA get failure!"))
                    }
                    //reset to idle
                    self.state = DFUControllerState.IDLE
                }
            }
            
            mPacketsbuffer = []
            
            if (self.state == DFUControllerState.SEND_FIRMWARE_DATA)
            {
                MCU_sendFirmwareChunk()
            }
            else if(self.state == DFUControllerState.WAIT_RECEIPT)
            {
                self.state = DFUControllerState.SEND_FIRMWARE_DATA;
                MCU_sendFirmwareChunk()
            }
        }
    }
    //end added
    
}

/**
this protocol is defined for OTA UIView controller
*/
protocol NevoOtaControllerDelegate {
    
   // func connectionStateChanged(isConnected : Bool)
    func onDFUStarted()
    func onDFUCancelled()
    func onTransferPercentage(Int)
    func onSuccessfulFileTranferred()
    func onError(NSString)
    
}
