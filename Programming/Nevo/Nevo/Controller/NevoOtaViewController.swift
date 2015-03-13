//
//  NevoOtaViewController.swift
//  Nevo
//
//  Created by supernova on 15/2/4.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class NevoOtaViewController: UIViewController,NevoOtaControllerDelegate,ButtonManagerCallBack  {

    @IBOutlet var nevoOtaView: NevoOtaView!
    
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
        if sender.isEqual(nevoOtaView.backButton) {
            self.dismissViewControllerAnimated(true, completion: nil)
            return
        }
        var senderString = sender as String
        if senderString == "selectWatchFile"{
            NSLog("selectWatchFile")
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
}
