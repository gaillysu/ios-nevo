//
//  NevoOtaViewController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/21.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit
import XCGLogger
import iOSDFULibrary
import CoreBluetooth
import MRProgress
import SwiftEventBus
import SwiftyTimer
import PopupDialog

protocol ButtonManagerCallBack: class {
    func controllManager(_ sender:AnyObject)
}

class NevoOtaViewController: UIViewController  {

    @IBOutlet var nevoOtaView: NevoOtaView!
    var startTimer:Timer?
    
    fileprivate var dfuPeripheral    : CBPeripheral?
    fileprivate var dfuController    : DFUServiceController?
    fileprivate var centralManager   : CBCentralManager?
    fileprivate var selectedFirmware : DFUFirmware?
    
    fileprivate var legacyDfuServiceUUID        : CBUUID = NevoOTAPacketProfile().CONTROL_SERVICE.last!
    fileprivate var discoveredPeripherals       : [CBPeripheral] = []
    fileprivate var securePeripheralMarkers     : [Bool]?
    
    fileprivate var mcuSelectedFileURL  : URL?
    fileprivate var bleSelectedFileURL  : URL?
    fileprivate var enumFirmwareType:DfuFirmwareTypes = DfuFirmwareTypes.application

    //save the build-in firmware version, it should be the latest FW version
    fileprivate var buildinSoftwareVersion:Int  = 0
    fileprivate var buildinFirmwareVersion:Int  = 0
    fileprivate var firmwareURLs:[URL] = []
    fileprivate var currentIndex = 0
    fileprivate var mNevoOtaController : NevoMCUOtaController?
    fileprivate var allTaskNumber:Int = 0;//计算所有OTA任务数量
    fileprivate var currentTaskNumber:Int = 0;//当前在第几个任务
    
    fileprivate lazy var dialogProperties: PopupDialog = {
        let title = NSLocalizedString("clean_pairing_infomation", comment: "")
        let message = NSLocalizedString("go_bluetooth_system_message", comment: "")
        let image = UIImage(named: "forgetDevice")
        
        let popup = PopupDialog(title: title, message: message, image: image, gestureDismissal: false) {
            
        }
        
        let buttonOne = DefaultButton(title: NSLocalizedString("go_settings", comment: "")) {
            Tools.openBluetoothSystem()
        }
        popup.addButtons([buttonOne])
        return popup
    }()

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

        initEventBus()
        
        mNevoOtaController = NevoMCUOtaController(self)

        nevoOtaView.setProgress(0, currentTask: currentTaskNumber,allTask: allTaskNumber, progressString: "BLE")
    }

    override func viewDidLayoutSubviews() {
        nevoOtaView.buildView()
    }

    override func viewDidAppear(_ animated: Bool) {

        if ConnectionManager.manager.isConnected {
            let currentSoftwareVersion = UserDefaults.standard.getSoftwareVersion()
            let currentFirmwareVersion = UserDefaults.standard.getFirmwareVersion()

            var fileArray:NSArray;
            
            let watchIdValue:Int = ConnectionManager.manager.getWatchID()
            if watchIdValue > 1 {
                fileArray = Tools.GET_FIRMWARE_FILES("Solar_Firmwares")
            }else{
                fileArray = Tools.GET_FIRMWARE_FILES("Firmwares")
            }

            for tmpfile in fileArray {
                let selectedFile = tmpfile as! URL
                let fileExtension:String? = selectedFile.pathExtension
                if currentFirmwareVersion < buildin_firmware_version {
                    if fileExtension == "hex"{
                        firmwareURLs.append(selectedFile)
                        allTaskNumber += 1
                        bleSelectedFileURL = selectedFile
                    }
                }
                
                if currentSoftwareVersion < buildin_software_version {
                    if fileExtension == "bin"{
                        firmwareURLs.append(selectedFile)
                        allTaskNumber += 1
                        mcuSelectedFileURL = selectedFile
                    }
                }
                
            }

            if currentSoftwareVersion == 0 {
                firmwareURLs.removeAll()
                allTaskNumber = 0
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
            
            currentTaskNumber = allTaskNumber == 1 ? 1:2
            
            if(currentSoftwareVersion < buildin_software_version) {
                nevoOtaView.setProgress(0.0, currentTask: currentTaskNumber,allTask: allTaskNumber, progressString: "MCU")
            }

            if(currentFirmwareVersion < buildin_firmware_version && currentSoftwareVersion != 0) {
                nevoOtaView.setProgress(0.0, currentTask: currentTaskNumber,allTask: allTaskNumber, progressString: "BLE")
            }

            if(currentSoftwareVersion < buildin_software_version || currentFirmwareVersion < buildin_firmware_version ) {
                showAlertView(currentSoftwareVersion,currentFirmwareVersion)
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        UIApplication.shared.isIdleTimerDisabled = false
        ConnectionManager.manager.setUpBTManager()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        SwiftEventBus.unregister(self, name: EVENT_BUS_RAWPACKET_DATA_KEY)
    }

    fileprivate func initEventBus() {
        
        SwiftEventBus.onMainThread(self, name: EVENT_BUS_RAWPACKET_DATA_KEY) { (notification) in
            let packet = notification.object as! NevoPacket
            //Do nothing
            if packet.getHeader() == SetOTAModeRequest.HEADER(){
                XCGLogger.default.debug("from OTAModeRequest response:switchNordicBLEOTAMode")
                self.switchNordicBLEOTAMode()
            }
        }
        
    }
}

//MARK: - Nevo Ota MCU
extension NevoOtaViewController: NevoOtaControllerDelegate {
    func addContinueMCUView() {
        if self.view.viewWithTag(1360) == nil {
            let continueView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: nevoOtaView.backView.frame.width, height: nevoOtaView.backView.frame.height))
            continueView.center = CGPoint(x: UIScreen.main.bounds.size.width/2.0, y: (nevoOtaView.backView.frame.origin.y+nevoOtaView.backView.frame.size.height/2.0))
            continueView.tag = 1360
            self.view.addSubview(continueView)
            
            let titleLabel:UILabel = UILabel(frame: CGRect(x: 0,  y: 0, width: continueView.frame.size.width, height: 35))
            titleLabel.font = UIFont.systemFont(ofSize: 19)
            titleLabel.text = NSLocalizedString("press_the_third_button", comment: "")
            titleLabel.textAlignment = NSTextAlignment.center
            continueView.addSubview(titleLabel)
            
            let titleLabel2:UILabel = UILabel(frame: CGRect(x: 0, y: 35, width: continueView.frame.size.width, height: 50))
            titleLabel2.font = UIFont.systemFont(ofSize: 16)
            titleLabel2.text = NSLocalizedString("in_order_reactivate_bluetooth", comment: "")
            titleLabel2.numberOfLines = 0
            titleLabel2.textAlignment = NSTextAlignment.center
            continueView.addSubview(titleLabel2)
            
            let continueButton:UIButton = UIButton(type: UIButtonType.custom)
            continueButton.setTitle(NSLocalizedString("Continue", comment: ""), for: UIControlState())
            continueButton.setTitleColor(UIColor.baseColor, for: UIControlState())
            continueButton.frame = CGRect(x: 0, y: 0, width: 135, height: 35)
            continueButton.center = CGPoint(x: UIScreen.main.bounds.size.width/2.0, y: (titleLabel2.frame.origin.y+titleLabel2.frame.size.height)+20)
            continueButton.addTarget(self, action: #selector(continueAction(_:)), for: UIControlEvents.touchUpInside)
            continueButton.layer.masksToBounds = true
            continueButton.layer.cornerRadius = 8.0
            continueButton.layer.borderWidth = 1.0
            continueButton.layer.borderColor = UIColor.baseColor.cgColor
            continueView.addSubview(continueButton)
        }
    }
    
    func removeContinueMCUView() {
        if let view = self.view.viewWithTag(1360) {
            view.removeAllSubviews()
            view.removeFromSuperview()
        }
    }
    
    func continueAction(_ button:UIButton) {
        startMCUProcess()
        
        removeContinueMCUView()
    }
    
    func startMCUProcess() {
        if(!mNevoOtaController!.isConnected()) {
            self.mNevoOtaController!.reset(false)
            return
        }
        if let fileExtension:String = mcuSelectedFileURL?.pathExtension {
            if fileExtension == "bin" {
                enumFirmwareType = DfuFirmwareTypes.softdevice
                
                nevoOtaView.setProgress(0.0, currentTask: currentTaskNumber,allTask: allTaskNumber, progressString: "Mcu")
                mNevoOtaController?.performDFUOnFile(mcuSelectedFileURL!, firmwareType: DfuFirmwareTypes.softdevice)
            }
        }
        
        
        nevoOtaView.startProgress()
    }
    
    //MARK: - NevoOtaControllerDelegate
    func connectionStateChanged(_ isConnected : Bool, fromAddress : UUID?,isFirstPair:Bool?) {
        
        if let pair = isFirstPair,pair {
            dismisDialog()
            
            addContinueMCUView()
        }
    }
    
    func onDFUStarted() {
    
    }
    
    func onDFUCancelled() {
    
    }
    
    func onError(_ errorMessage: String) {
        showMessage(errorMessage)
    }
    
    func firmwareVersionReceived(_ whichfirmware:DfuFirmwareTypes, version:Int) {
    
    }
    
    func receivedRSSIValue(_ number:NSNumber){
    
    }
    
    //successfully
    func onSuccessfulFileTranferred() {
        currentIndex = currentIndex + 1
        if currentIndex == firmwareURLs.count {
            self.nevoOtaView.upgradeSuccessful()
            self.mNevoOtaController!.reset(false)
            nevoOtaView.updatingView.isHidden = true
            nevoOtaView.backView.isHidden = false
            
        }else{
            mNevoOtaController!.setStatus(DFUControllerState.send_RESET)
            
            if(currentIndex == 1) {
                self.nevoOtaView.updatingView.isHidden = true
                nevoOtaView.setProgress(0, currentTask: 0, allTask: 0, progressString: nil)
            }
            
            self.mNevoOtaController!.reset(false)
        }
    }
    
    //percent is[0..100]
    func onTransferPercentage(_ percent:Int) {
        currentTaskNumber = allTaskNumber == 1 ? 1:2
        nevoOtaView.setProgress((Float(percent)/100.0), currentTask: currentTaskNumber, allTask: allTaskNumber, progressString: "Updating Mcu: \(currentTaskNumber)/\(allTaskNumber)")
    }
}


//MARK: - OTA BLE
//MARK: - Class Implementation
extension NevoOtaViewController {
    func showMessage(_ message:String) {
        let updateTitle:String = "Message"
        let updatemsg:String = message
        let alert :MEDAlertController = MEDAlertController(title: updateTitle, message: updatemsg, preferredStyle: UIAlertControllerStyle.alert)
        alert.view.tintColor = UIColor.baseColor
        let alertAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel) { (action:UIAlertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(alertAction)
        
        let alertAction2:UIAlertAction = UIAlertAction(title: NSLocalizedString("Enter", comment: ""), style: UIAlertActionStyle.default) { (action:UIAlertAction) -> Void in
            
        }
        alert.addAction(alertAction2)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertView(_ softwareVersion:Int,_ firmwareVersion:Int) {
        let updateTitle:String = NSLocalizedString("do_not_exit_this_screen", comment: "")
        let updatemsg:String = NSLocalizedString("please_follow_the_update_has_been_finished", comment: "")
        let alert :MEDAlertController = MEDAlertController(title: updateTitle, message: updatemsg, preferredStyle: UIAlertControllerStyle.alert)
        alert.view.tintColor = UIColor.baseColor
        let alertAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel) { (action:UIAlertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(alertAction)
        
        let alertAction2:UIAlertAction = UIAlertAction(title: NSLocalizedString("Enter", comment: ""), style: UIAlertActionStyle.default) { (action:UIAlertAction) -> Void in
            if softwareVersion == 0 {
                self.startMCUProcess()
            }else {
                if firmwareVersion<buildin_firmware_version {
                    self.startBLEOTARequest()
                    return
                }
                
                if softwareVersion<buildin_software_version {
                    self.startMCUProcess()
                }
            }
        }
        alert.addAction(alertAction2)
        self.present(alert, animated: true, completion: nil)
    }
    
    func dialogCleanPairInformation() {
        self.present(dialogProperties, animated: true, completion: nil)
    }
    
    func dismisDialog() {
        dialogProperties.dismiss(animated: true, completion: nil)
    }
    
    func startBLEOTARequest() {
        let view = MRProgressOverlayView.showOverlayAdded(to: self.navigationController!.view, title: NSLocalizedString("please_wait", comment: ""), mode: MRProgressOverlayViewMode.indeterminate, animated: true)
        view?.setTintColor(UIColor.baseColor)
        ConnectionManager.manager.sendRequest(SetOTAModeRequest())
        startTimer = Timer.after(10) {
             XCGLogger.default.debug("from timer out:switchNordicBLEOTAMode")
            self.switchNordicBLEOTAMode()
        }
    }
    
    func switchNordicBLEOTAMode() {
        startTimer?.invalidate()
        startTimer = nil
        
        if let connect = ConnectionManager.manager.getMconnectionController() {
            XCGLogger.default.debug("***********again set OTA mode,forget it firstly,and scan DFU service*******")
            ConnectionManager.manager.getMconnectionController()?.disconnect()
            
            ConnectionManager.manager.getMconnectionController()?.forgetSavedAddress()
            
            ConnectionManager.manager.cleanUpBTManager()
        }
        
        if centralManager == nil {
            self.centralManager = CBCentralManager(delegate:self, queue:nil)
            self.centralManager?.delegate = self
            self.startDiscovery()
        }
    }
    
    func cancelBLEOTAMode() {
        if let manager = centralManager {
            manager.stopScan()
            guard dfuPeripheral != nil else {
                print("No DFU peripheral was set")
                self.centralManager = nil
                return
            }

            manager.cancelPeripheralConnection(dfuPeripheral!)
            self.centralManager = nil
        }
        
        ConnectionManager.manager.setUpBTManager()
        ConnectionManager.manager.getMconnectionController()?.forgetSavedAddress()
        ConnectionManager.manager.getMconnectionController()?.setOTAMode(false, Disconnect: true)
        ConnectionManager.manager.getMconnectionController()?.connect()
        
        mNevoOtaController = NevoMCUOtaController(self)
    }
    
    func setCentralManager(centralManager aCentralManager : CBCentralManager){
        self.centralManager = aCentralManager
    }
    
    func setTargetPeripheral(aPeripheral targetPeripheral : CBPeripheral) {
        self.dfuPeripheral = targetPeripheral
    }
    
    func startBLEDFUProcess() {
        
        guard dfuPeripheral != nil else {
            print("No DFU peripheral was set")
            return
        }
        
        selectedFirmware = DFUFirmware(urlToBinOrHexFile: bleSelectedFileURL!, urlToDatFile: nil, type: DFUFirmwareType.application)
        let dfuInitiator = DFUServiceInitiator(centralManager: centralManager!, target: dfuPeripheral!)
        dfuInitiator.delegate = self
        dfuInitiator.progressDelegate = self
        dfuInitiator.logger = self
        dfuController = dfuInitiator.with(firmware: selectedFirmware!).start()
    }
    
    func startOTA(_ mode:Bool,peripheral:CBPeripheral,manager:CBCentralManager) {
        MRProgressOverlayView.dismissAllOverlays(for: self.navigationController!.view, animated: true)
        self.setTargetPeripheral(aPeripheral: peripheral)
        self.startBLEDFUProcess()
    }
}

//MARK: - CBCentralManagerDelegate
extension NevoOtaViewController:CBCentralManagerDelegate, CBPeripheralDelegate {
    func startDiscovery() {
        centralManager?.scanForPeripherals(withServices: [legacyDfuServiceUUID], options: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("CentralManager is now powered on\nStart discovery")
            self.startDiscovery()
        }
        logWith(LogLevel.verbose, message: "UpdatetState: \(String(describing: centralManager?.state.rawValue))")
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if advertisementData[CBAdvertisementDataServiceUUIDsKey] != nil {
            //Secure DFU UUID
            let advertisedUUIDstring = ((advertisementData[CBAdvertisementDataServiceUUIDsKey]!) as AnyObject).firstObject as! CBUUID
            if advertisedUUIDstring.uuidString  == legacyDfuServiceUUID.uuidString {
                print("Found Secure Peripheral: \(peripheral.name!)")
                if self.discoveredPeripherals.contains(peripheral) == false {
                    self.discoveredPeripherals.append(peripheral)
                    self.startOTA(true, peripheral: peripheral, manager: central)
                }
            }else{
                print("Found Legacy Peripheral: \(peripheral.name!)")
                if self.discoveredPeripherals.contains(peripheral) == false {
                    self.discoveredPeripherals.append(peripheral)
                    self.startOTA(false, peripheral: peripheral, manager: central)
                }
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to peripheral: \(String(describing: peripheral.name))")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from peripheral: \(String(describing: peripheral.name)),error:\(String(describing: error))")
        self.startDiscovery()
    }
    
}

//MARK: - DFUServiceDelegate
extension NevoOtaViewController:DFUServiceDelegate {
    /**
     Callback called when state of the DFU Service has changed.
     
     This method is called in the main thread and is safe to update any UI.
     
     - parameter state: the new state fo the service
     */
    func dfuStateDidChange(to state: DFUState) {
        switch state {
        case .aborted:
            nevoOtaView.setProgress(0, currentTask: 1, allTask: allTaskNumber, progressString: nil)
            break
        case .completed:
            nevoOtaView.setProgress(1.0, currentTask: 1,allTask: allTaskNumber, progressString: NSLocalizedString("UpdateSuccess1", comment: ""))
            onSuccessfulFileTranferred()
            self.dialogCleanPairInformation()
            cancelBLEOTAMode()
            break
        case .connecting:
            break
        case .disconnecting:
            break
        case .enablingDfuMode:
            break
        case .starting:
            break
        case .uploading:
            break
        case .validating:
            break
        }
        logWith(LogLevel.info, message: "Changed state to: \(state.description())")
    }
    
    func dfuError(_ error: DFUError, didOccurWithMessage message: String) {
        nevoOtaView.setProgress(0, currentTask: 1, allTask: allTaskNumber, progressString: message)
        logWith(LogLevel.error, message: message)
    }
}

//MARK: - DFUProgressDelegate
extension NevoOtaViewController:DFUProgressDelegate{
    func dfuProgressDidChange(for part: Int, outOf totalParts: Int, to progress: Int,
                              currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
        nevoOtaView.setProgress(Float(progress) / 100.0, currentTask: 1, allTask: allTaskNumber, progressString: "Updating BLE:\(1)/\(allTaskNumber)")
        XCGLogger.default.debug("progress:\(progress)"+"Speed : \(String(format:"%.1f", avgSpeedBytesPerSecond/1024)) Kbps, pt. \(part)/\(totalParts)")
    }
}

//MARK: - LoggerDelegate
extension NevoOtaViewController:LoggerDelegate{
    func logWith(_ level:LogLevel, message:String){
        XCGLogger.default.debug("\(level.rawValue),\(level.name()) : \(message)")
    }
}
