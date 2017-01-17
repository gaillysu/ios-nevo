//
//  ViewController.swift
//  iOSDFULibrary
//
//  Created by Mostafa Berg on 04/18/2016.
//  Copyright (c) 2016 Mostafa Berg. All rights reserved.
//

import UIKit
import CoreBluetooth

@objc protocol SelectPeripheralDelegate{
    @objc optional func onDidSelectPeripheral(_ dFUMode:Bool,_ peripheral:CBPeripheral, _ manager:CBCentralManager)
    
}

class ScannerViewController: UIViewController, CBCentralManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    //MARK: - Class properties
    var centralManager              : CBCentralManager
    var legacyDfuServiceUUID        : CBUUID
    var secureDfuServiceUUID        : CBUUID
    var selectedPeripheral          : CBPeripheral?
    var selectedPeripheralIsSecure  : Bool?
    var discoveredPeripherals       : [CBPeripheral]?
    var securePeripheralMarkers     : [Bool]?
    var didDelegate:SelectPeripheralDelegate?

    //MARK: - View Outlets
    @IBOutlet weak var discoveredPeripheralsTableView: UITableView!
    
    func startDiscovery() {
        centralManager.scanForPeripherals(withServices: [legacyDfuServiceUUID, secureDfuServiceUUID], options: nil)
    }

    init() {
        centralManager = CBCentralManager()
        legacyDfuServiceUUID    = CBUUID(string: "00001530-1212-EFDE-1523-785FEABCD123")
        secureDfuServiceUUID    = CBUUID(string: "FE59")
        super.init(nibName: "ScannerViewController", bundle: Bundle.main)
        centralManager.delegate = self
        discoveredPeripherals = [CBPeripheral]()
        securePeripheralMarkers = [Bool]()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        discoveredPeripheralsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "peripheralCell")
        //peripheralCell
    }
    
    //MARK: - CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("CentralManager is now powered on\nStart discovery")
            self.startDiscovery()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
            if advertisementData[CBAdvertisementDataServiceUUIDsKey] != nil {
                //Secure DFU UUID
                let secureUUIDString = CBUUID(string: "FE59").uuidString
                let advertisedUUIDstring = ((advertisementData[CBAdvertisementDataServiceUUIDsKey]!) as AnyObject).firstObject as! CBUUID
                if advertisedUUIDstring.uuidString  == secureUUIDString {
                    print("Found Secure Peripheral: \(peripheral.name!)")
                    if self.discoveredPeripherals?.contains(peripheral) == false {
                        self.discoveredPeripherals?.append(peripheral)
                        self.securePeripheralMarkers?.append(true)
                        discoveredPeripheralsTableView.reloadData()
                    }
                }else{
                    print("Found Legacy Peripheral: \(peripheral.name!)")
                    if self.discoveredPeripherals?.contains(peripheral) == false {
                        self.discoveredPeripherals?.append(peripheral)
                        self.securePeripheralMarkers?.append(false)
                        discoveredPeripheralsTableView.reloadData()
                    }
                }
            }
    }
    
    //MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (discoveredPeripherals?.count)!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aCell = tableView.dequeueReusableCell(withIdentifier: "peripheralCell", for: indexPath)
        
        aCell.textLabel?.text = discoveredPeripherals![(indexPath as NSIndexPath).row].name
        if securePeripheralMarkers![(indexPath as NSIndexPath).row] == true {
            aCell.detailTextLabel?.text = "Secure DFU"
        }else{
            aCell.detailTextLabel?.text = "Legacy DFU"
        }
        return aCell
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedPeripheral = discoveredPeripherals![(indexPath as NSIndexPath).row]
        self.selectedPeripheralIsSecure = securePeripheralMarkers![(indexPath as NSIndexPath).row]
        if self.navigationController?.popViewController(animated: true) == nil {
            self.dismiss(animated: true, completion: nil)
        }
        AppDelegate.getAppDelegate().delay(seconds: 1.2) { 
            self.didDelegate?.onDidSelectPeripheral!(self.selectedPeripheralIsSecure!, self.selectedPeripheral!, self.centralManager)
        }
        //didDelegate?.onDidSelectPeripheral(nil)
    }
}

