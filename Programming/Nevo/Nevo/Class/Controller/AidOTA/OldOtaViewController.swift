//
//  AidOtaViewController.swift
//  Nevo
//
//  Created by leiyuncun on 15/9/15.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit
import XCGLogger

class OldOtaViewController: UIViewController,NevoOtaControllerDelegate,ButtonManagerCallBack,UIAlertViewDelegate  {

    @IBOutlet var nevoOtaView: NevoOtaView!


    var isTransferring:Bool = false
    var enumFirmwareType:DfuFirmwareTypes = DfuFirmwareTypes.application
    var selectedFileURL:URL?
    //save the build-in firmware version, it should be the latest FW version
    var buildinSoftwareVersion:Int  = 0
    var buildinFirmwareVersion:Int  = 0
    var firmwareURLs:[URL] = []
    var currentIndex = 0
    var mAidOtaController : AidOtaController?
    fileprivate var allTaskNumber:NSInteger = 0;//计算所有OTA任务数量
    fileprivate var currentTaskNumber:NSInteger = 0;//当前在第几个任务

    fileprivate var mTimeoutTimer:Timer?

    fileprivate var hudView:MBProgressHUD?

    fileprivate var rssialert :UIAlertView?

    override func viewDidLayoutSubviews(){
        //init the view
        nevoOtaView.buildView(self,otacontroller: mAidOtaController!)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        //
        let alert :UIAlertView = UIAlertView(title: "Use warnings", message: "In the use of first aid mode, please forget all relevant Nevo pairing in the system Bluetooth settings", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
        //init the ota
        mAidOtaController = AidOtaController(controller: self)
        mAidOtaController?.mConnectionController?.setOTAMode(true, Disconnect: false)

        initValue()
        
        checkConnection()

        let fileArray = AppTheme.GET_FIRMWARE_FILES("Firmwares")
        for tmpfile in fileArray {
            let selectedFile = tmpfile as! URL
            //let fileName:String? = (selectedFile.path! as NSString).lastPathComponent
            let fileExtension:String? = selectedFile.pathExtension
            if fileExtension == "hex"
            {
                firmwareURLs.append(selectedFile)
                allTaskNumber+=1;
                break
            }
        }

        for tmpfile in fileArray {
            let selectedFile = tmpfile as! URL
            //let fileName:String? = (selectedFile.path! as NSString).lastPathComponent
            let fileExtension:String? = selectedFile.pathExtension

            if fileExtension == "bin"
            {
                firmwareURLs.append(selectedFile)
                allTaskNumber+=1;
                break
            }
        }
        
        let updateTitle:String = NSLocalizedString("do_not_exit_this_screen", comment: "")
        let updatemsg:String = NSLocalizedString("please_follow_the_update_has_been_finished", comment: "")
        if((UIDevice.current.systemVersion as NSString).floatValue>8.0){
            let alert :UIAlertController = UIAlertController(title: updateTitle, message: updatemsg, preferredStyle: UIAlertControllerStyle.alert)
            alert.view.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
            let alertAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel) { (action:UIAlertAction) -> Void in
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(alertAction)
            
            let alertAction2:UIAlertAction = UIAlertAction(title: NSLocalizedString("Enter", comment: ""), style: UIAlertActionStyle.default) { (action:UIAlertAction) -> Void in
                self.currentIndex = 0
                self.uploadPressed()
            }
            alert.addAction(alertAction2)
            self.present(alert, animated: true, completion: nil)
            
        }else{
            let alert :UIAlertView = UIAlertView(title: updateTitle, message: updatemsg, delegate: self, cancelButtonTitle: NSLocalizedString("Cancel", comment: ""))
            alert.addButton(withTitle: NSLocalizedString("Enter", comment: ""))
            alert.show()
        }

    }

    override func viewDidAppear(_ animated: Bool) {
        mAidOtaController!.setConnectControllerDelegate2Self()
    }

    override func viewDidDisappear(_ animated: Bool) {
        UIApplication.shared.isIdleTimerDisabled = false
        if (!self.isTransferring){
            mAidOtaController!.reset(true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //init data function
    fileprivate func initValue(){
        isTransferring = false

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

        currentTaskNumber += 1;
        selectedFileURL = firmwareURLs[currentIndex]
        let fileExtension:String? = selectedFileURL!.pathExtension
        if fileExtension == "bin"{
            enumFirmwareType = DfuFirmwareTypes.softdevice
        }
        if fileExtension == "hex"{
            enumFirmwareType = DfuFirmwareTypes.application
        }

        nevoOtaView.setProgress(0.0,currentTask: currentTaskNumber,allTask: allTaskNumber, progressString: "BLE")
        nevoOtaView.setLatestVersion(NSLocalizedString("Please wait...", comment: ""))
        isTransferring = true
        //when doing OTA, disable Cancel/Back button, enable them by callback function invoke initValue()/checkConnection()
        mAidOtaController?.performDFUOnFile(selectedFileURL!, firmwareType: enumFirmwareType)

    }

    /**
    Checks if any device is currently connected
    */

    func checkConnection() {

        if (mAidOtaController != nil && !(mAidOtaController!.isConnected() ) || isTransferring) {
            //disable upPress button
        }else{
            // enable upPress button
        }
        
    }

    //MARK: - UIAlertViewDelegate
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int){

        if(buttonIndex==1){
            currentIndex = 0
            self.uploadPressed()
        }
    }

    //MARK: - NevoOtaControllerDelegate
    /**
    See SyncControllerDelegate
    */
    func receivedRSSIValue(_ number:NSNumber){
        XCGLogger.default.debug("Red RSSI Value:\(number)")
        if(number.int32Value < -85){
            if(rssialert==nil){
                rssialert = UIAlertView(title: NSLocalizedString("Unstable connection ensure", comment: ""), message:NSLocalizedString("Unstable connection ensure phone is on and in range", comment: "") , delegate: nil, cancelButtonTitle: nil)
                rssialert?.show()
            }
        }else{
            rssialert?.dismiss(withClickedButtonIndex: 1, animated: true)
            rssialert = nil
        }
    }

    //below is delegate function
    func onDFUStarted(){
        XCGLogger.default.debug("onDFUStarted");
        //here enable upload button
    }

    //user cancel
    func onDFUCancelled(){
        XCGLogger.default.debug("onDFUCancelled");
        //reset OTA view controller 's some data, such as progress bar and upload button text/status
        initValue()
        mAidOtaController!.reset(false)
    }

    //percent is[0..100]
    func onTransferPercentage(_ percent:Int){
        nevoOtaView.setProgress((Float(percent)/100.0), currentTask: currentTaskNumber,allTask: allTaskNumber, progressString: "BLE")
    }

    //successfully
    func onSuccessfulFileTranferred(){
        currentIndex = currentIndex + 1
        if currentIndex == firmwareURLs.count {
            initValue()
            var message = NSLocalizedString("UpdateSuccess1", comment: "")
            if enumFirmwareType == DfuFirmwareTypes.application{
                message = NSLocalizedString("UpdateSuccess2", comment: "")
            }
            let alert :UIAlertView = UIAlertView(title: "Firmware Upgrade", message: message, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            nevoOtaView.upgradeSuccessful()
            mAidOtaController!.reset(false)
            let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(3.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                self.dismiss(animated: true, completion: nil)
            })
        }else{
            //mAidOtaController!.reset(false)
            //请确保重新点击配对按钮后再点击继续MCU升级,否则在升级的过程中会中断!
            let alert :UIAlertView = UIAlertView(title: "Firmware Upgrade", message: "Please make sure that the re click on the pairing button is clicked and then click on the MCU upgrade, otherwise it will be interrupted in the process of upgrading!", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            //nevoOtaView.ReUpgradeButton?.hidden = false
            //nevoOtaView.ReUpgradeButton?.setTitle("Upgrade the Ble", forState: UIControlState.Normal)
            if(mAidOtaController!.isConnected()){
                //nevoOtaView.ReUpgradeButton?.setTitle("Continue MCU", forState: UIControlState.Normal)
            }else{
                //nevoOtaView.ReUpgradeButton?.setTitle("Try to reconnect", forState: UIControlState.Normal)
                let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(3.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                    self.mAidOtaController?.mConnectionController?.setOTAMode(true,Disconnect:true)
                })
            }
        }
    }
    //Error happen
    func onError(_ errString : NSString){

        initValue()
        let alert :UIAlertView = UIAlertView(title: "Firmware Upgrade", message: errString as String, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
        mAidOtaController!.reset(false)
    }

    func connectionStateChanged(_ isConnected : Bool) {

        //Maybe we just got disconnected, let's check
        if(!isConnected){
            let SAVED_ADDRESS_KEY = "SAVED_ADDRESS"
            UserDefaults.standard.removeObject(forKey: SAVED_ADDRESS_KEY)
            //nevoOtaView.ReUpgradeButton?.setTitle("Search Nevo", forState: UIControlState.Normal)
        }else{
            //MBProgressHUD.showSuccess("Nevo has been connected, you can upgrade")
            if(currentIndex != 0){
                //nevoOtaView.ReUpgradeButton?.setTitle("Continue MCU", forState: UIControlState.Normal)
            }else{
                //nevoOtaView.ReUpgradeButton?.setTitle("Search Nevo", forState: UIControlState.Normal)
            }
        }

    }

    /**
    see NevoOtaControllerDelegate
    */
    func firmwareVersionReceived(_ whichfirmware:DfuFirmwareTypes, version:NSString)
    {
        //nevoOtaView.setVersionLbael(mNevoOtaController!.getSoftwareVersion(), bleNumber: mNevoOtaController!.getFirmwareVersion())
    }

    // MARK: - ButtonManagerCallBack
    func controllManager(_ sender:AnyObject) {
        let SAVED_ADDRESS_KEY = "SAVED_ADDRESS"
        UserDefaults.standard.removeObject(forKey: SAVED_ADDRESS_KEY)
        currentTaskNumber = currentIndex;
        if(mAidOtaController!.isConnected()){
            // reUpdate all firmwares
            uploadPressed()
        }else{
            hudView = MBProgressHUD.showMessage("Please later, in the connection.")
            hudView?.hide(true, afterDelay: 8)
            mTimeoutTimer = Timer.scheduledTimer(timeInterval: Double(1), target: self, selector:#selector(timeroutProc(_:)), userInfo: nil, repeats: true)
            mAidOtaController?.mConnectionController?.setOTAMode(true, Disconnect: true)
            // no connected nevo, disable update
        }

    }

    func timeroutProc(_ timer:Timer){
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
