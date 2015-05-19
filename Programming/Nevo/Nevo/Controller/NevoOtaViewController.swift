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
    
    @IBOutlet weak var labelFileName: UILabel!
    @IBOutlet var labelFileSize: UILabel!
    @IBOutlet var labelFIleTypes: UILabel!
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var ProgressLabel: UILabel!
    @IBOutlet weak var upLoadStatus: UILabel!
    
    var isTransferring:Bool = false
    var enumFirmwareType:DfuFirmwareTypes = DfuFirmwareTypes.APPLICATION
    var selectedFileURL:NSURL?
    //save the build-in firmware version, it should be the latest FW version
    var buildinSoftwareVersion:Int  = 12
    var buildinFirmwareVersion:Int  = 25
    
    var mNevoOtaController : NevoOtaController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //init the view
        nevoOtaView.buildView(self)
        //init the ota
        mNevoOtaController = NevoOtaController(controller: self)
        initValue()
        checkConnection()
        
        var fileArray = GET_FIRMWARE_FILES("Firmwares")
        for tmpfile in fileArray {
            var selectedFile = tmpfile as! NSURL
            var fileName:String? = selectedFile.path!.lastPathComponent
            var fileExtension:String? = selectedFile.pathExtension
            //get build in FW version from the file name
            if fileExtension == "bin"
            {
               //buildinSoftwareVersion =
            }
            if fileExtension == "hex"
            {
                //buildinFirmwareVersion =
            }
        }
        if(mNevoOtaController!.isConnected())
        {
            var currentSoftwareVersion = mNevoOtaController!.getSoftwareVersion() as String
            var currentFirmwareVersion = mNevoOtaController!.getFirmwareVersion() as String
            
            if(currentSoftwareVersion.toInt() < buildinSoftwareVersion
               || currentFirmwareVersion.toInt() < buildinFirmwareVersion )
            {
                var alert :UIAlertView = UIAlertView(title: "Firmware Version", message: "the nevo Firmware version:\(currentFirmwareVersion),\(currentSoftwareVersion) is not the lastest version:\(buildinFirmwareVersion),\(buildinSoftwareVersion)", delegate: self, cancelButtonTitle: "Cancel")
                alert.addButtonWithTitle("Upgrade")
               // alert.show()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        mNevoOtaController!.reset(true)
    }

    override func viewDidAppear(animated: Bool) {
        mNevoOtaController!.setConnectControllerDelegate2Self()
    }
    
    //init data function
    private func initValue()
    {
        progressBar.setProgress(0.0, animated: false)
        ProgressLabel.text = ""
        upLoadStatus.text = ""
        isTransferring = false
        uploadBtn.setTitle("Upload", forState: UIControlState.Normal)
        uploadBtn.hidden  = false
        uploadBtn.enabled = false
        nevoOtaView.backButton.enabled = true
        nevoOtaView.selectFileButton.enabled = true
    }
    
    //upload button function
    func uploadPressed()
    {
        if selectedFileURL == nil
        {
            var alert :UIAlertView = UIAlertView(title: "", message: "Please select NEVO file!", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            return
        }
        if (self.isTransferring) {
            isTransferring = false
            uploadBtn.setTitle("Upload", forState: UIControlState.Normal)
            mNevoOtaController?.cancelDFU()
        }
        else {
            isTransferring = true
            uploadBtn.setTitle("Cancel", forState: UIControlState.Normal)
            //when doing OTA, disable Cancel/Back button, enable them by callback function invoke initValue()/checkConnection()
            uploadBtn.hidden = true
            nevoOtaView.backButton.enabled = false
            nevoOtaView.selectFileButton.enabled = false
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
        self.progressBar.setProgress((Float(percent)/100.0), animated: false)
        self.ProgressLabel.text = "\(percent) %"
        });
    }
    
    //successfully
    func onSuccessfulFileTranferred(){
        dispatch_async(dispatch_get_main_queue(), {
            
            self.initValue()
            
            var alert :UIAlertView = UIAlertView(title: "Firmware Upgrade", message: "Successful!,pls open Nevo's bluetooth.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
            self.mNevoOtaController!.reset(false)
            
            });
    
    }
    //Error happen
    func onError(errString : NSString){
    
        dispatch_async(dispatch_get_main_queue(), {
            
            self.initValue()
            
            var alert :UIAlertView = UIAlertView(title: "Firmware Upgrade", message: errString as String, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
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
        upLoadStatus.text = "Firmware version BLE:"+(mNevoOtaController!.getFirmwareVersion() as String) + ",MCU:" +  (mNevoOtaController!.getSoftwareVersion() as String)
    }
    
    /**
    Checks if any device is currently connected
    */
    
    func checkConnection() {
        
        if mNevoOtaController != nil && !(mNevoOtaController!.isConnected()) {
            //disable upPress button
            uploadBtn.enabled = false
            upLoadStatus.text = ""
        }
        else
        {
            // enable upPress button
            uploadBtn.enabled = true
            upLoadStatus.text = "Firmware version BLE:"+(mNevoOtaController!.getFirmwareVersion() as String) + ",MCU:" +  (mNevoOtaController!.getSoftwareVersion() as String)
        }
        self.view.bringSubviewToFront(nevoOtaView.titleBgView)
        
    }


    // MARK: - ButtonManagerCallBack
    func controllManager(sender:AnyObject){

        if (sender.isEqual(nevoOtaView.selectFileButton)){
            NSLog("selectWatchFile")
            self.performSegueWithIdentifier("Ota2SelectFile", sender: self)
        }else if (sender.isEqual(nevoOtaView.backButton)) {
            NSLog("back2Home")
            self.dismissViewControllerAnimated(true, completion: nil)
            //self.navigationController?.popViewControllerAnimated(true)
        }else if (sender.isEqual(nevoOtaView.uploadButton)){
            NSLog("uploadFile")
            uploadPressed()
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
            //var fileAttr = fileManager.attributesOfItemAtPath(selectedFile, error: nil)
            //set the file information
            if let name = fileName{
                labelFileName.text = fileName
            }
            if let data:NSData = NSData(contentsOfURL: selectedFile){
                labelFileSize.text = String(data.length)
            }
            if let fextension = fileExtension{
                labelFIleTypes.text = fextension
            }
            
            selectedFileURL = selectedFile
            if fileExtension == "bin"
            {
               enumFirmwareType = DfuFirmwareTypes.SOFTDEVICE
               labelFIleTypes.text = "MCU firmware"
            }
            if fileExtension == "hex"
            {
                enumFirmwareType = DfuFirmwareTypes.APPLICATION
                labelFIleTypes.text = "BLE firmware"
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
