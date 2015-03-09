//
//  EnterNotificationController.swift
//  Nevo
//
//  Created by leiyuncun on 15/3/3.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit
/**
*  callBack choose notification protocol
*/
protocol SelectionTypeDelegate {

    /**
    Implementation method
    :param: results Switch state
    :param: type    type
    */
    func onSelectedType(results:Bool,type:NSString)

}

class EnterNotificationController: UITableViewController,SwitchActionDelegate,PaletteDelegate,SyncControllerDelegate,ButtonManagerCallBack{

    struct SOURCETYPE {
        static let CALL:NSString = "CALL"
        static let SMS:NSString = "SMS"
        static let EMAIL:NSString = "EMAIL"
        static let FACEBOOK:NSString = "FaceBook"
        static let TWITTER:NSString = "Twitter"
        static let WHATSAPP:NSString = "Whatsapp"
    }
    
    class func setLedColor(sourceType: NSString,ledColor:UInt32)
    {
        let userDefaults = NSUserDefaults.standardUserDefaults();
        var value:UInt32 = getMotorOnOff(sourceType) ? (ledColor | SetNortificationRequest.SetNortificationRequestValues.VIB_MOTOR)
            : (ledColor & ~SetNortificationRequest.SetNortificationRequestValues.VIB_MOTOR)
        
        userDefaults.setObject(UInt(value),forKey:sourceType)
        userDefaults.synchronize()
        
    }
    class  func getLedColor(sourceType: NSString) ->UInt32
    {
        if let color = NSUserDefaults.standardUserDefaults().objectForKey(sourceType) as? UInt
        {
            return UInt32(color) & ~SetNortificationRequest.SetNortificationRequestValues.VIB_MOTOR
        }
            // default value
        else{
            if sourceType == SOURCETYPE.CALL  { return SetNortificationRequest.SetNortificationRequestValues.BLUE_LED }
            if sourceType == SOURCETYPE.SMS  { return SetNortificationRequest.SetNortificationRequestValues.GREEN_LED }
            if sourceType == SOURCETYPE.EMAIL  { return SetNortificationRequest.SetNortificationRequestValues.YELLOW_LED }
            if sourceType == SOURCETYPE.FACEBOOK  { return SetNortificationRequest.SetNortificationRequestValues.RED_LED }
            if sourceType == SOURCETYPE.TWITTER  { return SetNortificationRequest.SetNortificationRequestValues.VIOLET_LED }
            if sourceType == SOURCETYPE.WHATSAPP  { return SetNortificationRequest.SetNortificationRequestValues.PURPLE_LED }
            
            return 0xFF0000
        }
    }
    
    class func setMotorOnOff(sourceType: NSString,motorStatus:Bool)
    {
        let userDefaults = NSUserDefaults.standardUserDefaults();
        var ledColor = getLedColor(sourceType)
        
        ledColor = motorStatus ? (ledColor | SetNortificationRequest.SetNortificationRequestValues.VIB_MOTOR)
            : (ledColor & ~SetNortificationRequest.SetNortificationRequestValues.VIB_MOTOR)
        userDefaults.setObject(UInt(ledColor),forKey:sourceType)
        userDefaults.synchronize()
    }
    
    class func getMotorOnOff(sourceType: NSString) ->Bool
    {
        if let color = NSUserDefaults.standardUserDefaults().objectForKey(sourceType) as? UInt
        {
            return ((UInt32(color) & SetNortificationRequest.SetNortificationRequestValues.VIB_MOTOR) == SetNortificationRequest.SetNortificationRequestValues.VIB_MOTOR) ? true : false
        }
        
        return true
    }

    @IBOutlet var enterNotView: EnterNotificationView!
    
    //From the higher level of the incoming type Array
    var notTypeArray:NSArray!

    /*
    Type switch state callBack to the before a object
    */
    var mDelegate:SelectionTypeDelegate?

    private var mSyncController:SyncController?
    
    /*
    led color default is full color led light on
    */
    //var ledcolor: UInt32 = 0xFF0000
    

    override func viewDidLoad() {
        super.viewDidLoad()

        mSyncController = SyncController.sharedInstance
        mSyncController?.startConnect(false, delegate: self)

        enterNotView.bulidEnterNotificationView(self,navigationItem:self.navigationItem)

    }

    override func viewDidAppear(animated: Bool) {
        checkConnection()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - ButtonManagerCallBack
    func controllManager(sender:AnyObject){
        if sender.isEqual(enterNotView.animationView?.getNoConnectScanButton()?) {
            NSLog("noConnectScanButton")
            reconnect()
        }

        if sender.isEqual(enterNotView.backButton) {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }

    // MARK: - SyncControllerDelegate
    /**
    See SyncControllerDelegate
    */
    func packetReceived(packet:RawPacket) {

    }

    /**
    See SyncControllerDelegate
    */
    func connectionStateChanged(isConnected : Bool) {
        //Maybe we just got disconnected, let's check
        checkConnection()
    }

    /**
    Checks if any device is currently connected
    */
    func checkConnection() {
        if mSyncController != nil && !(mSyncController!.isConnected()) {
            //We are currently not connected
            enterNotView.addSubview((enterNotView.animationView?.bulibNoConnectView())!)
            reconnect()
        } else {
            enterNotView.animationView?.endConnectRemoveView()
        }
    }

    func reconnect() {
        enterNotView.animationView?.RotatingAnimationObject((enterNotView.animationView?.getNoConnectImage())!)
        mSyncController?.connect()
    }

       // MARK: - SwitchActionDelegate
    func onSwitch(results:Bool){
        EnterNotificationController.setMotorOnOff(notTypeArray[1] as NSString, motorStatus: results)
        mSyncController?.SetNortification()
        mDelegate?.onSelectedType(results, type: notTypeArray[1] as NSString)
    }

    // MARK: - PaletteDelegate
    func selectedPalette(color:UIColor){
        NSLog("UIColor\(color)")
        if color == UIColor.blueColor()
        {
            EnterNotificationController.setLedColor(notTypeArray[1] as NSString,ledColor:SetNortificationRequest.SetNortificationRequestValues.BLUE_LED)
        }else if color == UIColor.redColor(){
            EnterNotificationController.setLedColor(notTypeArray[1] as NSString,ledColor:SetNortificationRequest.SetNortificationRequestValues.RED_LED)
        }else if color == UIColor.yellowColor(){
            EnterNotificationController.setLedColor(notTypeArray[1] as NSString,ledColor:SetNortificationRequest.SetNortificationRequestValues.YELLOW_LED)
        }else if color == UIColor.greenColor(){
            EnterNotificationController.setLedColor(notTypeArray[1] as NSString,ledColor:SetNortificationRequest.SetNortificationRequestValues.GREEN_LED)
        }else if color == UIColor.orangeColor(){
            EnterNotificationController.setLedColor(notTypeArray[1] as NSString,ledColor:SetNortificationRequest.SetNortificationRequestValues.VIOLET_LED)
        }else if color == AppTheme.PALETTE_BAGGROUND_COLOR(){
            EnterNotificationController.setLedColor(notTypeArray[1] as NSString,ledColor:SetNortificationRequest.SetNortificationRequestValues.PURPLE_LED)
        }

        mSyncController?.SetNortification()
        mDelegate?.onSelectedType(true, type: notTypeArray[1] as NSString)
        
    }

    // MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.section == 0){
            return 50.0
        }else{
            return 170
        }

    }
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        if (section == 0){
            return 44.0
        }else{
            return UIScreen.mainScreen().bounds.height-373
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){

    }

    // MARK: - UITableViewDataSource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2;
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{

        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.section == 0){
            var endCell:NotificationTypeCell = tableView.dequeueReusableCellWithIdentifier("NotificationTypeCell", forIndexPath: indexPath) as NotificationTypeCell
            endCell.cellSwitch.on = notTypeArray[0] as Bool
            endCell.cellLabel.text = notTypeArray[1] as? String
            endCell.ActionDelegate = self

            return endCell
        }else if (indexPath.section == 1){

            let endCell:PaletteViewCell = enterNotView.EnterPaletteListCell(indexPath, dataSource: NSArray())
            if (((notTypeArray[3] as NSNumber).unsignedIntValue) == SetNortificationRequest.SetNortificationRequestValues.RED_LED){
                endCell.currentColorView.backgroundColor = UIColor.redColor()
            }else if (((notTypeArray[3] as NSNumber).unsignedIntValue) == SetNortificationRequest.SetNortificationRequestValues.BLUE_LED){
                endCell.currentColorView.backgroundColor = UIColor.blueColor()
            }else if (((notTypeArray[3] as NSNumber).unsignedIntValue) == SetNortificationRequest.SetNortificationRequestValues.GREEN_LED){
                endCell.currentColorView.backgroundColor = UIColor.greenColor()
            }else if (((notTypeArray[3] as NSNumber).unsignedIntValue) == SetNortificationRequest.SetNortificationRequestValues.YELLOW_LED){
                endCell.currentColorView.backgroundColor = UIColor.yellowColor()
            }else if (((notTypeArray[3] as NSNumber).unsignedIntValue) == SetNortificationRequest.SetNortificationRequestValues.VIOLET_LED){
                endCell.currentColorView.backgroundColor = UIColor.orangeColor()
            }
            else if (((notTypeArray[3] as NSNumber).unsignedIntValue) == SetNortificationRequest.SetNortificationRequestValues.PURPLE_LED){
                endCell.currentColorView.backgroundColor = AppTheme.PALETTE_BAGGROUND_COLOR()
            }
            
            endCell.pDelegate = self

            return endCell
        }

        return UITableViewCell()

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
