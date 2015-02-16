//
//  alarmClockController.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/12.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class AlarmClockController: UIViewController, ConnectionControllerDelegate,alarmButtonActionCallBack {

    @IBOutlet var alarmView: alarmClockView!
    
    var alarmhour:Int = 0
    var alarmmin:Int = 0
    var alarmenable:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 120, 30))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "Alarm"
        titleLabel.font = UIFont.systemFontOfSize(25)
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel

        alarmView.bulidAlarmView(self)
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        ConnectionControllerImpl.sharedInstance.setDelegate(self)

        checkConnection()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func stringFromDate(date:NSDate) -> String {
        var dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let dateString:String = dateFormatter.stringFromDate(date)
        return dateString
    }

    /*
    call back Button Action
    */
    func controllManager(sender:AnyObject){

        if sender.isEqual(alarmView.selectedTimerButton){
            alarmView.initPickerView()
            NSLog("alarmView.selectedTimerButton")
        }

        if sender.isEqual(alarmView.alarmSwitch){
            NSLog("alarmView.alarmSwitch")
            if alarmView.alarmSwitch.on {
                alarmenable = true
            }else{
                alarmenable = false
            }

            ConnectionControllerImpl.sharedInstance.sendRequest(SetAlarmRequest(hour:alarmhour,min: alarmmin,enable: alarmenable))

        }

        if sender.isEqual(alarmView.datePicker) {
            let dateButtonTitle = stringFromDate(alarmView.datePicker.date)
            alarmView.selectedTimerButton.setTitle(dateButtonTitle as String, forState: UIControlState.Normal)
            var lines:[String] = dateButtonTitle.componentsSeparatedByString(":");

            alarmhour = (lines[0] as NSString).integerValue
            alarmmin  = (lines[1] as NSString).integerValue

            NSLog("datePicker.alarmhour:%d,alarmmin:%d",alarmhour,alarmmin)
        }

        if sender.isEqual(alarmView.noConnectScanButton) {
            NSLog("noConnectScanButton")

            ConnectionControllerImpl.sharedInstance.connect()
            reconnect()
        }
        if sender.isEqual(alarmView.enterButton){
            NSLog("alarmView.enterButton")
            
            ConnectionControllerImpl.sharedInstance.sendRequest(SetAlarmRequest(hour:alarmhour,min: alarmmin,enable: alarmenable))
        }
    }
    
    func reconnect() {
            alarmView.buttonAnimation(alarmView.noConnectImage)
            SyncController(controller: self, forceScan:false)
    }
    
    /**

    See ConnectionControllerDelegate

    */

    func packetReceived(RawPacket) {

        //Do nothing

    }



    /**

    See ConnectionControllerDelegate

    */

    func connectionStateChanged(isConnected : Bool) {

        //Maybe we just got disconnected, let's check

        checkConnection()

    }



    /**

    Checks if any device is currently connected

    */

    func checkConnection() {



        if !ConnectionControllerImpl.sharedInstance.isConnected() {
            
            //We are currently not connected
            alarmView.bulibNoConnectView()
            reconnect()
        } else {
            
            alarmView.endConnectRemoveView()
        }


    }

}
