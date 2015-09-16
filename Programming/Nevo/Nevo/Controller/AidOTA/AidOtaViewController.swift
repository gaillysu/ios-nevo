//
//  AidOtaViewController.swift
//  Nevo
//
//  Created by leiyuncun on 15/9/15.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class AidOtaViewController: UIViewController,NevoOtaControllerDelegate,ButtonManagerCallBack,UIAlertViewDelegate  {

    @IBOutlet var nevoOtaView: NevoOtaView!


    var isTransferring:Bool = false
    var enumFirmwareType:DfuFirmwareTypes = DfuFirmwareTypes.APPLICATION
    var selectedFileURL:NSURL?
    //save the build-in firmware version, it should be the latest FW version
    var buildinSoftwareVersion:Int  = 0
    var buildinFirmwareVersion:Int  = 0
    var firmwareURLs:[NSURL] = []
    var currentIndex = 0
    var mAidOtaController : AidOtaController?
    private var allTaskNumber:NSInteger = 0;//计算所有OTA任务数量
    private var currentTaskNumber:NSInteger = 0;//当前在第几个任务

    override func viewDidLayoutSubviews(){
        //init the view
        nevoOtaView.buildView(self,otacontroller: mAidOtaController!)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().idleTimerDisabled = true

        //init the ota
        mAidOtaController = AidOtaController(controller: self)
        mAidOtaController?.mConnectionController?.setOTAMode(true, Disconnect: false)

        initValue()
        
        checkConnection()

        if(mAidOtaController!.isConnected()){
            var currentSoftwareVersion = mAidOtaController!.getSoftwareVersion() as String
            var currentFirmwareVersion = mAidOtaController!.getFirmwareVersion() as String
            if(currentSoftwareVersion.isEmpty || currentFirmwareVersion.isEmpty)
            {
                return
            }
            buildinSoftwareVersion = GET_SOFTWARE_VERSION()
            buildinFirmwareVersion = GET_FIRMWARE_VERSION()

            var fileArray = GET_FIRMWARE_FILES("Firmwares")
            for tmpfile in fileArray {
                var selectedFile = tmpfile as! NSURL
                var fileName:String? = selectedFile.path!.lastPathComponent
                var fileExtension:String? = selectedFile.pathExtension
                if fileExtension == "hex" && currentFirmwareVersion.toInt() < buildinFirmwareVersion
                {
                    firmwareURLs.append(selectedFile)
                    allTaskNumber++
                    break
                }
            }

            for tmpfile in fileArray {
                var selectedFile = tmpfile as! NSURL
                var fileName:String? = selectedFile.path!.lastPathComponent
                var fileExtension:String? = selectedFile.pathExtension

                if fileExtension == "bin" && currentSoftwareVersion.toInt() < buildinSoftwareVersion {
                    firmwareURLs.append(selectedFile)
                    allTaskNumber++
                    break
                }
            }

            if(currentSoftwareVersion.toInt() < buildinSoftwareVersion
                || currentFirmwareVersion.toInt() < buildinFirmwareVersion ) {
                var updatemsg:String = NSLocalizedString("current FW version", comment: "") + "(\(currentFirmwareVersion),\(currentSoftwareVersion))," + NSLocalizedString("latest FW version", comment: "") + "(\(buildinFirmwareVersion),\(buildinSoftwareVersion)). " + NSLocalizedString("are you sure", comment: "")

                var alert :UIAlertView = UIAlertView(title: NSLocalizedString("Firmware Upgrade", comment: ""), message: updatemsg, delegate: self, cancelButtonTitle: NSLocalizedString("Cancel", comment: ""))
                alert.addButtonWithTitle(NSLocalizedString("Enter", comment: ""))
                alert.show()
            }else{
                nevoOtaView.setLatestVersion(NSLocalizedString("latestversion",comment: ""))
            }
        }
    }

    override func viewDidAppear(animated: Bool) {
        mAidOtaController!.setConnectControllerDelegate2Self()
    }

    override func viewDidDisappear(animated: Bool) {
        UIApplication.sharedApplication().idleTimerDisabled = false
        if (!self.isTransferring){
            mAidOtaController!.reset(true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //init data function
    private func initValue(){
        nevoOtaView.backButton.enabled = true
        isTransferring = false
        nevoOtaView.ReUpgradeButton?.hidden = false //The process of OTA hide this control
    }

    //upload button function
    func uploadPressed(){
        if currentIndex >= firmwareURLs.count  || firmwareURLs.count == 0 {
            onError(NSLocalizedString("checking_firmware", comment: "") as NSString)
            return
        }

        if(!mAidOtaController!.isConnected()){
            onError(NSLocalizedString("update_error_noconnect", comment: "") as NSString)
            return
        }

        currentTaskNumber++;
        selectedFileURL = firmwareURLs[currentIndex]
        var fileExtension:String? = selectedFileURL!.pathExtension
        if fileExtension == "bin"{
            enumFirmwareType = DfuFirmwareTypes.SOFTDEVICE
        }
        if fileExtension == "hex"{
            enumFirmwareType = DfuFirmwareTypes.APPLICATION
        }

        nevoOtaView.setProgress(0.0,currentTask: currentTaskNumber,allTask: allTaskNumber)
        nevoOtaView.setLatestVersion(NSLocalizedString("Please waiting...", comment: ""))
        isTransferring = true
        //when doing OTA, disable Cancel/Back button, enable them by callback function invoke initValue()/checkConnection()
        nevoOtaView.backButton.enabled = false
        nevoOtaView.ReUpgradeButton?.hidden = true //The process of OTA hide this control
        mAidOtaController?.performDFUOnFile(selectedFileURL!, firmwareType: enumFirmwareType)

    }

    /**
    Checks if any device is currently connected
    */

    func checkConnection() {

        if (mAidOtaController != nil && !(mAidOtaController!.isConnected() ) || isTransferring) {
            //disable upPress button
            nevoOtaView.ReUpgradeButton?.hidden = true
        }else{
            // enable upPress button
            nevoOtaView.ReUpgradeButton?.hidden = false
        }
        
    }

    //MARK: - UIAlertViewDelegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){

        if(buttonIndex==1){
            currentIndex = 0
            self.uploadPressed()
        }
    }

    //MARK: - NevoOtaControllerDelegate
    
    //below is delegate function
    func onDFUStarted(){
        AppTheme.DLog("onDFUStarted");
        //here enable upload button
    }

    //user cancel
    func onDFUCancelled(){
        AppTheme.DLog("onDFUCancelled");
        //reset OTA view controller 's some data, such as progress bar and upload button text/status
        initValue()
        mAidOtaController!.reset(false)
    }

    //percent is[0..100]
    func onTransferPercentage(percent:Int){
        nevoOtaView.setProgress((Float(percent)/100.0),currentTask: currentTaskNumber,allTask:allTaskNumber)
    }

    //successfully
    func onSuccessfulFileTranferred(){
        currentIndex = currentIndex + 1
        if currentIndex == firmwareURLs.count {
            initValue()
            var message = NSLocalizedString("UpdateSuccess1", comment: "")
            if enumFirmwareType == DfuFirmwareTypes.APPLICATION{
                message = NSLocalizedString("UpdateSuccess2", comment: "")
            }
            var alert :UIAlertView = UIAlertView(title: "Firmware Upgrade", message: message, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            nevoOtaView.upgradeSuccessful()
            mAidOtaController!.reset(false)
        }else{
            mAidOtaController!.reset(false)
            mAidOtaController!.setStatus(DFUControllerState.SEND_RESET)
            var dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(10.0 * Double(NSEC_PER_SEC)))
            if !mAidOtaController!.isConnected() && mAidOtaController!.getStatus() == DFUControllerState.SEND_RESET{
                var errorMessage = "Timeout,please try again";
                self.onError(errorMessage)
            }
        }
    }
    //Error happen
    func onError(errString : NSString){

        initValue()
        var alert :UIAlertView = UIAlertView(title: "Firmware Upgrade", message: errString as String, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
        mAidOtaController!.reset(false)
    }

    func connectionStateChanged(isConnected : Bool) {

        //Maybe we just got disconnected, let's check

        checkConnection()
        if mAidOtaController!.isConnected() && mAidOtaController!.getStatus() == DFUControllerState.SEND_RESET
        {
            mAidOtaController!.setStatus(DFUControllerState.INIT)
            var dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                //MCU reset OK, continue BLE OTA
                self.uploadPressed();
            })
        }

    }

    /**
    see NevoOtaControllerDelegate
    */
    func firmwareVersionReceived(whichfirmware:DfuFirmwareTypes, version:NSString)
    {
        //nevoOtaView.setVersionLbael(mNevoOtaController!.getSoftwareVersion(), bleNumber: mNevoOtaController!.getFirmwareVersion())
    }

    // MARK: - ButtonManagerCallBack
    func controllManager(sender:AnyObject){

        if (sender.isEqual(nevoOtaView.backButton)) {
            AppTheme.DLog("back2Home")
            self.dismissViewControllerAnimated(true, completion: nil)
        }

        if(sender.isEqual(nevoOtaView.ReUpgradeButton)){
            mAidOtaController?.setStatus(DFUControllerState.DISCOVERING)
            if(mAidOtaController!.isConnected()){
                currentTaskNumber = 0;
                allTaskNumber = 0;
                firmwareURLs = []
                currentIndex = 0
                var fileArray = GET_FIRMWARE_FILES("Firmwares")
                for tmpfile in fileArray {
                    var selectedFile = tmpfile as! NSURL
                    var fileName:String? = selectedFile.path!.lastPathComponent
                    var fileExtension:String? = selectedFile.pathExtension
                    if fileExtension == "hex"
                    {
                        firmwareURLs.append(selectedFile)
                        allTaskNumber++;
                        break
                    }
                }

                for tmpfile in fileArray {
                    var selectedFile = tmpfile as! NSURL
                    var fileName:String? = selectedFile.path!.lastPathComponent
                    var fileExtension:String? = selectedFile.pathExtension

                    if fileExtension == "bin"
                    {
                        firmwareURLs.append(selectedFile)
                        allTaskNumber++;
                        break
                    }
                }
                // reUpdate all firmwares
                uploadPressed()
            }else{
                // no connected nevo, disable update
            }
        }

    }

}
