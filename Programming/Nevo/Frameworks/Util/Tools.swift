//
//  Tools.swift
//  Nevo
//
//  Created by Cloud on 2017/5/22.
//  Copyright © 2017年 Nevo. All rights reserved.
//

import Foundation
import AudioToolbox
import XCGLogger

let buildin_firmware_version = Tools.GET_FIRMWARE_VERSION();
let buildin_software_version = Tools.GET_SOFTWARE_VERSION();

enum ActionType {
    case get
    case set
}


class Tools: NSObject {
    /**
     Determine whether the iPhone5s
     :returns: If it returns true or false
     */
    class func GET_IS_iPhone5S() -> Bool {
        let isiPhone5S:Bool = (UIScreen.instancesRespond(to: #selector(getter: RunLoop.currentMode)) ? CGSize(width: 640, height: 1136).equalTo(UIScreen.main.currentMode!.size) : false)
        return isiPhone5S
    }
    
    /**
     Determine whether the iPhone4s
     :returns: If it returns true or false
     */
    class func GET_IS_iPhone4S() -> Bool {
        let isiPhone4S:Bool = (UIScreen.instancesRespond(to: #selector(getter: RunLoop.currentMode)) ? CGSize(width: 640, height: 960).equalTo(UIScreen.main.currentMode!.size) : false)
        return isiPhone4S
    }
    
    class func KeyedArchiverName(_ name:String,andObject object:Any) -> Bool{
        let pathArray = NSSearchPathForDirectoriesInDomains(.libraryDirectory,.userDomainMask,true)
        let rootPath = pathArray[0].appending("/Caches/med_cache/")
        let filePath = rootPath.appending("\(name).data")
        if !FileManager.default.fileExists(atPath: rootPath) {
            do {
                try FileManager.default.createDirectory(atPath: rootPath, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                print("Archiver error:\(error)")
            }
        }
        return NSKeyedArchiver.archiveRootObject(object, toFile: filePath)
    }
    
    /**
     * 解档的数据是原始对象, 要获得原始数据需要自行转换
     */
    class func LoadKeyedArchiverName(_ name:String) -> Any?{
        
        let pathArray = NSSearchPathForDirectoriesInDomains(.libraryDirectory,.userDomainMask,true)
        let path = pathArray[0]
        let filename = path.appending("/Caches/med_cache/\(name).data")
        if FileManager.default.fileExists(atPath: filename) {
            let objectArr = NSKeyedUnarchiver.unarchiveObject(withFile: filename)
            return objectArr
        }
        
        return nil
    }
    
    /**
     Play the prompt
     */
    class func playSound(){
        let shake_sound_male_id:SystemSoundID  = UInt32(1005);//系统声音的id 取值范围为：1000-2000
        AudioServicesPlaySystemSound(shake_sound_male_id)
    }
    
    /**
     Get the FW build-in version by parse the file name
     BLE file: imaze_20150512_v29.hex ,keyword:_v, .hex
     return: 29
     */
    fileprivate class func GET_FIRMWARE_VERSION() ->Int
    {
        var buildinFirmwareVersion:Int  = 0
        let fileArray:NSArray = GET_FIRMWARE_FILES("Firmwares")
        
        for tmpfile in fileArray {
            let selectedFile:URL = tmpfile as! URL
            let fileName:NSString? = (selectedFile.path as NSString).lastPathComponent as NSString?
            let fileExtension:String? = selectedFile.pathExtension
            
            if fileExtension == "hex" {
                let ran:NSRange = fileName!.range(of: "_v")
                let ran2:NSRange = fileName!.range(of: ".hex")
                let string:String = fileName!.substring(with: NSRange(location: ran.location + ran.length,length: ran2.location-ran.location-ran.length))
                buildinFirmwareVersion = Int(string)!
                break
            }
            
        }
        
        return buildinFirmwareVersion
    }
    /**
     Get the FW build-in version by parse the file name
     MCU file: iMaze_v12.bin ,keyword:_v, .bin
     return: 12
     */
    fileprivate class func GET_SOFTWARE_VERSION() ->Int {
        var buildinSoftwareVersion:Int  = 0
        let fileArray = GET_FIRMWARE_FILES("Firmwares")
        for tmpfile in fileArray {
            let selectedFile = tmpfile as! URL
            let fileName:NSString? = (selectedFile.path as NSString).lastPathComponent as NSString?
            let fileExtension:String? = selectedFile.pathExtension
            
            if fileExtension == "bin" {
                let ran:NSRange = fileName!.range(of: "_v")
                let ran2:NSRange = fileName!.range(of: ".bin")
                let string:String = fileName!.substring(with: NSRange(location: ran.location + ran.length,length: ran2.location-ran.location-ran.length))
                buildinSoftwareVersion = Int(string)!
                break
            }
        }
        
        return buildinSoftwareVersion
    }
    /**
     Get or get the resource path of the array
     
     :param: folderName Resource folder name
     
     :returns: Return path array
     */
    class func GET_FIRMWARE_FILES(_ folderName:String) -> NSArray {
        
        let AllFilesNames:NSMutableArray = NSMutableArray()
        let appPath:NSString  = Bundle.main.resourcePath! as NSString
        let firmwaresDirectoryPath:NSString = appPath.appendingPathComponent(folderName) as NSString
        
        var  fileNames:[String] = []
        do {
            fileNames = try FileManager.default.contentsOfDirectory(atPath: firmwaresDirectoryPath as String)
            XCGLogger.default.debug("number of files in directory \(fileNames.count)");
            for fileName in fileNames {
                XCGLogger.default.debug("Found file in directory: \(fileName)");
                let filePath:String = firmwaresDirectoryPath.appendingPathComponent(fileName)
                let fileURL:URL = URL(fileURLWithPath: filePath)
                AllFilesNames.add(fileURL)
            }
            return AllFilesNames.copy() as! NSArray
        }catch{
            XCGLogger.default.debug("error in opening directory path: \(firmwaresDirectoryPath)");
            return NSArray()
        }
    }
    
    
    
    
    
    static func openBluetoothSystem() {
        let url:URL = URL(string: "App-Prefs:root=Bluetooth")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: Dictionary(), completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}
