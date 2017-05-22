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

class OldOtaViewController: UIViewController  {

    @IBOutlet var nevoOtaView: NevoOtaView!
 
    //MARK: - Class Properties
    fileprivate var dfuPeripheral    : CBPeripheral?
    fileprivate var dfuController    : DFUServiceController?
    fileprivate var centralManager   : CBCentralManager?
    fileprivate var selectedFirmware : DFUFirmware?
    fileprivate var selectedFileURL  : URL?
    fileprivate var secureDFU        : Bool?
    
    override func viewDidLayoutSubviews(){
        //init the view
        nevoOtaView.buildView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        
        ConnectionManager.manager.cleanUpBTManager()
        
        let leftItem:UIBarButtonItem = UIBarButtonItem(image:UIImage(named:"cancel_lunar") , style: UIBarButtonItemStyle.plain, target: self, action: #selector(backAction(_:)))
        leftItem.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = leftItem
        
        let rightItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(scanAction(_:)))
        rightItem.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = rightItem
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if dfuController != nil {
            dfuController?.abort()
        }
        
        ConnectionManager.manager.setUpBTManager()
    }
    
    func backAction(_ sender:AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func scanAction(_ sender:AnyObject) {
        let scannerController:ScannerViewController = ScannerViewController()
        scannerController.didDelegate = self
        self.navigationController?.pushViewController(scannerController, animated: true)
        //self.present(scannerController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: - CBCentralManagerDelegate
extension OldOtaViewController:CBCentralManagerDelegate, CBPeripheralDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        logWith(LogLevel.verbose, message: "UpdatetState: \(String(describing: centralManager?.state.rawValue))")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to peripheral: \(String(describing: peripheral.name))")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from peripheral: \(String(describing: peripheral.name))")
    }

}

//MARK: - DFUServiceDelegate
extension OldOtaViewController:DFUServiceDelegate {
    func dfuStateDidChange(to state: DFUState) {
        switch state {
        case .aborted:
            nevoOtaView.setProgress(0, currentTask: 1, allTask: 1, progressString: nil)
            break
        case .completed:
            nevoOtaView.setProgress(1, currentTask: 1, allTask: 1, progressString: NSLocalizedString("UpdateSuccess1", comment: ""))
            self.nevoOtaView.upgradeSuccessful()
            break
        case .connecting:
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
        }
        logWith(LogLevel.info, message: "Changed state to: \(state.description())")
    }
    
    func dfuError(_ error: DFUError, didOccurWithMessage message: String) {
        nevoOtaView.setProgress(0, currentTask: 1, allTask: 1, progressString: message)
        logWith(LogLevel.error, message: message)
    }
}

//MARK: - DFUProgressDelegate
extension OldOtaViewController:DFUProgressDelegate{
    func dfuProgressDidChange(for part: Int, outOf totalParts: Int, to progress: Int,
                              currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
        nevoOtaView.setProgress(Float(progress) / 100.0, currentTask: 1, allTask: 1, progressString: "Updating :\(part)/\(totalParts)")
    }
}

//MARK: - LoggerDelegate
extension OldOtaViewController:LoggerDelegate{
    func logWith(_ level:LogLevel, message:String){
        print("\(level.name()) : \(message)")
    }
}

//MARK: - Class Implementation
extension OldOtaViewController {
    
    func showAlertView() {
        let updateTitle:String = NSLocalizedString("do_not_exit_this_screen", comment: "")
        let updatemsg:String = NSLocalizedString("please_follow_the_update_has_been_finished", comment: "")
        
        let alertView :MEDAlertController = MEDAlertController(title: updateTitle, message: updatemsg, preferredStyle: UIAlertControllerStyle.alert)
        alertView.view.tintColor = UIColor.baseColor
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
        let fileArray:NSArray = AppTheme.GET_FIRMWARE_FILES("Firmwares")
        for tmpfile in fileArray {
            let selectedFile:URL = tmpfile as! URL
            let fileExtension:String? = selectedFile.pathExtension
            if fileExtension == "hex"{
                return selectedFile
            }
        }
        return URL(string: "")!
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
        selectedFirmware = DFUFirmware(urlToBinOrHexFile: selectedFileURL!, urlToDatFile: nil, type: DFUFirmwareType.application)
        
        let dfuInitiator = DFUServiceInitiator(centralManager: centralManager!, target: dfuPeripheral!)
        dfuInitiator.delegate = self
        dfuInitiator.progressDelegate = self
        dfuInitiator.logger = self
        dfuController = dfuInitiator.with(firmware: selectedFirmware!).start()
    }
}

//MARK: - SelectPeripheralDelegate
extension OldOtaViewController:SelectPeripheralDelegate {
    func onDidSelectPeripheral(_ dFUMode:Bool,_ peripheral:CBPeripheral, _ manager:CBCentralManager){
        self.secureDFUMode(dFUMode)
        self.setTargetPeripheral(aPeripheral: peripheral)
        self.setCentralManager(centralManager: manager)
        //self.startDFUProcess()
        self.showAlertView()
    }
}
