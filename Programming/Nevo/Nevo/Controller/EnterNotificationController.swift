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
        static let FACEBOOK:NSString = "Facebook"
        static let CALENDAR:NSString = "Calendar"
        static let WECHAT:NSString = "WeChat"
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
            if sourceType == SOURCETYPE.SMS  { return SetNortificationRequest.SetNortificationRequestValues.PURPLE_LED }
            if sourceType == SOURCETYPE.EMAIL  { return SetNortificationRequest.SetNortificationRequestValues.YELLOW_LED }
            if sourceType == SOURCETYPE.FACEBOOK  { return SetNortificationRequest.SetNortificationRequestValues.VIOLET_LED }
            if sourceType == SOURCETYPE.CALENDAR  { return SetNortificationRequest.SetNortificationRequestValues.GREEN_LED }
            if sourceType == SOURCETYPE.WECHAT  { return SetNortificationRequest.SetNortificationRequestValues.RED_LED }
            
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
    var notTypeArray:NSMutableArray?

    var notType:TypeModel?

    /*
    Type switch state callBack to the before a object
    */
    var mDelegate:SelectionTypeDelegate?

    private var mSyncController:SyncController?
    
    /*
    led color default is full color led light on
    */
    //var ledcolor: UInt32 = 0xFF0000

    var numberCount:Int = 1
    var PaletteSele:Bool = false
    

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


    /**
    Used to change the content of array function

    :param: results The switch state
    :param: color   Select the color
    */
    func replaceNotTypeArray(results:Bool,color:NSNumber) {
        var index:Int = 0
        for model in notTypeArray! {
            let mModel:TypeModel = model as TypeModel
            let typeString:NSString = mModel.getNotificationTypeContent().objectForKey("type") as NSString
            let notTypeString:NSString = notType?.getNotificationTypeContent().objectForKey("type") as NSString
            let sss:Bool = mModel.getNotificationTypeContent().objectForKey("states") as Bool
            if typeString.isEqualToString(notTypeString) {
                mModel.setNotificationTypeStates(typeString, state: results, icon: mModel.getNotificationTypeContent().objectForKey("icon") as NSString, color: color)
                notTypeArray?.replaceObjectAtIndex(index, withObject: mModel)
            }
            index++
        }
    }

    // MARK: - SwitchActionDelegate
    func onSwitch(results:Bool){

        replaceNotTypeArray(results, color: notType?.getNotificationTypeContent().objectForKey("color") as NSNumber)
        EnterNotificationController.setMotorOnOff(notType?.getNotificationTypeContent().objectForKey("type") as NSString, motorStatus: results)
        mSyncController?.SetNortification(notTypeArray!)
        mDelegate?.onSelectedType(results, type: notType!.getNotificationTypeContent().objectForKey("type") as NSString)
    }

    // MARK: - PaletteDelegate
    func selectedPalette(color:UIColor){
        NSLog("UIColor\(color)")
        let indexPathRow:NSIndexPath = NSIndexPath(forRow: 0, inSection: 1)
        let cellForRow:CurrentPaletteCell = self.tableView.cellForRowAtIndexPath(indexPathRow) as CurrentPaletteCell
        cellForRow.currentColorView.backgroundColor = color

        if color == UIColor.blueColor(){
            EnterNotificationController.setLedColor(notType!.getNotificationTypeContent().objectForKey("type") as NSString,ledColor:SetNortificationRequest.SetNortificationRequestValues.BLUE_LED)
        }else if color == UIColor.redColor(){
            EnterNotificationController.setLedColor(notType!.getNotificationTypeContent().objectForKey("type") as NSString,ledColor:SetNortificationRequest.SetNortificationRequestValues.RED_LED)
        }else if color == UIColor.yellowColor(){
            EnterNotificationController.setLedColor(notType!.getNotificationTypeContent().objectForKey("type") as NSString,ledColor:SetNortificationRequest.SetNortificationRequestValues.YELLOW_LED)
        }else if color == UIColor.greenColor(){
            EnterNotificationController.setLedColor(notType!.getNotificationTypeContent().objectForKey("type") as NSString,ledColor:SetNortificationRequest.SetNortificationRequestValues.GREEN_LED)
        }else if color == UIColor.orangeColor(){
            EnterNotificationController.setLedColor(notType!.getNotificationTypeContent().objectForKey("type") as NSString,ledColor:SetNortificationRequest.SetNortificationRequestValues.VIOLET_LED)
        }else if color == UIColor.purpleColor(){
            EnterNotificationController.setLedColor(notType!.getNotificationTypeContent().objectForKey("type") as NSString,ledColor:SetNortificationRequest.SetNortificationRequestValues.PURPLE_LED)
        }
        replaceNotTypeArray(notType!.getNotificationTypeContent().objectForKey("states") as Bool, color: NSNumber(unsignedInt: EnterNotificationController.getLedColor(notType!.getNotificationTypeContent().objectForKey("type") as NSString)))
        mSyncController?.SetNortification(notTypeArray!)
        mDelegate?.onSelectedType(true, type: notType!.getNotificationTypeContent().objectForKey("type") as NSString)
        
    }

    // MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.section == 0){
            return 50.0
        }else{
            if indexPath.row == 0 {
                return 45
            }else {
                return 245
            }
        }
    }
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        if (section == 0){
            return 44.0
        }else{
            return 100
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if (indexPath.section == 1){
            if !PaletteSele {
                numberCount+=1
                PaletteSele = true
                let indexPathRow:NSIndexPath = NSIndexPath(forRow: 1, inSection: 1)
                tableView.insertRowsAtIndexPaths([indexPathRow], withRowAnimation: UITableViewRowAnimation.Bottom)
            }else {
                numberCount-=1
                PaletteSele = false
                let indexPathRow:NSIndexPath = NSIndexPath(forRow: 1, inSection: 1)
                tableView.deleteRowsAtIndexPaths([indexPathRow], withRowAnimation: UITableViewRowAnimation.Bottom)
            }
        }
    }

    // MARK: - UITableViewDataSource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2;
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if (section == 0) {
            return 1
        }else if (section == 1) {
            return numberCount
        }else{
            return 0
        }

    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.section == 0){
            var endCell:NotificationTypeCell = tableView.dequeueReusableCellWithIdentifier("NotificationTypeCell", forIndexPath: indexPath) as NotificationTypeCell
            endCell.cellSwitch.on = notType!.getNotificationTypeContent().objectForKey("states") as Bool
            endCell.cellLabel.text = notType!.getNotificationTypeContent().objectForKey("type") as? String
            endCell.ActionDelegate = self

            return endCell
        }else if (indexPath.section == 1){

            if (indexPath.row == 0) {
                let endCell:CurrentPaletteCell = enterNotView.EnterCurrentPaletteCell(indexPath)

                if (((notType!.getNotificationTypeContent().objectForKey("color") as NSNumber).unsignedIntValue) == SetNortificationRequest.SetNortificationRequestValues.RED_LED){
                    endCell.currentColorView.backgroundColor = UIColor.redColor()
                }else if (((notType!.getNotificationTypeContent().objectForKey("color") as NSNumber).unsignedIntValue) == SetNortificationRequest.SetNortificationRequestValues.BLUE_LED){
                    endCell.currentColorView.backgroundColor = UIColor.blueColor()
                }else if (((notType!.getNotificationTypeContent().objectForKey("color") as NSNumber).unsignedIntValue) == SetNortificationRequest.SetNortificationRequestValues.GREEN_LED){
                    endCell.currentColorView.backgroundColor = UIColor.greenColor()
                }else if (((notType!.getNotificationTypeContent().objectForKey("color") as NSNumber).unsignedIntValue) == SetNortificationRequest.SetNortificationRequestValues.YELLOW_LED){
                    endCell.currentColorView.backgroundColor = UIColor.yellowColor()
                }else if (((notType!.getNotificationTypeContent().objectForKey("color") as NSNumber).unsignedIntValue) == SetNortificationRequest.SetNortificationRequestValues.VIOLET_LED){
                    endCell.currentColorView.backgroundColor = UIColor.orangeColor()
                }
                else if (((notType!.getNotificationTypeContent().objectForKey("color") as NSNumber).unsignedIntValue) == SetNortificationRequest.SetNortificationRequestValues.PURPLE_LED){
                    endCell.currentColorView.backgroundColor = UIColor.purpleColor()
                }

                //endCell.pDelegate = self
                return endCell
            }else {
                let paletteCell:PaletteViewCell = enterNotView.EnterPaletteListCell(indexPath, dataSource: NSArray())
                paletteCell.pDelegate = self
                return paletteCell
            }

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
