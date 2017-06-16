/**

this file is main OTA controller
usage: 
var mNevoOtaController : NevoOtaController?
mNevoOtaController = NevoOtaController(controller: self)


*/

import Foundation
import XCGLogger
import iOSDFULibrary
import SwiftEventBus

struct DFUResponse
{
    var responseCode:UInt8;
    var requestedCode:UInt8;
    var responseStatus:UInt8;
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

class NevoMCUOtaController : NSObject,ConnectionControllerDelegate {
    enum DfuOperationStatus:UInt8{
        case operation_SUCCESSFUL_RESPONSE = 0x01,
        operation_INVALID_RESPONSE = 0x02,
        operation_NOT_SUPPORTED_RESPONSE = 0x03,
        data_SIZE_EXCEEDS_LIMIT_RESPONSE = 0x04,
        crc_ERROR_RESPONSE = 0x05,
        operation_FAILED_RESPONSE = 0x06
        
    }

    var mDelegate : NevoOtaControllerDelegate?
    let mConnectionController : ConnectionController = ConnectionManager.manager.getMconnectionController()!
    
    var dfuFirmwareType : DfuFirmwareTypes = DfuFirmwareTypes.application
    fileprivate var mPacketsbuffer:[Data]=[]
    fileprivate var binFileSize:Int = 0
    fileprivate var uploadTimeInSeconds:Int = 0
    fileprivate var firmwareFile :URL?
    fileprivate var dfuResponse:DFUResponse = DFUResponse(responseCode: 0,requestedCode: 0,responseStatus: 0)
    
    fileprivate var binFileData:Data?
    fileprivate var numberOfPackets:Int = 0
    fileprivate var bytesInLastPacket:Int = 0
    fileprivate var writingPacketNumber :Int = 0
    
    /** check the OTA is doing or stop */
    fileprivate var mTimeoutTimer:Timer?
    fileprivate let MAX_TIME = 15
    fileprivate var lastprogress = 0.0
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
    fileprivate var state:DFUControllerState = DFUControllerState.inittialize
    fileprivate var mcu_broken_state:DFUControllerState = DFUControllerState.inittialize
    fileprivate var firmwareDataBytesSent:Int = 0
    fileprivate var progress = 0.0
    fileprivate var curpage:Int = 0
    fileprivate var totalpage:Int = 0
    fileprivate  var checksum:Int = 0
    //end added
    
    init(_ delegate:NevoOtaControllerDelegate) {
        super.init()
        mDelegate = delegate
        mConnectionController.setDelegate(self)
        mConnectionController.connect()
    }

    fileprivate func writeNextPacket(){
        var percentage :Int = 0;
        for index:Int in 0 ..< Int(EnumPacketOption.packets_NOTIFICATION_INTERVAL.rawValue) {
            if (self.writingPacketNumber > self.numberOfPackets-2) {
                XCGLogger.default.debug("writing last packet");
                let dataRange : Range = self.writingPacketNumber*EnumPacketOption.packet_SIZE.rawValue..<(self.writingPacketNumber*EnumPacketOption.packet_SIZE.rawValue+self.bytesInLastPacket)
                    //NSMakeRange(self.writingPacketNumber*enumPacketOption.packet_SIZE.rawValue, self.bytesInLastPacket);
                let nextPacketData : Data = (binFileData?.subdata(in: dataRange))!

                XCGLogger.default.debug("writing packet number \(self.writingPacketNumber+1) ...");
                XCGLogger.default.debug("packet data: \(nextPacketData)");

                mConnectionController.sendRequest(OnePacketRequest(packetdata: nextPacketData ))
                progress = 100.0
                percentage = Int(progress)
                XCGLogger.default.debug("DFUOperations: onTransferPercentage \(percentage)");
                mDelegate?.onTransferPercentage(percentage)
                self.writingPacketNumber += 1;
                mTimeoutTimer?.invalidate()
                XCGLogger.default.debug("DFUOperations: onAllPacketsTransfered");
                break;

            }
            let dataRange : Range = self.writingPacketNumber*EnumPacketOption.packet_SIZE.rawValue..<(self.writingPacketNumber*EnumPacketOption.packet_SIZE.rawValue+EnumPacketOption.packet_SIZE.rawValue)
                //NSMakeRange(self.writingPacketNumber*enumPacketOption.packet_SIZE.rawValue, enumPacketOption.packet_SIZE.rawValue);

            let    nextPacketData : Data  = (self.binFileData?.subdata(in: dataRange))!
            XCGLogger.default.debug("writing packet number \(self.writingPacketNumber+1) ...");
            XCGLogger.default.debug("packet data: \(nextPacketData)");

            mConnectionController.sendRequest(OnePacketRequest(packetdata: nextPacketData ))
            progress = Double(self.writingPacketNumber * EnumPacketOption.packet_SIZE.rawValue) / Double(self.binFileSize) * 100.0
            percentage = Int(progress)

            XCGLogger.default.debug("DFUOperations: onTransferPercentage \(percentage)");
            mDelegate?.onTransferPercentage(percentage)
            
            self.writingPacketNumber += 1;
        }
    }

    fileprivate func startSendingFile(){
        XCGLogger.default.debug("DFUOperationsdetails enablePacketNotification");
        mConnectionController.sendRequest(EnablePacketNotifyRequest())
        XCGLogger.default.debug("DFUOperationsdetails receiveFirmwareImage");
        mConnectionController.sendRequest(ReceiveFirmwareImageRequest())
  
        writeNextPacket()
        
        mDelegate?.onDFUStarted()
    }
    
    fileprivate func resetSystem(){
        XCGLogger.default.debug("DFUOperationsDetails resetSystem");
        mConnectionController.sendRequest(ResetSystemRequest())
    }
    
    fileprivate func validateFirmware(){
        XCGLogger.default.debug("DFUOperationsDetails validateFirmware");
        mConnectionController.sendRequest(ValidateFirmwareRequest())
    }

    fileprivate func activateAndReset(){
        XCGLogger.default.debug("DFUOperationsDetails activateAndReset");
        mConnectionController.sendRequest(ActivateAndResetRequest())
    }

    fileprivate func responseErrorMessage(_ errorCode:DfuOperationStatus.RawValue) ->NSString{
        switch (errorCode) {
        case DfuOperationStatus.operation_FAILED_RESPONSE.rawValue:
            return NSString(string:"Operation Failed");

        case DfuOperationStatus.operation_INVALID_RESPONSE.rawValue:
            return NSString(string:"Invalid Response");

        case DfuOperationStatus.operation_NOT_SUPPORTED_RESPONSE.rawValue:
            return NSString(string:"Operation Not Supported");

        case DfuOperationStatus.data_SIZE_EXCEEDS_LIMIT_RESPONSE.rawValue:
            return NSString(string:"Data Size Exceeds");

        case DfuOperationStatus.crc_ERROR_RESPONSE.rawValue:
            return NSString(string:"CRC Error");
            
        default:
            return NSString(string:"unknown Error");
            
        }
    }
    
    fileprivate func processRequestedCode(){
        XCGLogger.default.debug("processsRequestedCode");
        switch (dfuResponse.requestedCode) {
        case DfuOperations.start_DFU_REQUEST.rawValue:
            XCGLogger.default.debug("Requested code is StartDFU now processing response status");
            processStartDFUResponseStatus()
            break;
        case DfuOperations.receive_FIRMWARE_IMAGE_REQUEST.rawValue:
            XCGLogger.default.debug("Requested code is Receive Firmware Image now processing response status");
            processReceiveFirmwareResponseStatus()
            break;
        case DfuOperations.validate_FIRMWARE_REQUEST.rawValue:
            XCGLogger.default.debug("Requested code is Validate Firmware now processing response status");
            processValidateFirmwareResponseStatus()
            break;

        default:
            XCGLogger.default.debug("invalid Requested code in DFU Response \(self.dfuResponse.requestedCode)");
            break;
        }
    }
    
    fileprivate func processStartDFUResponseStatus(){
        XCGLogger.default.debug("processStartDFUResponseStatus");
        let errorMessage = "Error on StartDFU\n Message: \(responseErrorMessage(dfuResponse.responseStatus))"
        switch (dfuResponse.responseStatus) {
        case DfuOperationStatus.operation_SUCCESSFUL_RESPONSE.rawValue:
            XCGLogger.default.debug("successfully received startDFU notification");
            startSendingFile()
            break;
        case DfuOperationStatus.operation_NOT_SUPPORTED_RESPONSE.rawValue:
            XCGLogger.default.debug("device has old DFU. switching to old DFU ...");
            performOldDFUOnFile()
            break;

        default:
            XCGLogger.default.debug("StartDFU failed, Error Status: \(self.responseErrorMessage(self.dfuResponse.responseStatus))");
            mDelegate?.onError(errorMessage)
            resetSystem()
            break;
        }

    }
    
    fileprivate func processReceiveFirmwareResponseStatus(){
        XCGLogger.default.debug("processReceiveFirmwareResponseStatus");
        if (dfuResponse.responseStatus == DfuOperationStatus.operation_SUCCESSFUL_RESPONSE.rawValue) {
            XCGLogger.default.debug("successfully received notification for whole File transfer");
            validateFirmware()
            
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: { 
                self.activateAndReset()
            })
        }else {
            XCGLogger.default.debug("Firmware Image failed, Error Status: \(self.responseErrorMessage(self.dfuResponse.responseStatus))");
            let errorMessage = "Error on Receive Firmware Image\n Message: \(responseErrorMessage(dfuResponse.responseStatus))";
            mDelegate?.onError(errorMessage)
            resetSystem()
        }

    }
    
    fileprivate func processValidateFirmwareResponseStatus(){
        XCGLogger.default.debug("processValidateFirmwareResponseStatus");
        if (dfuResponse.responseStatus == DfuOperationStatus.operation_SUCCESSFUL_RESPONSE.rawValue) {
            XCGLogger.default.debug("succesfully received notification for ValidateFirmware");
            activateAndReset()
            mDelegate?.onSuccessfulFileTranferred()
        }else {
            XCGLogger.default.debug("Firmware validate failed, Error Status: \( self.responseErrorMessage(self.dfuResponse.responseStatus))");
            let errorMessage = "Error on Validate Firmware Request\n Message: \(responseErrorMessage(dfuResponse.responseStatus))";
            mDelegate?.onError(errorMessage)
            resetSystem()
        }
    }
    
    fileprivate func processPacketNotification(){
        XCGLogger.default.debug("received Packet Received Notification");
        if (writingPacketNumber < numberOfPackets) {
            writeNextPacket()
        }
    }

    fileprivate func setDFUResponseStruct(_ data:[UInt8]){
        dfuResponse.responseCode = data[0]
        dfuResponse.requestedCode = data[1]
        dfuResponse.responseStatus = data[2]
    }
    
    fileprivate func processDFUResponse(_ data :[UInt8]){
        XCGLogger.default.debug("processDFUResponse");
        setDFUResponseStruct(data)
        
        if (dfuResponse.responseCode == DfuOperations.response_CODE.rawValue) {
            processRequestedCode()
        }else if(dfuResponse.responseCode == DfuOperations.packet_RECEIPT_NOTIFICATION_RESPONSE.rawValue) {
            processPacketNotification()
        }
    }
    
    /*
    see ConnectionControllerDelegate protocol
    */
    func packetReceived(_ packet:RawPacket) {
        //dicard those packets from  NevoProfile
        if !(packet.getSourceProfile() is NevoProfile){
            if(dfuFirmwareType == DfuFirmwareTypes.softdevice) {
                SyncQueue.sharedInstance_ota.next()
                MCU_processDFUResponse(packet)
            }
        }
    }
    /*
    see ConnectionControllerDelegate protocol
    */
    func connectionStateChanged(_ isConnected : Bool, fromAddress : UUID!,isFirstPair:Bool) {

        mDelegate?.connectionStateChanged(isConnected, fromAddress: fromAddress, isFirstPair: isFirstPair)
        //only BLE OTA run below code
        if(dfuFirmwareType == DfuFirmwareTypes.softdevice)//only MCU OTA run below code
        {
            if isConnected {
                if self.state == DFUControllerState.send_RECONNECT{
                    if self.mcu_broken_state == DFUControllerState.send_FIRMWARE_DATA
                    || self.mcu_broken_state == DFUControllerState.wait_RECEIPT {
                        //reset it
                        self.mcu_broken_state = DFUControllerState.inittialize
                        self.state = DFUControllerState.send_FIRMWARE_DATA
                        //resend current page
                        if(curpage>0) {
                            curpage = curpage - 1
                            firmwareDataBytesSent = firmwareDataBytesSent - DFUCONTROLLER_PAGE_SIZE
                        }
                        MCU_sendFirmwareChunk()
                    }else {
                        //MCU got broken is more than 30s, app will get timeout and retry connect again,
                        //when got connected, will send restart OTA cmd and retry do OTA from page No.0
                        self.state = DFUControllerState.send_START_COMMAND
                        let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                            self.mConnectionController.sendRequest(Mcu_SetOTAModeRequest())
                        })
                    }
                }
                
            }else{
                if self.state == DFUControllerState.idle {
                    self.state = DFUControllerState.send_RECONNECT
                    let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {

                        self.mConnectionController.connect()
                    })
                }else if self.state == DFUControllerState.send_FIRMWARE_DATA || self.state == DFUControllerState.wait_RECEIPT {
                    //keep state within 30s timeout
                    self.mcu_broken_state = self.state
                    self.state = DFUControllerState.send_RECONNECT
                    let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                        
                        self.mConnectionController.connect()
                    })
                }

            }
        }
    }

    func bluetoothEnabled(_ enabled:Bool) {

    }

    func scanAndConnect(){

    }

    /**
    See ConnectionControllerDelegate
    */
    func firmwareVersionReceived(_ whichfirmware:DfuFirmwareTypes, version:Int){
        mDelegate?.firmwareVersionReceived(whichfirmware, version: version)
    }

    /**
    See ConnectionControllerDelegate
    */
    func receivedRSSIValue(_ number:NSNumber){
        mDelegate?.receivedRSSIValue(number)
    }

    func setConnectControllerDelegate2Self(){
        mConnectionController.setDelegate(self)
    }

    func performDFUOnFile(_ firmwareURL:URL , firmwareType:DfuFirmwareTypes){
        lastprogress = 0.0
        progress = 0.0
        mTimeoutTimer?.invalidate()
        mTimeoutTimer = Timer.scheduledTimer(timeInterval: Double(MAX_TIME), target: self, selector:#selector(timeroutProc(_:)), userInfo: nil, repeats: true)
        
        mConnectionController.setDelegate(self)
        state = DFUControllerState.idle
        dfuFirmwareType = firmwareType
        firmwareFile = firmwareURL

        MCU_openfirmware(firmwareURL)
        //enable it done after doing discover service
        mConnectionController.setOTAMode(true,Disconnect:true)
    }
    
    func timeroutProc(_ timer:Timer){
        if lastprogress == progress  && progress != 100.0{
            //when MCU got broken and got timeout(30s), reset mcu_broken_state
            if(dfuFirmwareType == DfuFirmwareTypes.softdevice) {
                self.mcu_broken_state = DFUControllerState.inittialize
            }
            XCGLogger.default.debug("* * * OTA timeout * * *")
            let errorMessage = "OTA Failed"
            mDelegate?.onError(errorMessage)
        }else{
            lastprogress = progress
        }
    }

    fileprivate func performOldDFUOnFile(){
        if self.dfuFirmwareType == DfuFirmwareTypes.softdevice {
            let errorMessage = "Old DFU only supports Application upload"
            mDelegate?.onError(errorMessage)
            resetSystem()
        }
    }
    
    func cancelDFU(){
        XCGLogger.default.debug("cancelDFU");
        mDelegate?.onDFUCancelled()
    }

    func sendRequest(_ r:Request) {
        //for MCU OTA, use send queue to control it
        if (self.dfuFirmwareType == DfuFirmwareTypes.softdevice){
            SyncQueue.sharedInstance_ota.post( { (Void) -> (Void) in
                self.mConnectionController.sendRequest(r)
            } )
        }else{
            self.mConnectionController.sendRequest(r)
        }
    }

    //added for MCU OTA
    
    func MCU_openfirmware(_ firmwareURL:URL){
        let locData:Data = try! Data(contentsOf: firmwareURL);
        //remove first 16K bytes, remain 48k bytes
        let currentRange :Range = (16*1024)..<locData.count
            //NSMakeRange(16*1024, locData.count - 16 * 1024);

        firmwareDataBytesSent = 0
        curpage = 0
        binFileData = locData.subdata(in: currentRange)
        binFileSize = binFileData!.count
        totalpage = binFileData!.count/DFUCONTROLLER_PAGE_SIZE;
        checksum = 0
        dfuFirmwareType = DfuFirmwareTypes.softdevice

        let bytes = UnsafeBufferPointer<UInt8>(start: (binFileData! as NSData).bytes.bindMemory(to: UInt8.self, capacity: binFileData!.count), count:binFileData!.count)

        for  byte in bytes {
            checksum = checksum + Int(byte)
        }

        XCGLogger.default.debug("Set firmware with size \(self.binFileData!.count), notificationPacketInterval: \(self.notificationPacketInterval), totalpage: \(self.totalpage),Checksum: \(self.checksum)")

    }
    
    func MCU_sendFirmwareChunk(){
        XCGLogger.default.debug("sendFirmwareData")
        //define one page request  object
        let Onepage:Mcu_OnePageRequest = Mcu_OnePageRequest()

        for i:Int in 0..<notificationPacketInterval {
            if firmwareDataBytesSent < binFileSize {
                var length = DFUCONTROLLER_MAX_PACKET_SIZE;
                var pagePacket : Data;
                if( i == 0){
                    //LSB format
                    let pagehead :[UInt8] = [
                        00,0x71,
                        UInt8(curpage & 0xFF),
                        UInt8((curpage>>8) & 0xFF),
                        UInt8(totalpage & 0xFF),
                        UInt8((totalpage>>8) & 0xFF),
                        00,00,00,00,00,00,00,00,00,00,00,00,00,00]
                    
                    pagePacket = Data(bytes: UnsafePointer<UInt8>(pagehead), count: pagehead.count)
                }else {
                    if( i != (notificationPacketInterval - 1)){
                        length = DFUCONTROLLER_MAX_PACKET_SIZE;
                    }else{
                        length = DFUCONTROLLER_PAGE_SIZE%DFUCONTROLLER_MAX_PACKET_SIZE;
                    }
                    
                    let currentRange:Range = self.firmwareDataBytesSent..<(self.firmwareDataBytesSent+length)
                    //NSMakeRange(self.firmwareDataBytesSent, length)
                    let currentData:Data =  binFileData!.subdata(in: currentRange)
                    
                    let fulldata:NSMutableData = NSMutableData()
                    
                    if i == self.notificationPacketInterval - 1{
                        fulldata.append([0xFF,0x71] as [UInt8], length: 2)
                    }else{
                        fulldata.append([UInt8(i),0x71] as [UInt8], length: 2)
                    }
                    
                    fulldata.append(currentData)
                    
                    //last packet of the page, remains 8 bytes,fill 0
                    if(i == (notificationPacketInterval - 1)){
                        fulldata.append([0,0,0,0,0,0,0,0] as [UInt8], length: 8)
                    }
                    pagePacket = fulldata as Data
                    
                    firmwareDataBytesSent += length;
                }
                
                Onepage.addPacket(Mcu_OnePacketRequest(packetdata: pagePacket ))
            }
        }

        if(curpage < totalpage){
            sendRequest(Onepage)
            progress = 100.0*Double(firmwareDataBytesSent) / Double(binFileSize);
            mDelegate?.onTransferPercentage(Int(progress))
            XCGLogger.default.debug("didWriteDataPacket")

            if (state == DFUControllerState.send_FIRMWARE_DATA){
                curpage += 1
                state = DFUControllerState.wait_RECEIPT
            }
            
        }else{
            state = DFUControllerState.finished
            progress = 100.0
            mDelegate?.onTransferPercentage(Int(progress))
            sendRequest(Mcu_CheckSumPacketRequest(totalpage: totalpage, checksum: checksum))        
            XCGLogger.default.debug("sendEndPacket, totalpage =\(self.totalpage), checksum = \(self.checksum), checksum-Lowbyte = \(self.checksum&0xFF)")
            mTimeoutTimer?.invalidate()
            return
        }
        XCGLogger.default.debug("Sent \(self.firmwareDataBytesSent) bytes, pageno: \(self.curpage).")
    }
    
    func MCU_processDFUResponse(_ packet:RawPacket){
        XCGLogger.default.debug("didReceiveReceipt")
        mPacketsbuffer.append(packet.getRawData())
        var databyte:[UInt8] = packet.getRawData().data2Bytes()
        
        if(databyte[0] == 0xFF){
            if( databyte[1] == 0x70){
                //first Packet  as header get successful response!
                progress = Double(firmwareDataBytesSent) / Double(binFileSize)
                self.state = DFUControllerState.send_FIRMWARE_DATA
               
            }

            if( databyte[1] == 0x71 && self.state == DFUControllerState.finished){
                var databyte1:[UInt8] = mPacketsbuffer[0].data2Bytes()
                
                if(databyte1[1] == 0x71
                    && databyte1[2] == 0xFF
                    && databyte1[3] == 0xFF
                    ){
                    let TotalPageLo:UInt8 = UInt8(totalpage & 0xFF)
                    let TotalPageHi:UInt8 = UInt8((totalpage>>8) & 0xFF)
                    
                    if (databyte1[4] == TotalPageLo
                        && databyte1[5] == TotalPageHi){
                        //Check sum match ,OTA over.
                        XCGLogger.default.debug("Checksum match ,OTA get success!");
                        mDelegate?.onSuccessfulFileTranferred()
                    }else{
                        XCGLogger.default.debug("Checksum error ,OTA get failure!");
                        mDelegate?.onError("Checksum error ,OTA get failure!")
                    }
                }
            }
            
            mPacketsbuffer = []
            
            if (self.state == DFUControllerState.send_FIRMWARE_DATA){
                MCU_sendFirmwareChunk()
            }else if(self.state == DFUControllerState.wait_RECEIPT){
                self.state = DFUControllerState.send_FIRMWARE_DATA;
                MCU_sendFirmwareChunk()
            }
        }
    }
    //end added
    
    func isConnected() -> Bool{
        return mConnectionController.isConnected()
    }

    func setStatus(_ state:DFUControllerState){
      self.state = state
    }

    func getStatus() ->DFUControllerState{
        return state
    }

    /**
    reset to normal mode "NevoProfile"
    parameter: switch2SyncController: true/false
    step1: restore Address
    step2: restore syncController
    step3: restore normal mode
    step4: reconnect
    //from OTA mode to normal mode, must make syncController to handle connectionController
    because MCU/BLE ota, user has done one of them, perhaps do another one,
    so no need make syncController handle connectionController
    */
    func reset(_ switch2SyncController:Bool){
        mTimeoutTimer?.invalidate()
        //reset it to INIT status !!!IMPORTANT!!!
        self.state = DFUControllerState.inittialize
        
        if switch2SyncController{
            self.mConnectionController.setDelegate(ConnectionManager.manager)
        }
        self.mConnectionController.setOTAMode(false,Disconnect:true)
        self.mConnectionController.connect()
    }
}

/**
this protocol is defined for OTA UIView controller
*/
protocol NevoOtaControllerDelegate {
    
    func connectionStateChanged(_ isConnected : Bool, fromAddress : UUID?,isFirstPair:Bool?)
    func onDFUStarted()
    func onDFUCancelled()
    func onTransferPercentage(_: Int)
    func onSuccessfulFileTranferred()
    func onError(_ errorMessage: String)
    /**
    Call when finished OTA, will reconnect nevo and read firmware, refresh the firmware  to screen view
    @parameter whichfirmware, firmware type
    @parameter version, return the version
    */
    func firmwareVersionReceived(_ whichfirmware:DfuFirmwareTypes, version:Int)
    /**
    See SyncControllerDelegate
    */
    func receivedRSSIValue(_ number:NSNumber)
}