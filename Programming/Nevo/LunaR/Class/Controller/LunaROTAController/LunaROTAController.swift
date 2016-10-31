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
import PopupController

class LunaROTAController: UIViewController  {

    @IBOutlet var nevoOtaView: LunaROtaView!
 
    //MARK: - Class Properties
    fileprivate var dfuPeripheral    : CBPeripheral?
    fileprivate var dfuController    : DFUServiceController?
    fileprivate var centralManager   : CBCentralManager?
    fileprivate var selectedFirmware : DFUFirmware?
    fileprivate var selectedFileURL  : URL?
    fileprivate var secureDFU        : Bool?
    
    var legacyDfuServiceUUID        : CBUUID = CBUUID(string: "00001530-1212-EFDE-1523-785FEABCD123")
    var secureDfuServiceUUID        : CBUUID = CBUUID(string: "FE59")
    var discoveredPeripherals       : [CBPeripheral]?
    var securePeripheralMarkers     : [Bool]?
    
    init() {
        super.init(nibName: "OldOtaViewController", bundle: Bundle.main)
        centralManager = CBCentralManager()
        centralManager?.delegate = self
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews(){
        //init the view
        nevoOtaView.buildView(nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        
        let leftItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(backAction(_:)))
        leftItem.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = leftItem

        let hud:MBProgressHUD = MBProgressHUD.showAdded(to: UIApplication.shared.windows.last, animated: true)
        hud.detailsLabelText = "In the use of first aid mode, please forget all relevant Nevo pairing in the system Bluetooth settings"
        hud.removeFromSuperViewOnHide = true;
        hud.dimBackground = true;
        hud.hide(true, afterDelay: 1.9)
        
        let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
            self.setOTAMode()
        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if dfuController != nil {
            dfuController?.abort()
        }
    }
    
    func backAction(_ sender:AnyObject) {
        self.dismiss(animated: true, completion: nil)
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
            let secureUUIDString = CBUUID(string: "FE59").uuidString
            let advertisedUUIDstring = ((advertisementData[CBAdvertisementDataServiceUUIDsKey]!) as AnyObject).firstObject as! CBUUID
            if advertisedUUIDstring.uuidString  == secureUUIDString {
                print("Found Secure Peripheral: \(peripheral.name!)")
                if self.discoveredPeripherals?.contains(peripheral) == false {
                    self.startOTA(true, peripheral: peripheral, manager: central)
                }
            }else{
                print("Found Legacy Peripheral: \(peripheral.name!)")
                if self.discoveredPeripherals?.contains(peripheral) == false {
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
    }

}

//MARK: - DFUServiceDelegate
extension LunaROTAController:DFUServiceDelegate {
    func didStateChangedTo(_ state:DFUState) {
        switch state {
        case .aborted:
            nevoOtaView.setProgress(0, currentTask: 1, allTask: 1, progressString: nil)
            break
        case .signatureMismatch:
            nevoOtaView.setProgress(0, currentTask: 1, allTask: 1, progressString: nil)
            break
        case .completed:
            nevoOtaView.setProgress(0, currentTask: 1, allTask: 1, progressString: nil)
            break
        case .connecting:
            //self.stopProcessButton.isEnabled = true
            break
        case .disconnecting:
            nevoOtaView.setProgress(0, currentTask: 1, allTask: 1, progressString: nil)
            break
        case .enablingDfuMode:
            break
        case .starting:
            break
        case .uploading:
            break
        case .validating:
            break
        case .operationNotPermitted:
            break
        case .failed:
            break
        }
        
        //self.dfuStatusLabel.text = state.description()
        logWith(LogLevel.info, message: "Changed state to: \(state.description())")
    }
    
    func didErrorOccur(_ error: DFUError, withMessage message: String) {
        //self.dfuStatusLabel.text = "Error: \(message)"
        //self.dfuActivityIndicator.stopAnimating()
        //self.dfuUploadProgressView.setProgress(0, animated: true)
        nevoOtaView.setProgress(0, currentTask: 1, allTask: 1, progressString: message)
        logWith(LogLevel.error, message: message)
    }
}

//MARK: - DFUProgressDelegate
extension LunaROTAController:DFUProgressDelegate{
    func onUploadProgress(_ part: Int, totalParts: Int, progress: Int, currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
        //self.dfuUploadProgressView.setProgress(Float(progress)/100.0, animated: true)
        //self.dfuUploadStatus.text = "Speed : \(String(format:"%.1f", avgSpeedBytesPerSecond/1024)) Kbps, pt. \(part)/\(totalParts)"
        nevoOtaView.setProgress(Float(progress/100), currentTask: 1, allTask: 1, progressString: "Speed : \(String(format:"%.1f", avgSpeedBytesPerSecond/1024)) Kbps, pt. \(part)/\(totalParts)")
    }
}

//MARK: - LoggerDelegate
extension LunaROTAController:LoggerDelegate{
    func logWith(_ level:LogLevel, message:String){
        print("\(level.name()) : \(message)")
    }
}

//MARK: - Class Implementation
extension LunaROTAController {
    
    func showAlertView() {
        let updateTitle:String = NSLocalizedString("do_not_exit_this_screen", comment: "")
        let updatemsg:String = NSLocalizedString("please_follow_the_update_has_been_finished", comment: "")
        
        let alertView :UIAlertController = UIAlertController(title: updateTitle, message: updatemsg, preferredStyle: UIAlertControllerStyle.alert)
        alertView.view.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        let alertAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel) { (action:UIAlertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
        }
        alertView.addAction(alertAction)
        
        let alertAction2:UIAlertAction = UIAlertAction(title: NSLocalizedString("Enter", comment: ""), style: UIAlertActionStyle.default) { (action:UIAlertAction) -> Void in
            self.startDFUProcess()
        }
        alertView.addAction(alertAction2)
        self.present(alertView, animated: true, completion: nil)
    }
    
    func secureDFUMode(_ secureDFU : Bool) {
        self.secureDFU = secureDFU
    }
    
    func getBundledFirmwareURLHelper() -> URL {
        if self.secureDFU! {
            return Bundle.main.url(forResource: "lunar_20161011_v3", withExtension: "zip")!
        }else{
            return Bundle.main.url(forResource: "lunar_20161011_v3", withExtension: "zip")!
        }
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
        _ = dfuInitiator.withFirmwareFile(selectedFirmware!)
        dfuInitiator.delegate = self
        dfuInitiator.progressDelegate = self
        dfuInitiator.logger = self
        dfuController = dfuInitiator.start()
    }
}

//MARK: - SelectPeripheralDelegate
extension LunaROTAController:SelectPeripheralDelegate {
    func onDidSelectPeripheral(_ dFUMode:Bool,_ peripheral:CBPeripheral, _ manager:CBCentralManager){
        //popupView?.dismiss()
        self.secureDFUMode(dFUMode)
        self.setTargetPeripheral(aPeripheral: peripheral)
        self.setCentralManager(centralManager: manager)
        //self.startDFUProcess()
        self.showAlertView()
    }
    
    func setOTAMode(){
        AppDelegate.getAppDelegate().getMconnectionController()?.setOTAMode(true, Disconnect: true)
    }
    
    func startOTA(_ mode:Bool,peripheral:CBPeripheral,manager:CBCentralManager) {
        self.secureDFUMode(mode)
        self.setTargetPeripheral(aPeripheral: peripheral)
        self.setCentralManager(centralManager: manager)
        self.showAlertView()
    }
    
}
