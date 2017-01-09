//
//  AidOtaViewController.swift
//  Nevo
//
//  Created by leiyuncun on 15/9/15.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit
import XCGLogger
import iOSDFULibrary
import CoreBluetooth
import MRProgress

class LunaROTAController: UIViewController,ButtonManagerCallBack  {

    @IBOutlet var lunarOtaView: LunaROtaView!
 
    //MARK: - Class Properties
    fileprivate var dfuPeripheral    : CBPeripheral?
    fileprivate var dfuController    : DFUServiceController?
    fileprivate var centralManager   : CBCentralManager?
    fileprivate var selectedFirmware : DFUFirmware?
    fileprivate var selectedFileURL  : URL?

    fileprivate var dfuFirmwareType : DfuFirmwareTypes = DfuFirmwareTypes.application
    fileprivate var state:DFUControllerState = DFUControllerState.inittialize
    
    fileprivate var legacyDfuServiceUUID        : CBUUID = CBUUID(string: "00001530-1212-EFDE-1523-785FEABCD123")
    fileprivate var secureDfuServiceUUID        : CBUUID = CBUUID(string: "FE59")
    fileprivate var discoveredPeripherals       : [CBPeripheral]?
    fileprivate var securePeripheralMarkers     : [Bool]?
    
    init() {
        super.init(nibName: "LunaROTAController", bundle: Bundle.main)
        discoveredPeripherals = []
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews(){
        //init the view
        lunarOtaView.buildView(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        
        self.navigationItem.title = "Upgrade Firmwares"
        AppDelegate.getAppDelegate().getMconnectionController()?.setDelegate(self)
        
        self.showAlertView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if dfuController != nil {
            dfuController?.abort()
        }
        cancelOTAMode()
    }

    func controllManager(_ sender:AnyObject){
        if(lunarOtaView.backButton.isEqual(sender)) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: - CBCentralManagerDelegate
extension LunaROTAController:CBCentralManagerDelegate, CBPeripheralDelegate {
    func startDiscovery() {
        centralManager?.scanForPeripherals(withServices: [legacyDfuServiceUUID, secureDfuServiceUUID], options: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("CentralManager is now powered on\nStart discovery")
            self.startDiscovery()
        }
        logWith(LogLevel.verbose, message: "UpdatetState: \(centralManager?.state.rawValue)")
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if advertisementData[CBAdvertisementDataServiceUUIDsKey] != nil {
            //Secure DFU UUID
            let advertisedUUIDstring = ((advertisementData[CBAdvertisementDataServiceUUIDsKey]!) as AnyObject).firstObject as! CBUUID
            if advertisedUUIDstring.uuidString  == legacyDfuServiceUUID.uuidString {
                print("Found Secure Peripheral: \(peripheral.name!)")
                if self.discoveredPeripherals?.contains(peripheral) == false {
                    self.discoveredPeripherals?.append(peripheral)
                    self.startOTA(true, peripheral: peripheral, manager: central)
                }
            }else{
                print("Found Legacy Peripheral: \(peripheral.name!)")
                if self.discoveredPeripherals?.contains(peripheral) == false {
                    self.discoveredPeripherals?.append(peripheral)
                    self.startOTA(false, peripheral: peripheral, manager: central)
                }
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to peripheral: \(peripheral.name)")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from peripheral: \(peripheral.name)")
        self.startDiscovery()
    }

}

//MARK: - DFUServiceDelegate
extension LunaROTAController:DFUServiceDelegate {
    /**
     Callback called when state of the DFU Service has changed.
     
     This method is called in the main thread and is safe to update any UI.
     
     - parameter state: the new state fo the service
     */
    func dfuStateDidChange(to state: DFUState) {
        switch state {
        case .aborted:
            lunarOtaView.setProgress(0, currentTask: 1, allTask: 1, progressString: nil)
            break
        case .completed:
            lunarOtaView.setProgress(1, currentTask: 1, allTask: 1, progressString: NSLocalizedString("UpdateSuccess1", comment: ""))
            self.lunarOtaView.upgradeSuccessful()
            break
        case .connecting:
            break
        case .disconnecting:
            lunarOtaView.setProgress(0, currentTask: 1, allTask: 1, progressString: nil)
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
        
        //self.dfuStatusLabel.text = state.description()
        logWith(LogLevel.info, message: "Changed state to: \(state.description())")
    }
    
    func dfuError(_ error: DFUError, didOccurWithMessage message: String) {
        lunarOtaView.setProgress(0, currentTask: 1, allTask: 1, progressString: message)
        logWith(LogLevel.error, message: message)
    }
}

//MARK: - DFUProgressDelegate
extension LunaROTAController:DFUProgressDelegate{
    func dfuProgressDidChange(for part: Int, outOf totalParts: Int, to progress: Int,
                              currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
        lunarOtaView.setProgress(Float(progress) / 100.0, currentTask: 1, allTask: 1, progressString: "Updating :\(part)/\(totalParts)")
        XCGLogger.default.debug("progress:\(progress)"+"Speed : \(String(format:"%.1f", avgSpeedBytesPerSecond/1024)) Kbps, pt. \(part)/\(totalParts)")
    }
}

//MARK: - LoggerDelegate
extension LunaROTAController:LoggerDelegate{
    func logWith(_ level:LogLevel, message:String){
        XCGLogger.default.debug("\(level),\(level.name()) : \(message)")
    }
}

//MARK: - Class Implementation
extension LunaROTAController {
    
    func showAlertView() {
        let updateTitle:String = NSLocalizedString("do_not_exit_this_screen", comment: "")
        let updatemsg:String = NSLocalizedString("please_follow_the_update_has_been_finished", comment: "")
        
        let alertView :MEDAlertController = MEDAlertController(title: updateTitle, message: updatemsg, preferredStyle: UIAlertControllerStyle.alert)
        alertView.view.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        let alertAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel) { (action:UIAlertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
        }
        alertView.addAction(alertAction)
        
        let alertAction2:UIAlertAction = UIAlertAction(title: NSLocalizedString("Enter", comment: ""), style: UIAlertActionStyle.default) { (action:UIAlertAction) -> Void in
            //self.startDFUProcess()
            self.state = DFUControllerState.idle
            self.setOTAMode()
        }
        alertView.addAction(alertAction2)
        self.present(alertView, animated: true, completion: nil)
    }
    
    
    func getBundledFirmwareURLHelper() -> URL {
        let fileArray = AppTheme.GET_FIRMWARE_FILES("DFUFirmware")
        var lunaRFirmwareUrl:URL?
        for tmpfile in fileArray {
            let selectedFile = tmpfile as! URL
            let fileExtension:String? = selectedFile.pathExtension
            if fileExtension == "zip"{
                lunaRFirmwareUrl = selectedFile
                break
            }
        }
        if lunaRFirmwareUrl == nil {
            lunaRFirmwareUrl = URL(string: "")
        }
        return lunaRFirmwareUrl!
    }
    
    func setCentralManager(centralManager aCentralManager : CBCentralManager){
        self.centralManager = aCentralManager
    }
    
    func setTargetPeripheral(aPeripheral targetPeripheral : CBPeripheral) {
        self.dfuPeripheral = targetPeripheral
    }
    
    func startDFUProcess() {
        
        guard dfuPeripheral != nil else {
            print("No DFU peripheral was set")
            return
        }
        
        selectedFileURL  = self.getBundledFirmwareURLHelper()
        selectedFirmware = DFUFirmware(urlToZipFile: selectedFileURL!)
    
        let dfuInitiator = DFUServiceInitiator(centralManager: centralManager!, target: dfuPeripheral!)
        dfuInitiator.delegate = self
        dfuInitiator.progressDelegate = self
        dfuInitiator.logger = self
        
        // This enables the experimental Buttonless DFU feature from SDK 12.
        // Please, read the field documentation before use.
        //dfuInitiator.enableUnsafeExperimentalButtonlessServiceInSecureDfu = true
        
        dfuController = dfuInitiator.with(firmware: selectedFirmware!).start()
    }
}

//MARK: - SelectPeripheralDelegate
extension LunaROTAController {
    func setOTAMode(){
        let view = MRProgressOverlayView.showOverlayAdded(to: self.navigationController!.view, title: NSLocalizedString("please_wait", comment: ""), mode: MRProgressOverlayViewMode.indeterminate, animated: true)
        view?.setTintColor(UIColor.getBaseColor())
        AppDelegate.getAppDelegate().getMconnectionController()?.setOTAMode(true, Disconnect: true)
    }
    
    func cancelOTAMode() {
        AppDelegate.getAppDelegate().getMconnectionController()?.forgetSavedAddress()
        AppDelegate.getAppDelegate().getMconnectionController()?.setOTAMode(false, Disconnect: false)
        AppDelegate.getAppDelegate().getMconnectionController()?.setDelegate(AppDelegate.getAppDelegate())
        AppDelegate.getAppDelegate().getMconnectionController()?.connect()
    }
    
    func startOTA(_ mode:Bool,peripheral:CBPeripheral,manager:CBCentralManager) {
        MRProgressOverlayView.dismissAllOverlays(for: self.navigationController!.view, animated: true)
        self.setTargetPeripheral(aPeripheral: peripheral)
        self.startDFUProcess()
    }
    
}

extension LunaROTAController:ConnectionControllerDelegate {
    func connectionStateChanged(_ isConnected : Bool, fromAddress : UUID!,isFirstPair:Bool) {
        if(dfuFirmwareType == DfuFirmwareTypes.application ){
            if isConnected{
                if state == DFUControllerState.send_RECONNECT{
                    state = DFUControllerState.send_START_COMMAND
                    let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(0.8 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                        AppDelegate.getAppDelegate().getMconnectionController()?.sendRequest(SetOTAModeRequest())
                    })
                }else if state == DFUControllerState.discovering{
                    state = DFUControllerState.send_FIRMWARE_DATA
                    AppDelegate.getAppDelegate().getMconnectionController()?.disconnect()
                    self.centralManager = AppDelegate.getAppDelegate().getMconnectionController()!.getBLECentralManager()!
                    self.centralManager?.delegate = self
                    self.centralManager!.connect(dfuPeripheral!)
                    self.startDiscovery()
                }
            }else{
                if state == DFUControllerState.idle{
                    self.state = DFUControllerState.send_RECONNECT
                    
                    let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                        AppDelegate.getAppDelegate().getMconnectionController()?.connect()
                    })
                }else if state == DFUControllerState.send_START_COMMAND{
                    self.state = DFUControllerState.discovering
                    //reset it by BLE peer disconnect
                    AppDelegate.getAppDelegate().getMconnectionController()?.setOTAMode(false,Disconnect:false)
                    let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                        XCGLogger.default.debug("***********again set OTA mode,forget it firstly,and scan DFU service*******")
                        //when switch to DFU mode, the identifier has changed another one
                        AppDelegate.getAppDelegate().getMconnectionController()?.forgetSavedAddress()
                        AppDelegate.getAppDelegate().getMconnectionController()?.setOTAMode(true,Disconnect:false)
                        //AppDelegate.getAppDelegate().getMconnectionController()?.connect()
                    })
                }
            }
        }
    }
    
    /**
     Called when a packet is received from the device
     */
    func packetReceived(_ rawPacket: RawPacket){
    
    }
    
    /**
     Call when finish reading Firmware
     @parameter whichfirmware, firmware type
     @parameter version, return the version
     */
    func firmwareVersionReceived(_ whichfirmware:DfuFirmwareTypes, version:Float){
    
    }
    
    /**
     *  Receiving the current device signal strength value
     */
    func receivedRSSIValue(_ number:NSNumber){
    
    }
    
    func bluetoothEnabled(_ enabled:Bool){
    
    }
    
    func scanAndConnect(){
    
    }

}
