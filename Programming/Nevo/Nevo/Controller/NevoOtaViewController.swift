//
//  NevoOtaViewController.swift
//  Nevo
//
//  Created by supernova on 15/2/4.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class NevoOtaViewController: UIViewController,NevoOtaControllerDelegate {

    var isTransferring:Bool = false
    var enumFirmwareType:DfuFirmwareTypes?=DfuFirmwareTypes.APPLICATION
    var selectedFileURL:NSURL?
    
    var mNevoOtaController : NevoOtaController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
     //   selectedFileURL = NSURL(string: "file://firmware/imaze_BLE_R2.hex")!
        enumFirmwareType? = DfuFirmwareTypes.APPLICATION
    }
    
    //upload button function
    func uploadPressed()
    {
        if (self.isTransferring) {
            mNevoOtaController?.cancelDFU()
        }
        else {
            mNevoOtaController?.performDFUOnFile(selectedFileURL!, firmwareType: enumFirmwareType!)
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
    

}
