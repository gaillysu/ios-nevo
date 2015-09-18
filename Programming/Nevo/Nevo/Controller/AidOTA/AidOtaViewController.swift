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

    private var mTimeoutTimer:NSTimer?

    private var hudView:MBProgressHUD?

    override func viewDidLayoutSubviews(){
        //init the view
        nevoOtaView.buildView(self,otacontroller: mAidOtaController!)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().idleTimerDisabled = true
        //
        let alert :UIAlertView = UIAlertView(title: "Use warnings", message: "In the use of first aid mode, please forget all relevant Nevo pairing in the system Bluetooth settings", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
        //init the ota
        mAidOtaController = AidOtaController(controller: self)
        mAidOtaController?.mConnectionController?.setOTAMode(true, Disconnect: false)

        initValue()
        
        checkConnection()

        let fileArray = GET_FIRMWARE_FILES("Firmwares")
        for tmpfile in fileArray {
            let selectedFile = tmpfile as! NSURL
            let fileName:String? = (selectedFile.path! as NSString).lastPathComponent
            let fileExtension:String? = selectedFile.pathExtension
            if fileExtension == "hex"
            {
                firmwareURLs.append(selectedFile)
                allTaskNumber++;
                break
            }
        }

        for tmpfile in fileArray {
            let selectedFile = tmpfile as! NSURL
            let fileName:String? = (selectedFile.path! as NSString).lastPathComponent
            let fileExtension:String? = selectedFile.pathExtension

            if fileExtension == "bin"
            {
                firmwareURLs.append(selectedFile)
                allTaskNumber++;
                break
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
            //onError(NSLocalizedString("update_error_noconnect", comment: "") as NSString)
            mAidOtaController!.reset(false)
            return
        }

        currentTaskNumber++;
        selectedFileURL = firmwareURLs[currentIndex]
        let fileExtension:String? = selectedFileURL!.pathExtension
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
            let alert :UIAlertView = UIAlertView(title: "Firmware Upgrade", message: message, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            nevoOtaView.ReUpgradeButton?.hidden = true
            nevoOtaView.upgradeSuccessful()
            mAidOtaController!.reset(false)
            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(3.0 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        }else{
            //mAidOtaController!.reset(false)
            //请确保重新点击配对按钮后再点击继续MCU升级,否则在升级的过程中会中断!
            let alert :UIAlertView = UIAlertView(title: "Firmware Upgrade", message: "Please make sure that the re click on the pairing button is clicked and then click on the MCU upgrade, otherwise it will be interrupted in the process of upgrading!", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            nevoOtaView.ReUpgradeButton?.hidden = false
            nevoOtaView.ReUpgradeButton?.setTitle("Upgrade the Ble", forState: UIControlState.Normal)
            if(mAidOtaController!.isConnected()){
                nevoOtaView.ReUpgradeButton?.setTitle("Continue MCU", forState: UIControlState.Normal)
            }else{
                nevoOtaView.ReUpgradeButton?.setTitle("Try to reconnect", forState: UIControlState.Normal)
                let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(3.0 * Double(NSEC_PER_SEC)))
                dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                    mAidOtaController?.mConnectionController?.setOTAMode(true,Disconnect:true)
                })
            }
        }
    }
    //Error happen
    func onError(errString : NSString){

        initValue()
        let alert :UIAlertView = UIAlertView(title: "Firmware Upgrade", message: errString as String, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
        mAidOtaController!.reset(false)
    }

    func connectionStateChanged(isConnected : Bool) {

        //Maybe we just got disconnected, let's check
        if(!isConnected){
            let SAVED_ADDRESS_KEY = "SAVED_ADDRESS"
            NSUserDefaults.standardUserDefaults().removeObjectForKey(SAVED_ADDRESS_KEY)
            nevoOtaView.ReUpgradeButton?.setTitle("Search Nevo", forState: UIControlState.Normal)
        }else{
            //MBProgressHUD.showSuccess("Nevo has been connected, you can upgrade")
            if(currentIndex != 0){
                nevoOtaView.ReUpgradeButton?.setTitle("Continue MCU", forState: UIControlState.Normal)
            }else{
                nevoOtaView.ReUpgradeButton?.setTitle("Search Nevo", forState: UIControlState.Normal)
            }
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
            let SAVED_ADDRESS_KEY = "SAVED_ADDRESS"
            NSUserDefaults.standardUserDefaults().removeObjectForKey(SAVED_ADDRESS_KEY)
            currentTaskNumber = currentIndex;
            if(mAidOtaController!.isConnected()){
                // reUpdate all firmwares
                uploadPressed()
            }else{
                hudView = MBProgressHUD.showMessage("Please later, in the connection.")
                hudView?.hide(true, afterDelay: 8)
                mTimeoutTimer = NSTimer.scheduledTimerWithTimeInterval(Double(1), target: self, selector:Selector("timeroutProc:"), userInfo: nil, repeats: true)
                mAidOtaController?.mConnectionController?.setOTAMode(true, Disconnect: true)
                // no connected nevo, disable update
            }
        }

    }

    func timeroutProc(timer:NSTimer){
        if(mAidOtaController!.isConnected()){
            timer.invalidate()
            //[[UIApplication sharedApplication].windows lastObject]
            hudView?.hide(true)
        }else{
            uploadPressed()
            //mAidOtaController?.setStatus(DFUControllerState.IDLE)
            //mAidOtaController?.mConnectionController?.setOTAMode(true, Disconnect: true)
        }

    }

}
