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

class OldOtaViewController: UIViewController  {

    @IBOutlet var nevoOtaView: NevoOtaView!
 
    //MARK: - Class Properties
    fileprivate var dfuPeripheral    : CBPeripheral?
    fileprivate var dfuController    : DFUServiceController?
    fileprivate var centralManager   : CBCentralManager?
    fileprivate var selectedFirmware : DFUFirmware?
    fileprivate var selectedFileURL  : URL?
    fileprivate var secureDFU        : Bool?
    fileprivate var popupView:PopupController?
    
    override func viewDidLayoutSubviews(){
        //init the view
        nevoOtaView.buildView(nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        
        let leftItem:UIBarButtonItem = UIBarButtonItem(image:UIImage(named:"left_button") , style: UIBarButtonItemStyle.plain, target: self, action: #selector(backAction(_:)))
        leftItem.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = leftItem
        
        let rightItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(scanAction(_:)))
        rightItem.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = rightItem

        let hud:MBProgressHUD = MBProgressHUD.showAdded(to: UIApplication.shared.windows.last, animated: true)
        hud.detailsLabelText = "In the use of first aid mode, please forget all relevant Nevo pairing in the system Bluetooth settings"
        hud.removeFromSuperViewOnHide = true;
        hud.dimBackground = true;
        hud.hide(true, afterDelay: 1.9)
        
        let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
            
            //popup.dismiss() // dismiss popup
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
    
    func scanAction(_ sender:AnyObject) {
        let scannerController:ScannerViewController = ScannerViewController()
        scannerController.didDelegate = self
        self.present(scannerController, animated: true, completion: nil)
//
//        popupView = PopupController
//            .create(self)
//            .customize(
//                [
//                    .animation(.fadeIn),
//                    .scrollable(false),
//                    .backgroundStyle(.blackFilter(alpha: 0.7))
//                ]
//            )
//            .didShowHandler { popup in
//                print("showed popup!")
//            }
//            .didCloseHandler { _ in
//                print("closed popup!")
//            }
//            .show(scannerController) // show popup
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: - CBCentralManagerDelegate
extension OldOtaViewController:CBCentralManagerDelegate, CBPeripheralDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        logWith(LogLevel.verbose, message: "UpdatetState: \(centralManager?.state.rawValue)")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to peripheral: \(peripheral.name)")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from peripheral: \(peripheral.name)")
    }

}

//MARK: - DFUServiceDelegate
extension OldOtaViewController:DFUServiceDelegate {
    func didStateChangedTo(_ state:DFUState) {
        switch state {
        case .aborted:
            //self.dfuActivityIndicator.stopAnimating()
            //self.dfuUploadProgressView.setProgress(0, animated: true)
            //self.stopProcessButton.isEnabled = false
            nevoOtaView.setProgress(0, currentTask: 1, allTask: 1, progressString: nil)
            break
        case .signatureMismatch:
            //self.dfuActivityIndicator.stopAnimating()
            //self.dfuUploadProgressView.setProgress(0, animated: true)
            //self.stopProcessButton.isEnabled = false
            nevoOtaView.setProgress(0, currentTask: 1, allTask: 1, progressString: nil)
            break
        case .completed:
            //self.dfuActivityIndicator.stopAnimating()
            //self.dfuUploadProgressView.setProgress(0, animated: true)
            //self.stopProcessButton.isEnabled = false
            nevoOtaView.setProgress(0, currentTask: 1, allTask: 1, progressString: nil)
            break
        case .connecting:
            //self.stopProcessButton.isEnabled = true
            break
        case .disconnecting:
            //self.dfuUploadProgressView.setProgress(0, animated: true)
            //self.dfuActivityIndicator.stopAnimating()
            //self.stopProcessButton.isEnabled = false
            nevoOtaView.setProgress(0, currentTask: 1, allTask: 1, progressString: nil)
            break
        case .enablingDfuMode:
            //self.stopProcessButton.isEnabled = true
            break
        case .starting:
            //self.stopProcessButton.isEnabled = true
            break
        case .uploading:
            //self.stopProcessButton.isEnabled = true
            break
        case .validating:
            //self.stopProcessButton.isEnabled = true
            break
        case .operationNotPermitted:
            //self.stopProcessButton.isEnabled = true
            break
        case .failed:
            //self.stopProcessButton.isEnabled = true
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
extension OldOtaViewController:DFUProgressDelegate{
    func onUploadProgress(_ part: Int, totalParts: Int, progress: Int, currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
        //self.dfuUploadProgressView.setProgress(Float(progress)/100.0, animated: true)
        //self.dfuUploadStatus.text = "Speed : \(String(format:"%.1f", avgSpeedBytesPerSecond/1024)) Kbps, pt. \(part)/\(totalParts)"
        nevoOtaView.setProgress(Float(progress/100), currentTask: 1, allTask: 1, progressString: "Speed : \(String(format:"%.1f", avgSpeedBytesPerSecond/1024)) Kbps, pt. \(part)/\(totalParts)")
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
extension OldOtaViewController:SelectPeripheralDelegate {
    func onDidSelectPeripheral(_ dFUMode:Bool,_ peripheral:CBPeripheral, _ manager:CBCentralManager){
        popupView?.dismiss()
        self.secureDFUMode(dFUMode)
        self.setTargetPeripheral(aPeripheral: peripheral)
        self.setCentralManager(centralManager: manager)
        //self.startDFUProcess()
        self.showAlertView()
    }
}
