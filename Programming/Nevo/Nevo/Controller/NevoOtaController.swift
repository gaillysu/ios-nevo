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
    
    private var binFileSize:Int = 0
    private var uploadTimeInSeconds:Int = 0
    private var firmwareFile :NSURL?
    private var dfuResponse:DFUResponse
    
    private var binFileData:NSData?
    private var numberOfPackets:Int = 0
    private var bytesInLastPacket:Int = 0
    private var writingPacketNumber :Int = 0
    
    init(controller : NevoOtaViewController) {
        
        dfuResponse = DFUResponse(responseCode: 0,requestedCode: 0,responseStatus: 0)
        
        mDelegate = controller
        mConnectionController = ConnectionControllerImpl.sharedInstance
        
        mConnectionController?.setDelegate(self)
        
        mConnectionController?.connect()

    }
    private func openFile(fileURL:NSURL)
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
        
        processDFUResponse(NSData2Bytes(packet.getRawData()))
 
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
        
        mConnectionController?.sendRequest(StartOTARequest())
        mConnectionController?.sendRequest(writeFileSizeRequest(filelength: binFileSize))
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
        resetSystem()
        mDelegate?.onDFUCancelled()
    }

    
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
