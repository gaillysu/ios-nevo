//
//  ProfileTestController.swift
//  Nevo
//
//  Created by ideas on 15/3/6.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

/**
*  just for test 
*  to get all information about the watch
*/
class ProfileTestController: UITableViewController,SyncControllerDelegate,ButtonManagerCallBack {

    @IBOutlet var myTable: UITableView?
    
    private var mSyncController:SyncController?
    private var mPacketsbuffer:[NSData]=[]
    
    var dataSource = NSMutableArray()
    var currentIndexPath: NSIndexPath?

    class UserModel : NSObject {
        var userName: String     ///< store user's name, optional
        var userID: Int          ///< store user's ID
        var phone: String?       ///< store user's telephone number
        var email: String?       ///< store user's email
        
        // designated initializer
        init(userName: String, userID: Int, phone: String?, email: String?) {
            self.userName = userName
            self.userID = userID
            self.phone = phone
            self.email = email
            
            super.init()  
        }  
    }
    
    class UserInfoCell : UITableViewCell {
        var userNameLabel : UILabel!
        var phoneLabel : UILabel!
        var emailLabel : UILabel!
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            userNameLabel = UILabel(frame: CGRectMake(30, 0, 50, 44))
            userNameLabel.backgroundColor = UIColor.clearColor()
            userNameLabel.font = UIFont.systemFontOfSize(14)
            self.contentView.addSubview(userNameLabel)
            
            phoneLabel = UILabel(frame: CGRectMake(70, 0, 250, 20))
            phoneLabel.backgroundColor = UIColor.clearColor()
            phoneLabel.font = UIFont.systemFontOfSize(12)
            self.contentView.addSubview(phoneLabel)
            
            emailLabel = UILabel(frame: CGRectMake(70, 20, 250, 40))
            emailLabel.backgroundColor = UIColor.clearColor()
            emailLabel.font = UIFont.systemFontOfSize(12)
            emailLabel.lineBreakMode = NSLineBreakMode.ByCharWrapping
            emailLabel.numberOfLines = 0
            self.contentView.addSubview(emailLabel)
        }

        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func configureCell(userModel: UserModel?) {
            if let model = userModel {
                userNameLabel.text = model.userName
                phoneLabel.text = model.phone  
                emailLabel.text = model.email  
            }  
        }  
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //init the request object
        mSyncController = SyncController.sharedInstance
        mSyncController?.startConnect(false, delegate: self)
        
        let firstMode = UserModel(userName: "\(0 + 1)",userID: 0, phone: "test", email: "test")
        dataSource.addObject(firstMode)
        // Do any additional setup after loading the view.
//        for index in 0...1 {
//            let model = UserModel(userName: "\(index + 1)",
//                userID: index, phone: "13877747982", email: "632840804@qq.com")
//            dataSource.addObject(model)
//        }
        
        self.title = "UITableViewDemo"
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
//        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        
        //add back button
        var backButton = UIButton(frame: CGRectMake(0, 0, 35, 35))
        backButton.setImage(UIImage(named: "back"), forState: UIControlState.Normal)
        backButton.addTarget(self, action: Selector("goBack"), forControlEvents: UIControlEvents.TouchUpInside)
        let item:UIBarButtonItem = UIBarButtonItem(customView: backButton as UIView!);
        navigationItem.leftBarButtonItem = item
        
        //add refresh control
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "refreshData", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl?.attributedTitle = NSAttributedString(string: "xxxx")
        
//        tableView.addPullToRefreshWithAction({
//            NSOperationQueue().addOperationWithBlock {
//                sleep(2)
//                NSOperationQueue.mainQueue().addOperationWithBlock {
//                    self.tableView.stopPullToRefresh()
//                }
//            }
//            }, withAnimator: BeatAnimator())
        
        
    }

    func goBack(){
//        self.navigationController?.popViewControllerAnimated(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        checkConnection()
    }
    
    /**
    Checks if any device is currently connected
    */
    func checkConnection() {
        if mSyncController != nil && !(mSyncController!.isConnected()) {
//            self.tabBarController?.selectedIndex = 1
//            goBack()
        }
        
    }
    
    func refreshData() {
        dataSource.removeAllObjects()
//        let firstMode = UserModel(userName: "name:\(0 + 1)",userID: 0, phone: "11111111", email: "632840804@qq.com")
//        dataSource.addObject(firstMode)
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
        
        //to get the profile information
        mPacketsbuffer = []
        mSyncController?.getGoal()
        
        //to get the information about notification
        var keys = []
        var userSetting = NSUserDefaults.standardUserDefaults()
        //var notificationSetting = TypeModel().getNotificationTypeContent()
        var notificationArray = refreshNotificationSettingArray()
        for (key,value) in notificationArray{
            NSLog("key:\(key.rawValue) \(value.description())")
        }
    }
    
    func insertNewObject(sender:AnyObject){
        let firstMode = UserModel(userName: "name:\(0 + 1)",userID: 0, phone: "11111111", email: "632840804@qq.com")
        dataSource.insertObject(firstMode, atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    func insertNewItem(user:UserModel){
        let firstMode = user
        dataSource.insertObject(firstMode, atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    // MARK: - Table view data source
    //return section num
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    //return num of line in the section
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // can't use static?
        let cellIdentifier: String = "UserInfoCellIdentifier"
        // may be no value, so use optional
        var cell: UserInfoCell? = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? UserInfoCell
        
        if cell == nil { // no value
            cell = UserInfoCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        }
        
        let model: UserModel? = dataSource[indexPath.row] as? UserModel
        cell!.configureCell(model)
        
        return cell!
    }
    
    // support the cell edit function
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return false
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            dataSource.removeObjectAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        if fromIndexPath != toIndexPath{
            var object: AnyObject = dataSource.objectAtIndex(fromIndexPath.row)
            dataSource.removeObjectAtIndex(fromIndexPath.row)
            if toIndexPath.row > self.dataSource.count{
                self.dataSource.addObject(object)
            }else{
                self.dataSource.insertObject(object, atIndex: toIndexPath.row)
            }
        }
    }
    
    
    
    // Override to support conditional rearranging of the table view.
    //when it at edit status , you can move the position of the item
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }

    // MARK: - ButtonManagerCallBack
    func controllManager(sender:AnyObject){
        if sender.isEqual(true) {
            NSLog("noConnectScanButton")
            reconnect()
        }
    }
    
    /**
    See SyncControllerDelegate
    */
    func connectionStateChanged(isConnected : Bool) {
        //Maybe we just got disconnected, let's check
    }
    
    // MARK: - SyncControllerDelegate
    /**
    See SyncControllerDelegate
    */
    func packetReceived(packet:RawPacket) {
        mPacketsbuffer.append(packet.getRawData())
        
        if(NSData2Bytes(packet.getRawData())[0] == 0xFF
            && NSData2Bytes(packet.getRawData())[1] == 0x26 )
        {
            var dailySteps:Int = Int(NSData2Bytes(mPacketsbuffer[0])[2] )
            dailySteps =  dailySteps + Int(NSData2Bytes(mPacketsbuffer[0])[3] )<<8
            dailySteps =  dailySteps + Int(NSData2Bytes(mPacketsbuffer[0])[4] )<<16
            dailySteps =  dailySteps + Int(NSData2Bytes(mPacketsbuffer[0])[5] )<<24
            
            var dailyStepGoal:Int = Int(NSData2Bytes(mPacketsbuffer[0])[6] )
            dailyStepGoal =  dailyStepGoal + Int(NSData2Bytes(mPacketsbuffer[0])[7] )<<8
            dailyStepGoal =  dailyStepGoal + Int(NSData2Bytes(mPacketsbuffer[0])[8] )<<16
            dailyStepGoal =  dailyStepGoal + Int(NSData2Bytes(mPacketsbuffer[0])[9] )<<24
            
            let numberOfSteps = NSUserDefaults.standardUserDefaults().objectForKey("NUMBER_OF_STEPS_GOAL_KEY") as? Int
            
            var percent :Float = Float(dailySteps)/Float(dailyStepGoal)
            
            NSLog("the profile get Daily Steps is: \(dailySteps), getDaily Goal is: \(dailyStepGoal), saved Goal is:\(numberOfSteps),percent is: \(percent)")
            
            var stepGoal = "step: \(dailySteps) watchGoal: \(dailyStepGoal)\n"
            var appGoal = "appGoal: \(numberOfSteps) percent: \(percent) \n"
            
            insertNewItem(UserModel(userName: "0", userID: 0, phone: stepGoal, email: appGoal))
        }
    }
    
    func reconnect() {

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    
    //create all notification setting
    func getNotificationSettingArray() -> Dictionary<NotificationType,NotificationSetting>{
        var config:Dictionary<String, String> = ["CALL":"callIcon", "SMS":"smsIcon", "EMAIL":"emailIcon", "FaceBook":"callIcon", "Twitter":"callIcon", "Whatsapp":"callIcon" ]
        var notificationArray:Dictionary<NotificationType,NotificationSetting> = [:]
        for (key, value) in config {
            if var valueType:NotificationType = NotificationType(rawValue: key){
                notificationArray.updateValue(NotificationSetting(type: valueType, icon: value, color: 0), forKey: valueType)
            }
        }
        return notificationArray
    }
    
    func refreshNotificationSettingArray() -> Dictionary<NotificationType,NotificationSetting>{
        var notificationArray:Dictionary<NotificationType,NotificationSetting> = getNotificationSettingArray()
        for (key,value) in notificationArray{
            value.updateValueFromEnternotification()
        }
        return notificationArray
    }
    

    // notification setting
    class NotificationSetting {
        var mStates:Bool = true
        var mType:NotificationType
        var mIcon:NSString
        var mColor:NSNumber
        
        init(type:NotificationType, icon:NSString, color:NSNumber){
            mType = type
            mIcon = icon
            mColor = color
        }
        
        func updateValueFromEnternotification(){
            mColor = NSNumber(unsignedInt: EnterNotificationController.getLedColor(mType.rawValue))
            mStates = EnterNotificationController.getMotorOnOff(mType.rawValue)
        }
        
        func description() -> String{
            var description = ""
            description = "type:\(mType.rawValue) color:\(mColor) status:\(mStates)"
            return description
        }
        
        func getColorName(){
            var colorName = ""
        }
    }
    
    //notification type
    enum NotificationType:NSString {
        case CALL = "CALL"
        case SMS = "SMS"
        case EMAIL = "EMAIL"
        case FACEBOOK = "FaceBook"
        case TWITTER = "Twitter"
        case WHATSAPP = "Whatsapp"
        
        static let allValues = [CALL, SMS, EMAIL, FACEBOOK, TWITTER, WHATSAPP]
    }
    
    //end of class
}
