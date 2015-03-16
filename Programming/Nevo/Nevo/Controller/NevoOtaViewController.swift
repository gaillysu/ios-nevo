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
        initValue()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //init data function
    private func initValue()
    {
        //TODO
       // var files = AppTheme.GET_FIRMWARE_FILES("Firmwares")
        
        selectedFileURL = NSURL(string: "file://firmwares/iMaze_v9.bin")!
        enumFirmwareType = DfuFirmwareTypes.SOFTDEVICE
    }
    
    //upload button function
    func uploadPressed()
    {
        if (self.isTransferring) {
            mNevoOtaController?.cancelDFU()
        }
        else {
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
        initValue()
    }

    //percent is[0..100]
    func onTransferPercentage(percent:Int){
        
    }
    
    //successfully
    func onSuccessfulFileTranferred(){
        dispatch_async(dispatch_get_main_queue(), {
            
            self.initValue()
            
            var alert :UIAlertView = UIAlertView(title: "Firmware Upgrade", message: "Successful!", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
            
            });
    
    }
    //Error happen
    func onError(errString : NSString){
    
        dispatch_async(dispatch_get_main_queue(), {
            
            self.initValue()
            
            var alert :UIAlertView = UIAlertView(title: "Firmware Upgrade", message: errString, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
            
        });

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
