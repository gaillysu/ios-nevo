//
//  NevoOtaViewController.swift
//  Nevo
//
//  Created by supernova on 15/2/4.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class NevoOtaViewController: UIViewController,NevoOtaControllerDelegate,ButtonManagerCallBack,PtlSelectFile,UIAlertViewDelegate  {

    @IBOutlet var nevoOtaView: NevoOtaView!

    
    var isTransferring:Bool = false
    var enumFirmwareType:DfuFirmwareTypes = DfuFirmwareTypes.APPLICATION
    var selectedFileURL:NSURL?
    //save the build-in firmware version, it should be the latest FW version
    var buildinSoftwareVersion:Int  = 12
    var buildinFirmwareVersion:Int  = 29
    var firmwareURLs:[NSURL] = []
    var currentIndex = 0
    var mNevoOtaController : NevoOtaController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //init the ota
        mNevoOtaController = NevoOtaController(controller: self)
        initValue()
        checkConnection()

       //init the view
        nevoOtaView.buildView(self,otacontroller: mNevoOtaController!)
        
        if(mNevoOtaController!.isConnected())
        {
            var currentSoftwareVersion = mNevoOtaController!.getSoftwareVersion() as String
            var currentFirmwareVersion = mNevoOtaController!.getFirmwareVersion() as String
            
            var fileArray = GET_FIRMWARE_FILES("Firmwares")
            for tmpfile in fileArray {
                var selectedFile = tmpfile as! NSURL
                var fileName:String? = selectedFile.path!.lastPathComponent
                var fileExtension:String? = selectedFile.pathExtension
                
                if fileExtension == "bin" && currentSoftwareVersion.toInt() < buildinSoftwareVersion
                {
                    //buildinSoftwareVersion =
                    firmwareURLs.append(selectedFile)
                    break
                }
            }

            for tmpfile in fileArray {
                var selectedFile = tmpfile as! NSURL
                var fileName:String? = selectedFile.path!.lastPathComponent
                var fileExtension:String? = selectedFile.pathExtension
                if fileExtension == "hex" && currentFirmwareVersion.toInt() < buildinFirmwareVersion
                {
                    //buildinFirmwareVersion =
                    firmwareURLs.append(selectedFile)
                    break
                }
            }
            
            
            if( currentSoftwareVersion.toInt() < buildinSoftwareVersion
               || currentFirmwareVersion.toInt() < buildinFirmwareVersion )
            {
                var alert :UIAlertView = UIAlertView(title: "Firmware Version", message: "the nevo Firmware version:\(currentFirmwareVersion),\(currentSoftwareVersion). the lastest version:\(buildinFirmwareVersion),\(buildinSoftwareVersion). Do you want Upgrade?", delegate: self, cancelButtonTitle: "Cancel")
                alert.addButtonWithTitle("Upgrade")
                alert.show()
            }else{

                nevoOtaView.setLatestVersion(NSLocalizedString("latestversion", comment: ""))
            }
        }
    }

    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
    
        if(buttonIndex==1){
            currentIndex = 0
            self.uploadPressed()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if (!self.isTransferring)
        {mNevoOtaController!.reset(true)}
    }

    override func viewDidAppear(animated: Bool) {
        mNevoOtaController!.setConnectControllerDelegate2Self()
    }
    
    //init data function
    private func initValue()
    {
        nevoOtaView.backButton.enabled = true
    }
    
    //upload button function
    func uploadPressed()
    {
        if currentIndex >= firmwareURLs.count {
            return
        }
        
        selectedFileURL = firmwareURLs[currentIndex]
        var fileExtension:String? = selectedFileURL!.pathExtension
        if fileExtension == "bin"
        {
            enumFirmwareType = DfuFirmwareTypes.SOFTDEVICE
        }
        if fileExtension == "hex"
        {
            enumFirmwareType = DfuFirmwareTypes.APPLICATION
        }
        
        if selectedFileURL == nil
        {
            var alert :UIAlertView = UIAlertView(title: "", message: "Please select NEVO file!", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            return
        }
        if (self.isTransferring) {
            isTransferring = false
            mNevoOtaController?.cancelDFU()
        }
        else {
            nevoOtaView.setProgress(0.0)
            self.nevoOtaView.setLatestVersion("Please wait...")
            isTransferring = true
            //when doing OTA, disable Cancel/Back button, enable them by callback function invoke initValue()/checkConnection()
            nevoOtaView.backButton.enabled = false
            mNevoOtaController?.performDFUOnFile(selectedFileURL!, firmwareType: enumFirmwareType)
        }
    }
    
    //below is delegate function
    
    func onDFUStarted(){
     NSLog("onDFUStarted");
    //here enable upload button
    }
    
    //user cancel
    func onDFUCancelled(){
        NSLog("onDFUCancelled");
        //reset OTA view controller 's some data, such as progress bar and upload button text/status
        dispatch_async(dispatch_get_main_queue(), {
        self.initValue()
        self.mNevoOtaController!.reset(false)
        });
    }

    //percent is[0..100]
    func onTransferPercentage(percent:Int){
        dispatch_async(dispatch_get_main_queue(), {

            self.nevoOtaView.setProgress((Float(percent)/100.0))
        });
    }
    
    //successfully
    func onSuccessfulFileTranferred(){
        dispatch_async(dispatch_get_main_queue(), {
            
            self.initValue()
            
            self.currentIndex = self.currentIndex + 1
            if self.currentIndex == self.firmwareURLs.count
            {
                var message = "Successful!,pls open Nevo's bluetooth."
                if self.enumFirmwareType == DfuFirmwareTypes.SOFTDEVICE
                {
                    message = "Successful!"
                }
                var alert :UIAlertView = UIAlertView(title: "Firmware Upgrade", message: message, delegate: nil, cancelButtonTitle: "OK")
                alert.show()
                self.nevoOtaView.upgradeSuccessful()
                self.mNevoOtaController!.reset(false)
            }
            else
            {
                var dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
                dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                    //MCU OTA done,the connection keep alive,continue do BLE OTA after 1s
                    self.uploadPressed()
                })
            }
            
            });
    
    }
    //Error happen
    func onError(errString : NSString){
    
        dispatch_async(dispatch_get_main_queue(), {
            
            self.initValue()
            
            var alert :UIAlertView = UIAlertView(title: "Firmware Upgrade", message: errString as String, delegate: nil, cancelButtonTitle: "OK")
            //alert.show()
            self.nevoOtaView.setLatestVersion(errString as String)
            self.mNevoOtaController!.reset(false)
        });

    }
    
    func connectionStateChanged(isConnected : Bool) {
        
        //Maybe we just got disconnected, let's check
        
        checkConnection()
    }

    /**
    see NevoOtaControllerDelegate
    */
    func firmwareVersionReceived(whichfirmware:DfuFirmwareTypes, version:NSString)
    {
        nevoOtaView.setVersionLbael(mNevoOtaController!.getSoftwareVersion(), bleNumber: mNevoOtaController!.getFirmwareVersion())
    }
    
    /**
    Checks if any device is currently connected
    */
    
    func checkConnection() {
        
        if mNevoOtaController != nil && !(mNevoOtaController!.isConnected()) {
            //disable upPress button

        }else{
            // enable upPress button
        }
        
    }


    // MARK: - ButtonManagerCallBack
    func controllManager(sender:AnyObject){

        if (sender.isEqual(nevoOtaView.backButton)) {
            NSLog("back2Home")
            self.dismissViewControllerAnimated(true, completion: nil)
        }

    }
    
    /**
    PtlSelectFile
    
    :param: path <#path description#>
    */
    func onFileSelected(selectedFile:NSURL){
        NSLog("onFileSelected")
        if (selectedFile.path != nil) {
            var fileName:String? = selectedFile.path!.lastPathComponent
            var fileExtension:String? = selectedFile.pathExtension
            var fileManager = NSFileManager.defaultManager()
            //set the file information
            
            selectedFileURL = selectedFile
            if fileExtension == "bin"
            {
               enumFirmwareType = DfuFirmwareTypes.SOFTDEVICE
            }
            if fileExtension == "hex"
            {
                enumFirmwareType = DfuFirmwareTypes.APPLICATION
            }
            
        }
    }
    
    /**
    <#Description#>
    
    :param: segue  <#segue description#>
    :param: sender <#sender description#>
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "Ota2SelectFile"){
            var selectFile = segue.destinationViewController as! SelectFileController
            selectFile.mFileDelegate = self
        }
    }
    
    
}

protocol PtlSelectFile {
    func onFileSelected(selectedFile:NSURL)
}
