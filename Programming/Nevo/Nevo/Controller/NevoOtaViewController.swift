//
//  NevoOtaViewController.swift
//  Nevo
//
//  Created by supernova on 15/2/4.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class NevoOtaViewController: UIViewController,NevoOtaControllerDelegate,ButtonManagerCallBack,PtlSelectFile  {

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
    
    var mNevoOtaController : NevoOtaController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //init the view
        nevoOtaView.buildView(self)
        //init the ota
        mNevoOtaController = NevoOtaController(controller: self)
        checkConnection()
        initValue()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        mNevoOtaController!.reset()
    }
    
    //init data function
    private func initValue()
    {
        progressBar.setProgress(0.0, animated: false)
        ProgressLabel.text = ""
        upLoadStatus.text = ""
    }
    
    //upload button function
    func uploadPressed()
    {
        if selectedFileURL? == nil
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
            isTransferring = true
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
        self.mNevoOtaController!.reset()
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
            
            self.mNevoOtaController!.reset()
            });
    
    }
    //Error happen
    func onError(errString : NSString){
    
        dispatch_async(dispatch_get_main_queue(), {
            
            self.initValue()
            
            var alert :UIAlertView = UIAlertView(title: "Firmware Upgrade", message: errString, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
            self.mNevoOtaController!.reset()
            
        });

    }
    
    func connectionStateChanged(isConnected : Bool) {
        
        //Maybe we just got disconnected, let's check
        
        checkConnection()
        
    }
    
    
    
    /**
    Checks if any device is currently connected
    */
    
    func checkConnection() {
        
        if mNevoOtaController != nil && !(mNevoOtaController!.isConnected()) {
            //disable upPress button
            uploadBtn.enabled = false
        }
        else
        {
            // enable upPress button
            uploadBtn.enabled = true
        }
        
    }


    // MARK: - ButtonManagerCallBack
    func controllManager(sender:AnyObject){

        var senderString = sender as String
        if senderString == "selectWatchFile"{
            NSLog("selectWatchFile")
            self.performSegueWithIdentifier("Ota2SelectFile", sender: self)
        }else if senderString == "selectWatchDevice"{
            NSLog("selectWatchDevice")
            if enumFirmwareType == DfuFirmwareTypes.APPLICATION
            {
                
            }
            else if enumFirmwareType == DfuFirmwareTypes.SOFTDEVICE
            {
                
            }
            
            
        }else if senderString == "uploadFile"{
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
            var selectFile = segue.destinationViewController as SelectFileController
            selectFile.mFileDelegate = self
        }
    }
    
    
}

protocol PtlSelectFile {
    func onFileSelected(selectedFile:NSURL)
}
