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
    var buildinSoftwareVersion:Int  = 0
    var buildinFirmwareVersion:Int  = 0
    var firmwareURLs:[NSURL] = []
    var currentIndex = 0
    var mNevoOtaController : NevoOtaController?
    private var allTaskNumber:NSInteger = 0;//计算所有OTA任务数量
    private var currentTaskNumber:NSInteger = 0;//当前在第几个任务
    private var rssialert:UIAlertView?

    override func viewDidLayoutSubviews(){
        //init the view
        nevoOtaView.buildView(self,otacontroller: mNevoOtaController!)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().idleTimerDisabled = true

        //init the ota
        mNevoOtaController = NevoOtaController(controller: self)
        initValue()
    }

    override func viewDidAppear(animated: Bool) {
        mNevoOtaController!.setConnectControllerDelegate2Self()
        if(mNevoOtaController!.isConnected())
        {
            let currentSoftwareVersion:NSString = mNevoOtaController!.getSoftwareVersion()
            let currentFirmwareVersion:NSString = mNevoOtaController!.getFirmwareVersion()
            if((currentSoftwareVersion as String).isEmpty || (currentFirmwareVersion as String).isEmpty)
            {
                return
            }
            buildinSoftwareVersion = GET_SOFTWARE_VERSION()
            buildinFirmwareVersion = GET_FIRMWARE_VERSION()

            let fileArray = GET_FIRMWARE_FILES("Firmwares")

            if(currentFirmwareVersion.integerValue < buildinFirmwareVersion && currentSoftwareVersion != 0){
                for tmpfile in fileArray {
                    let selectedFile = tmpfile as! NSURL
                    let fileExtension:String? = selectedFile.pathExtension
                    if fileExtension == "hex"{
                        firmwareURLs.append(selectedFile)
                        allTaskNumber++
                        break
                    }
                }
            }

            if(currentSoftwareVersion.integerValue < buildinSoftwareVersion){
                for tmpfile in fileArray {
                    let selectedFile = tmpfile as! NSURL
                    let fileExtension:String? = selectedFile.pathExtension

                    if fileExtension == "bin"{
                        firmwareURLs.append(selectedFile)
                        allTaskNumber++
                        break
                    }
                }
            }

            if(currentSoftwareVersion.integerValue < buildinSoftwareVersion || currentFirmwareVersion.integerValue < buildinFirmwareVersion )
            {
                let updatemsg:String = NSLocalizedString("current FW version", comment: "") + "(\(currentFirmwareVersion),\(currentSoftwareVersion))," + NSLocalizedString("latest FW version", comment: "") + "(\(buildinFirmwareVersion),\(buildinSoftwareVersion)). " + NSLocalizedString("are you sure", comment: "")

                let alert :UIAlertView = UIAlertView(title: NSLocalizedString("Firmware Upgrade", comment: ""), message: updatemsg, delegate: self, cancelButtonTitle: NSLocalizedString("Cancel", comment: ""))
                alert.addButtonWithTitle(NSLocalizedString("Enter", comment: ""))
                alert.show()
            }else{
                nevoOtaView.setLatestVersion(NSLocalizedString("latestversion",comment: ""))

                #if DEBUG
                    nevoOtaView.ReUpgradeButton?.hidden = false
                #else
                    nevoOtaView.ReUpgradeButton?.hidden = true
                #endif
            }
        }
    }

    override func viewDidDisappear(animated: Bool) {
        UIApplication.sharedApplication().idleTimerDisabled = false
        if (!self.isTransferring)
        {mNevoOtaController!.reset(true)}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - UIAlertViewDelegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
    
        if(buttonIndex==1){
            currentIndex = 0
            uploadPressed()
        }
    }

    //MARK: -
    //init data function
    private func initValue()
    {
        nevoOtaView.backButton.enabled = true
        isTransferring = false
        nevoOtaView.ReUpgradeButton?.hidden = false //The process of OTA hide this control
    }
    
    //upload button function
    func uploadPressed()
    {
        if currentIndex >= firmwareURLs.count  || firmwareURLs.count == 0 {
            onError(NSLocalizedString("checking_firmware", comment: "") as NSString)
            return
        }
        
        if(!mNevoOtaController!.isConnected())
        {
            self.mNevoOtaController!.reset(false)
            //onError(NSLocalizedString("update_error_noconnect", comment: "") as NSString)
            return
        }
        
        currentTaskNumber++;
        selectedFileURL = firmwareURLs[currentIndex]
        let fileExtension:String? = selectedFileURL!.pathExtension
        if fileExtension == "bin"
        {
            enumFirmwareType = DfuFirmwareTypes.SOFTDEVICE
        }
        if fileExtension == "hex"
        {
            enumFirmwareType = DfuFirmwareTypes.APPLICATION
        }
        
            nevoOtaView.setProgress(0.0,currentTask: currentTaskNumber,allTask: allTaskNumber)
            nevoOtaView.setLatestVersion(NSLocalizedString("Please waiting...", comment: ""))
            isTransferring = true
            //when doing OTA, disable Cancel/Back button, enable them by callback function invoke initValue()/checkConnection()
            nevoOtaView.backButton.enabled = false
            nevoOtaView.ReUpgradeButton?.hidden = true //The process of OTA hide this control
            mNevoOtaController?.performDFUOnFile(selectedFileURL!, firmwareType: enumFirmwareType)
        
    }
    
    //below is delegate function
    
    func onDFUStarted(){
     AppTheme.DLog("onDFUStarted");
    //here enable upload button
    }

    //MARK: - NevoOtaControllerDelegate
    /**
    See SyncControllerDelegate
    */
    func receivedRSSIValue(number:NSNumber){
        //AppTheme.DLog("Red RSSI Value:\(number)")
        if(number.integerValue < -85){
            if(rssialert==nil){
                rssialert = UIAlertView(title: NSLocalizedString("Unstable connection ensure", comment: ""), message:NSLocalizedString("Unstable connection ensure phone is on and in range", comment: "") , delegate: nil, cancelButtonTitle: nil)
                rssialert?.show()
            }
        }else{
            rssialert?.dismissWithClickedButtonIndex(1, animated: true)
            rssialert = nil
        }
    }
    
    //user cancel
    func onDFUCancelled(){
        AppTheme.DLog("onDFUCancelled");
        //reset OTA view controller 's some data, such as progress bar and upload button text/status
        dispatch_async(dispatch_get_main_queue(), {
        self.initValue()
        self.mNevoOtaController!.reset(false)
        });
    }

    //percent is[0..100]
    func onTransferPercentage(percent:Int){
        dispatch_async(dispatch_get_main_queue(), {

            self.nevoOtaView.setProgress((Float(percent)/100.0),currentTask: self.currentTaskNumber,allTask: self.allTaskNumber)
        });
    }
    
    //successfully
    func onSuccessfulFileTranferred(){
        currentIndex = currentIndex + 1
        if currentIndex == firmwareURLs.count
        {
            initValue()
            var message = NSLocalizedString("UpdateSuccess1", comment: "")
            if enumFirmwareType == DfuFirmwareTypes.APPLICATION{
                message = NSLocalizedString("UpdateSuccess2", comment: "")
            }
            let alert :UIAlertView = UIAlertView(title: "Firmware Upgrade", message: message, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            self.nevoOtaView.upgradeSuccessful()
            self.mNevoOtaController!.reset(false)
            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        }else{
            //self.mNevoOtaController!.reset(false)
            mNevoOtaController!.setStatus(DFUControllerState.SEND_RESET)
            initValue()
            nevoOtaView.ReUpgradeButton?.setTitle("继续Mcu", forState: UIControlState.Normal)
            if(currentIndex == 1){
                //Ble升级完成请打开手表蓝牙,确保连接上并弹出配对信息点击配对后在点击继续Mcu按钮,不然会出现超时现象
                let alertTip :UIAlertView = UIAlertView(title: "Firmware Upgrade", message: "Ble upgrade completed please open the watch Bluetooth, to ensure that the connection has been connected to the Nevo and pop up on the information, click on the button to continue to click on the Mcu button, or there will be a timeout phenomenon", delegate: nil, cancelButtonTitle: "Ok")
                alertTip.show()
            }
            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(3.0 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                self.mNevoOtaController!.reset(false)
                //self.uploadPressed()
            })
        }

    }
    //Error happen
    func onError(errString : NSString){

        dispatch_async(dispatch_get_main_queue(), {
            
            self.initValue()
            
            let alert :UIAlertView = UIAlertView(title: "Firmware Upgrade", message: errString as String, delegate: nil, cancelButtonTitle: "OK")
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
        //nevoOtaView.setVersionLbael(mNevoOtaController!.getSoftwareVersion(), bleNumber: mNevoOtaController!.getFirmwareVersion())
    }
    
    /**
    Checks if any device is currently connected
    */
    
    func checkConnection() {
        
        if (mNevoOtaController != nil && !(mNevoOtaController!.isConnected() ) || isTransferring) {
            //disable upPress button
            nevoOtaView.ReUpgradeButton?.hidden = true
        }else{
            // enable upPress button
            nevoOtaView.ReUpgradeButton?.hidden = false
        }
        
    }


    // MARK: - ButtonManagerCallBack
    func controllManager(sender:AnyObject){

        if (sender.isEqual(nevoOtaView.backButton)) {
            AppTheme.DLog("back2Home")
            self.dismissViewControllerAnimated(true, completion: nil)
        }

        if(sender.isEqual(nevoOtaView.ReUpgradeButton)){
            let SAVED_ADDRESS_KEY = "SAVED_ADDRESS"
            NSUserDefaults.standardUserDefaults().removeObjectForKey(SAVED_ADDRESS_KEY)
            self.mNevoOtaController!.reset(false)
            uploadPressed()
            if(mNevoOtaController!.isConnected()){
                //currentTaskNumber = 0;
                //allTaskNumber = 0;
                //firmwareURLs = []
                //currentIndex = 0
                // reUpdate all firmwares
            }else{
                // no connected nevo, disable update
            }
        }

    }
    
    /**
    PtlSelectFile
    
    :param: path <#path description#>
    */
    func onFileSelected(selectedFile:NSURL){
        AppTheme.DLog("onFileSelected")
        if (selectedFile.path != nil) {
            let fileExtension:String? = selectedFile.pathExtension
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
            let selectFile = segue.destinationViewController as! SelectFileController
            selectFile.mFileDelegate = self
        }
    }
    
    
}

protocol PtlSelectFile {
    func onFileSelected(selectedFile:NSURL)
}
