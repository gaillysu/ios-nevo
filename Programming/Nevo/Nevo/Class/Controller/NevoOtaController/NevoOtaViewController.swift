//
//  NevoOtaViewController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/21.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit
import XCGLogger

protocol ButtonManagerCallBack {
    func controllManager(_ sender:AnyObject)
}

class NevoOtaViewController: UIViewController,NevoOtaControllerDelegate,ButtonManagerCallBack,PtlSelectFile,UIAlertViewDelegate  {

    @IBOutlet var nevoOtaView: NevoOtaView!

    var isTransferring:Bool = false
    var enumFirmwareType:DfuFirmwareTypes = DfuFirmwareTypes.application
    var selectedFileURL:URL?
    //save the build-in firmware version, it should be the latest FW version
    var buildinSoftwareVersion:Int  = 0
    var buildinFirmwareVersion:Int  = 0
    var firmwareURLs:[URL] = []
    var currentIndex = 0
    var mNevoOtaController : NevoOtaController?
    fileprivate var allTaskNumber:NSInteger = 0;//计算所有OTA任务数量
    fileprivate var currentTaskNumber:NSInteger = 0;//当前在第几个任务
    fileprivate var continueButton:UIButton = UIButton(type: UIButtonType.custom)

    init() {
        super.init(nibName: "NevoOtaViewController", bundle: Bundle.main)

    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        self.navigationItem.title = NSLocalizedString("Upgrade", comment:"")
        //init the ota
        mNevoOtaController = NevoOtaController(controller: self)

        //init the view

        initValue()
        nevoOtaView.setProgress(0, currentTask: currentTaskNumber,allTask: allTaskNumber, progressString: "BLE")
    }

    override func viewDidLayoutSubviews() {
        nevoOtaView.buildView(self)
    }

    override func viewDidAppear(_ animated: Bool) {
        mNevoOtaController!.setConnectControllerDelegate2Self()
        if(mNevoOtaController!.isConnected()) {
            let currentSoftwareVersion = mNevoOtaController!.getSoftwareVersion()
            let currentFirmwareVersion = mNevoOtaController!.getFirmwareVersion()
            if(currentSoftwareVersion == 0 || currentFirmwareVersion == 0) {
                return
            }

            var fileArray:NSArray;
            let watchIdValue:Int = UserDefaults.standard.object(forKey: "WATCHNAME_KEY") as! Int
            if watchIdValue > 1 {
                fileArray = AppTheme.GET_FIRMWARE_FILES("Solar_Firmwares")
            }else{
                fileArray = AppTheme.GET_FIRMWARE_FILES("Firmwares")
            }
            
            if(currentFirmwareVersion < Float(buildin_firmware_version) && currentSoftwareVersion != 0) {
                for tmpfile in fileArray {
                    let selectedFile = tmpfile as! URL
                    let fileExtension:String? = selectedFile.pathExtension
                    if fileExtension == "hex"{
                        
                        firmwareURLs.append(selectedFile)
                        allTaskNumber += 1
                        break
                    }
                }
            }

            if(currentSoftwareVersion < Float(buildin_software_version)) {
                for tmpfile in fileArray {
                    let selectedFile = tmpfile as! URL
                    let fileExtension:String? = selectedFile.pathExtension

                    if fileExtension == "bin"{
                        firmwareURLs.append(selectedFile)
                        allTaskNumber += 1
                        break
                    }
                }
            }
            if(currentSoftwareVersion < Float(buildin_software_version)) {
                nevoOtaView.setProgress(0.0, currentTask: currentTaskNumber,allTask: allTaskNumber, progressString: "MCU")
            }

            if(currentFirmwareVersion < Float(buildin_firmware_version)) {
                nevoOtaView.setProgress(0.0, currentTask: currentTaskNumber,allTask: allTaskNumber, progressString: "BLE")
            }

            if(currentSoftwareVersion < Float(buildin_software_version) || currentFirmwareVersion < Float(buildin_firmware_version) ) {
                let updateTitle:String = NSLocalizedString("do_not_exit_this_screen", comment: "")
                let updatemsg:String = NSLocalizedString("please_follow_the_update_has_been_finished", comment: "")
                if((UIDevice.current.systemVersion as NSString).floatValue>8.0){
                    let alert :MEDAlertController = MEDAlertController(title: updateTitle, message: updatemsg, preferredStyle: UIAlertControllerStyle.alert)
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
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        UIApplication.shared.isIdleTimerDisabled = false
        if (!self.isTransferring) {
            mNevoOtaController!.reset(true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - UIAlertViewDelegate
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if(buttonIndex==1) {
            currentIndex = 0
            uploadPressed()
        }

        if(buttonIndex==0) {
            self.dismiss(animated: true, completion: nil)
        }
    }

    //MARK: -
    //init data function
    fileprivate func initValue() {
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

        currentTaskNumber += 1;
        selectedFileURL = firmwareURLs[currentIndex]
        let fileExtension:String? = selectedFileURL!.pathExtension
        if fileExtension == "bin" {
            enumFirmwareType = DfuFirmwareTypes.softdevice
            nevoOtaView.setProgress(0.0, currentTask: currentTaskNumber,allTask: allTaskNumber, progressString: "Mcu")
        }
        if fileExtension == "hex" {
            enumFirmwareType = DfuFirmwareTypes.application
            nevoOtaView.setProgress(0.0, currentTask: currentTaskNumber,allTask: allTaskNumber, progressString: "BLE")
        }
        isTransferring = true
        mNevoOtaController?.performDFUOnFile(selectedFileURL!, firmwareType: enumFirmwareType)
    }

    //below is delegate function

    func onDFUStarted() {
        XCGLogger.default.debug("onDFUStarted");
        //here enable upload button
    }

    //MARK: - NevoOtaControllerDelegate
    /**
    See SyncControllerDelegate
    */
    func receivedRSSIValue(_ number:NSNumber) {
        //AppTheme.DLog("Red RSSI Value:\(number)")
        if(number.int32Value < -85) {
            
        }else {
            
        }
    }

    //user cancel
    func onDFUCancelled() {
        XCGLogger.default.debug("onDFUCancelled");
        //reset OTA view controller 's some data, such as progress bar and upload button text/status
        DispatchQueue.main.async(execute: {
            self.initValue()
            self.mNevoOtaController!.reset(false)
        });
    }

    //percent is[0..100]
    func onTransferPercentage(_ percent:Int) {
        nevoOtaView.setProgress((Float(percent)/100.0), currentTask: currentTaskNumber, allTask: allTaskNumber, progressString: enumFirmwareType == DfuFirmwareTypes.application ? "BLE":"Mcu")
    }

    //successfully
    func onSuccessfulFileTranferred() {
        currentIndex = currentIndex + 1
        if currentIndex == firmwareURLs.count {
            initValue()
            self.nevoOtaView.upgradeSuccessful()
            self.mNevoOtaController!.reset(false)
            nevoOtaView.updatingView.isHidden = true
            nevoOtaView.backView.isHidden = false

        }else{
            mNevoOtaController!.setStatus(DFUControllerState.send_RESET)

            initValue()

            if(currentIndex == 1) {
                //Ble升级完成请打开手表蓝牙,确保连接上并弹出配对信息,点击配对按钮后在点击继续Mcu按钮,不然会出现超时现象
                let alertTip :UIAlertView = UIAlertView(title: NSLocalizedString("Firmware Upgrade", comment: ""), message: NSLocalizedString("update_ble_success_message", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("Ok", comment: ""))
                alertTip.show()

                nevoOtaView.nevoWacthImage.image = UIImage(named: "4_clock_dial")
                self.nevoOtaView.updatingView.isHidden = true
                nevoOtaView.OTAprogressViewHiddenOrNotHidden()

                let titleLabel:UILabel = UILabel(frame: CGRect(x: 0,  y: nevoOtaView.nevoWacthImage.frame.origin.y + nevoOtaView.nevoWacthImage.frame.size.height+10, width: UIScreen.main.bounds.size.width, height: 35))
                //titleLabel.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2.0, UIScreen.mainScreen().bounds.size.height-100)
                titleLabel.font = UIFont.systemFont(ofSize: 19)
                titleLabel.text = NSLocalizedString("press_the_third_button", comment: "")
                titleLabel.textAlignment = NSTextAlignment.center
                titleLabel.tag = 1360
                self.view.addSubview(titleLabel)

                let titleLabel2:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50))
                titleLabel2.center = CGPoint(x: UIScreen.main.bounds.size.width/2.0, y: (titleLabel.frame.origin.y+titleLabel.frame.size.height)+25)
                titleLabel2.font = UIFont.systemFont(ofSize: 16)
                titleLabel2.text = NSLocalizedString("in_order_reactivate_bluetooth", comment: "")
                titleLabel2.numberOfLines = 0
                titleLabel2.textAlignment = NSTextAlignment.center
                titleLabel2.tag = 1361
                self.view.addSubview(titleLabel2)

                continueButton.setTitle(NSLocalizedString("Continue", comment: ""), for: UIControlState())
                continueButton.setTitleColor(AppTheme.NEVO_SOLAR_YELLOW(), for: UIControlState())
                continueButton.frame = CGRect(x: 0, y: 0, width: 135, height: 35)
                continueButton.center = CGPoint(x: UIScreen.main.bounds.size.width/2.0, y: (titleLabel2.frame.origin.y+titleLabel2.frame.size.height)+17)
                continueButton.addTarget(self, action: #selector(NevoOtaViewController.controllManager(_:)), for: UIControlEvents.touchUpInside)
                continueButton.isHidden = true
                continueButton.layer.masksToBounds = true
                continueButton.layer.cornerRadius = 8.0
                continueButton.layer.borderWidth = 1.0
                continueButton.layer.borderColor = AppTheme.NEVO_SOLAR_YELLOW().cgColor
                self.view.addSubview(continueButton)
            }
            let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(3.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                self.mNevoOtaController!.reset(false)
                //self.uploadPressed()
            })
        }

    }
    //Error happen
    func onError(_ errString : NSString){

        DispatchQueue.main.async(execute: {

            self.initValue()

            let alert :UIAlertView = UIAlertView(title: NSLocalizedString("Firmware Upgrade", comment: ""), message: errString as String, delegate: nil, cancelButtonTitle: NSLocalizedString("Ok", comment: ""))
            alert.show()
            self.mNevoOtaController!.reset(false)
            self.currentTaskNumber -= 1;
        });

    }

    func connectionStateChanged(_ isConnected : Bool) {

        //Maybe we just got disconnected, let's check
        checkConnection()

    }

    /**
     see NevoOtaControllerDelegate
     */
    func firmwareVersionReceived(_ whichfirmware:DfuFirmwareTypes, version:Float)
    {
        XCGLogger.default.debug("version :  \(version)")
        continueButton.isHidden = false
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
    func controllManager(_ sender:AnyObject) {
        if(continueButton.isEqual(sender)){
            let SAVED_ADDRESS_KEY = "SAVED_ADDRESS"
            UserDefaults.standard.removeObject(forKey: SAVED_ADDRESS_KEY)
            self.mNevoOtaController!.reset(false)
            uploadPressed()

            for index:Int in 0..<2 {
                let view  = self.view.viewWithTag(1360+index)
                if(view != nil) {
                    view?.isHidden = true
                }
            }
            continueButton.alpha = 0
            self.nevoOtaView.updatingView.isHidden = false
            nevoOtaView.nevoWacthImage.image = UIImage(named: "upgrade_clock.png")
            nevoOtaView.OTAprogressViewHiddenOrNotHidden()
        }

        if(nevoOtaView.backButton.isEqual(sender)) {
            self.dismiss(animated: true, completion: nil)
        }
    }

    /**
     PtlSelectFile

     :param: path <#path description#>
     */
    func onFileSelected(_ selectedFile:URL) {
        XCGLogger.default.debug("onFileSelected")
        if (selectedFile.path != nil) {
            let fileExtension:String? = selectedFile.pathExtension
            //set the file information

            selectedFileURL = selectedFile
            if fileExtension == "bin" {
                enumFirmwareType = DfuFirmwareTypes.softdevice
            }

            if fileExtension == "hex" {
                enumFirmwareType = DfuFirmwareTypes.application
            }
        }
    }
    
}

protocol PtlSelectFile {
    func onFileSelected(_ selectedFile:URL)
}
