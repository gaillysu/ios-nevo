//
//  NevoOtaViewController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/21.
//  Copyright © 2015年 Nevo. All rights reserved.
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
    private var continueButton:UIButton = UIButton(type: UIButtonType.Custom)

    init() {
        super.init(nibName: "NevoOtaViewController", bundle: NSBundle.mainBundle())

    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().idleTimerDisabled = true
        self.navigationItem.title = NSLocalizedString("Upgrade", comment:"")
        //init the ota
        mNevoOtaController = NevoOtaController(controller: self)

        //init the view

        initValue()
        nevoOtaView.setProgress(0, currentTask: currentTaskNumber,allTask: allTaskNumber, progressString: "BLE")
    }

    override func viewDidLayoutSubviews() {
        nevoOtaView.buildView(self,otacontroller: mNevoOtaController!)
    }

    override func viewDidAppear(animated: Bool) {
        mNevoOtaController!.setConnectControllerDelegate2Self()
        if(mNevoOtaController!.isConnected()) {
            let currentSoftwareVersion:NSString = mNevoOtaController!.getSoftwareVersion()
            let currentFirmwareVersion:NSString = mNevoOtaController!.getFirmwareVersion()
            if((currentSoftwareVersion as String).isEmpty || (currentFirmwareVersion as String).isEmpty) {
                return
            }
            buildinSoftwareVersion = AppTheme.GET_SOFTWARE_VERSION()
            buildinFirmwareVersion = AppTheme.GET_FIRMWARE_VERSION()

            let fileArray = AppTheme.GET_FIRMWARE_FILES("Firmwares")

            if(currentFirmwareVersion.integerValue < buildinFirmwareVersion && currentSoftwareVersion.integerValue != 0) {
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

            if(currentSoftwareVersion.integerValue < buildinSoftwareVersion) {
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
            if(currentSoftwareVersion.integerValue < buildinSoftwareVersion) {
                nevoOtaView.setProgress(0.0, currentTask: currentTaskNumber,allTask: allTaskNumber, progressString: "MCU")
            }

            if(currentFirmwareVersion.integerValue < buildinFirmwareVersion ) {
                nevoOtaView.setProgress(0.0, currentTask: currentTaskNumber,allTask: allTaskNumber, progressString: "BLE")
            }

            if(currentSoftwareVersion.integerValue < buildinSoftwareVersion || currentFirmwareVersion.integerValue < buildinFirmwareVersion ) {
                let updateTitle:String = NSLocalizedString("do_not_exit_this_screen", comment: "")
                let updatemsg:String = NSLocalizedString("please_follow_the_update_has_been_finished", comment: "")
                if((UIDevice.currentDevice().systemVersion as NSString).floatValue>8.0){
                    let alert :UIAlertController = UIAlertController(title: updateTitle, message: updatemsg, preferredStyle: UIAlertControllerStyle.Alert)
                    let alertAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.Cancel) { (action:UIAlertAction) -> Void in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    alert.addAction(alertAction)

                    let alertAction2:UIAlertAction = UIAlertAction(title: NSLocalizedString("Enter", comment: ""), style: UIAlertActionStyle.Default) { (action:UIAlertAction) -> Void in
                        self.currentIndex = 0
                        self.uploadPressed()
                    }
                    alert.addAction(alertAction2)
                    self.presentViewController(alert, animated: true, completion: nil)

                }else{
                    let alert :UIAlertView = UIAlertView(title: updateTitle, message: updatemsg, delegate: self, cancelButtonTitle: NSLocalizedString("Cancel", comment: ""))
                    alert.addButtonWithTitle(NSLocalizedString("Enter", comment: ""))
                    alert.show()
                }
            }else {

                #if DEBUG
                    //nevoOtaView.ReUpgradeButton?.hidden = false
                #else
                    //nevoOtaView.ReUpgradeButton?.hidden = true
                #endif
            }
        }
    }

    override func viewDidDisappear(animated: Bool) {
        UIApplication.sharedApplication().idleTimerDisabled = false
        if (!self.isTransferring) {
            mNevoOtaController!.reset(true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - UIAlertViewDelegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if(buttonIndex==1) {
            currentIndex = 0
            uploadPressed()
        }

        if(buttonIndex==0) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    //MARK: -
    //init data function
    private func initValue() {
        isTransferring = false
    }

    //upload button function
    func uploadPressed() {
        if currentIndex >= firmwareURLs.count  || firmwareURLs.count == 0 {
            onError(NSLocalizedString("checking_firmware", comment: "") as NSString)
            return
        }

        if(!mNevoOtaController!.isConnected()) {
            self.mNevoOtaController!.reset(false)
            //onError(NSLocalizedString("update_error_noconnect", comment: "") as NSString)
            return
        }

        currentTaskNumber++;
        selectedFileURL = firmwareURLs[currentIndex]
        let fileExtension:String? = selectedFileURL!.pathExtension
        if fileExtension == "bin" {
            enumFirmwareType = DfuFirmwareTypes.SOFTDEVICE
            nevoOtaView.setProgress(0.0, currentTask: currentTaskNumber,allTask: allTaskNumber, progressString: "Mcu")
        }
        if fileExtension == "hex" {
            enumFirmwareType = DfuFirmwareTypes.APPLICATION
            nevoOtaView.setProgress(0.0, currentTask: currentTaskNumber,allTask: allTaskNumber, progressString: "BLE")
        }
        isTransferring = true
        mNevoOtaController?.performDFUOnFile(selectedFileURL!, firmwareType: enumFirmwareType)

    }

    //below is delegate function

    func onDFUStarted() {
        AppTheme.DLog("onDFUStarted");
        //here enable upload button
    }

    //MARK: - NevoOtaControllerDelegate
    /**
    See SyncControllerDelegate
    */
    func receivedRSSIValue(number:NSNumber) {
        //AppTheme.DLog("Red RSSI Value:\(number)")
        if(number.integerValue < -85) {
            if(rssialert==nil) {
                rssialert = UIAlertView(title: NSLocalizedString("Unstable connection ensure", comment: ""), message:NSLocalizedString("Unstable connection ensure phone is on and in range", comment: "") , delegate: nil, cancelButtonTitle: nil)
                rssialert?.show()
            }
        }else {
            rssialert?.dismissWithClickedButtonIndex(1, animated: true)
            rssialert = nil
        }
    }

    //user cancel
    func onDFUCancelled() {
        AppTheme.DLog("onDFUCancelled");
        //reset OTA view controller 's some data, such as progress bar and upload button text/status
        dispatch_async(dispatch_get_main_queue(), {
            self.initValue()
            self.mNevoOtaController!.reset(false)
        });
    }

    //percent is[0..100]
    func onTransferPercentage(percent:Int) {
        nevoOtaView.setProgress((Float(percent)/100.0), currentTask: currentTaskNumber, allTask: allTaskNumber, progressString: enumFirmwareType == DfuFirmwareTypes.APPLICATION ? "BLE":"Mcu")
    }

    //successfully
    func onSuccessfulFileTranferred() {
        currentIndex = currentIndex + 1
        if currentIndex == firmwareURLs.count {
            initValue()
            self.nevoOtaView.upgradeSuccessful()
            self.mNevoOtaController!.reset(false)
            nevoOtaView.updatingView.hidden = true
            nevoOtaView.backView.hidden = false

        }else{
            mNevoOtaController!.setStatus(DFUControllerState.SEND_RESET)

            initValue()

            if(currentIndex == 1) {
                //Ble升级完成请打开手表蓝牙,确保连接上并弹出配对信息,点击配对按钮后在点击继续Mcu按钮,不然会出现超时现象
                let alertTip :UIAlertView = UIAlertView(title: NSLocalizedString("Firmware Upgrade", comment: ""), message: NSLocalizedString("update_ble_success_message", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("Ok", comment: ""))
                alertTip.show()

                nevoOtaView.nevoWacthImage.image = UIImage(named: "4_clock_dial")
                self.nevoOtaView.updatingView.hidden = true
                nevoOtaView.OTAprogressViewHiddenOrNotHidden()

                let titleLabel:UILabel = UILabel(frame: CGRectMake(0,  nevoOtaView.nevoWacthImage.frame.origin.y + nevoOtaView.nevoWacthImage.frame.size.height+10, UIScreen.mainScreen().bounds.size.width, 35))
                //titleLabel.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2.0, UIScreen.mainScreen().bounds.size.height-100)
                titleLabel.font = AppTheme.FONT_SFCOMPACTDISPLAY_BOLD(mSize: 19)
                titleLabel.text = NSLocalizedString("press_the_third_button", comment: "")
                titleLabel.textAlignment = NSTextAlignment.Center
                titleLabel.tag = 1360
                self.view.addSubview(titleLabel)

                let titleLabel2:UILabel = UILabel(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 50))
                titleLabel2.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2.0, (titleLabel.frame.origin.y+titleLabel.frame.size.height)+25)
                titleLabel2.font = AppTheme.FONT_SFCOMPACTDISPLAY_LIGHT(mSize: 16)
                titleLabel2.text = NSLocalizedString("in_order_reactivate_bluetooth", comment: "")
                titleLabel2.numberOfLines = 0
                titleLabel2.textAlignment = NSTextAlignment.Center
                titleLabel2.tag = 1361
                self.view.addSubview(titleLabel2)

                continueButton.setTitle(NSLocalizedString("Continue", comment: ""), forState: UIControlState.Normal)
                continueButton.setTitleColor(AppTheme.NEVO_SOLAR_YELLOW(), forState: UIControlState.Normal)
                continueButton.frame = CGRectMake(0, 0, 135, 35)
                continueButton.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2.0, (titleLabel2.frame.origin.y+titleLabel2.frame.size.height)+17)
                continueButton.addTarget(self, action: Selector("controllManager:"), forControlEvents: UIControlEvents.TouchUpInside)
                continueButton.layer.masksToBounds = true
                continueButton.layer.cornerRadius = 8.0
                continueButton.layer.borderWidth = 1.0
                continueButton.layer.borderColor = AppTheme.NEVO_SOLAR_YELLOW().CGColor
                self.view.addSubview(continueButton)
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

            let alert :UIAlertView = UIAlertView(title: NSLocalizedString("Firmware Upgrade", comment: ""), message: errString as String, delegate: nil, cancelButtonTitle: NSLocalizedString("Ok", comment: ""))
            alert.show()
            self.mNevoOtaController!.reset(false)
            self.currentTaskNumber--;
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

        }else {
            // enable upPress button
        }
    }


    // MARK: - ButtonManagerCallBack
    func controllManager(sender:AnyObject) {
        if(continueButton.isEqual(sender)){
            let SAVED_ADDRESS_KEY = "SAVED_ADDRESS"
            NSUserDefaults.standardUserDefaults().removeObjectForKey(SAVED_ADDRESS_KEY)
            self.mNevoOtaController!.reset(false)
            uploadPressed()

            for(var index:Int = 0; index<2; index++) {
                let view  = self.view.viewWithTag(1360+index)
                if(view != nil) {
                    view?.hidden = true
                }
            }
            continueButton.hidden = true
            self.nevoOtaView.updatingView.hidden = false
            nevoOtaView.nevoWacthImage.image = UIImage(named: "upgrade_clock.png")
            nevoOtaView.OTAprogressViewHiddenOrNotHidden()
        }

        if(nevoOtaView.backButton.isEqual(sender)) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    /**
     PtlSelectFile

     :param: path <#path description#>
     */
    func onFileSelected(selectedFile:NSURL) {
        AppTheme.DLog("onFileSelected")
        if (selectedFile.path != nil) {
            let fileExtension:String? = selectedFile.pathExtension
            //set the file information

            selectedFileURL = selectedFile
            if fileExtension == "bin" {
                enumFirmwareType = DfuFirmwareTypes.SOFTDEVICE
            }

            if fileExtension == "hex" {
                enumFirmwareType = DfuFirmwareTypes.APPLICATION
            }
        }
    }
    
}

protocol PtlSelectFile {
    func onFileSelected(selectedFile:NSURL)
}
