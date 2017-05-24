//
//  SetingViewController.swift
//  Nevo
//
//  Created by leiyuncun on 15/3/24.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit
import BRYXBanner
import SwiftEventBus
import XCGLogger
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
    import RxDataSources
#endif

class SettingViewController: UITableViewController {
    //vibrate and show all color light to find my device, only send one request in 6 sec
    //this action take lot power and we maybe told customer less to use it
    var mFindMydeviceDatetime:Date = Date(timeIntervalSinceNow: -6)
    
    let settingItems = Variable([
        SettingSectionModel(header:"User info",footer:"",items:[
            SettingSectionModelItem(label: "User", type: SetingType.userInfo, name:"usericon")]),
        SettingSectionModel(header:"Watch Settings",footer:"",items:[
            SettingSectionModelItem(label: NSLocalizedString("My Nevo", comment: ""), type: SetingType.myNevo, name:"icon_nevo"),
            SettingSectionModelItem(label: NSLocalizedString("Notifications", comment: ""), type: SetingType.notifications, name:"icon_bell"),
            SettingSectionModelItem(label: NSLocalizedString("Scan Duration", comment: ""), type: SetingType.scanDuration, name:"icon_bluetooth"),
            SettingSectionModelItem(label: NSLocalizedString("Link-Loss Notifications", comment: ""), type: SetingType.linkLoss, name:"icon_chain"),
            SettingSectionModelItem(label: NSLocalizedString("find_my_watch", comment: ""), type: SetingType.findWatch, name:"icon_crosshair")
            ]),
        SettingSectionModel(header:"App Settings",footer:"",items:[
            SettingSectionModelItem(label: NSLocalizedString("goals", comment: ""), type: SetingType.goal, name:"icon_goals"),
            SettingSectionModelItem(label: NSLocalizedString("unit", comment: ""), type: SetingType.unit, name:"icon_scale")
            ]),
        SettingSectionModel(header:"Other Settings",footer:"",items:[
            SettingSectionModelItem(label: NSLocalizedString("Support", comment: ""), type: SetingType.support, name:"icon_support")
            ])
        ])
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("Setting", comment: "")
        
        tableView.separatorColor = UIColor.lightGray
        tableView.viewDefaultColorful()
        tableView.register(UINib(nibName:"SetingNotLoginCell" ,bundle: nil), forCellReuseIdentifier: "SetingNotLoginIdentifier")
        tableView.register(UINib(nibName:"SetingInfoCell" ,bundle: nil), forCellReuseIdentifier: "SetingInfoIdentifier")
        tableView.register(UINib(nibName:"LinkLossNotificationsCell" ,bundle: nil), forCellReuseIdentifier: "LinkLossNotifications_Identifier")
        tableView.register(UINib(nibName:"SetingValue1Cell" ,bundle: nil), forCellReuseIdentifier: "SetingValue1_Identifier")
        tableView.register(UINib(nibName:"SetingDefaultCell" ,bundle: nil), forCellReuseIdentifier: "SetingDefault_Identifier")
        
        let dataSource = RxTableViewSectionedReloadDataSource<SettingSectionModel>()
        
        dataSource.configureCell = { (_ , tv, indexPath, element) in
            if element.type == .userInfo {
                let users = MEDUserProfile.getAll()
                if users.count>0 {
                    let cell = tv.dequeueReusableCell(withIdentifier: "SetingInfoIdentifier", for: indexPath)
                    cell.separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.size.width, bottom: 0, right: 0)
                    let users = MEDUserProfile.getAll()
                    let userprofile:MEDUserProfile = users[0] as! MEDUserProfile
                    (cell as! SetingInfoCell).emailLabel.text = userprofile.email
                    (cell as! SetingInfoCell).userName.text = "\(userprofile.first_name) \(userprofile.last_name)"
                    if let image = ProfileImageManager.shared.getImage() {
                        (cell as! SetingInfoCell).avatarImageView.image = image
                    }
                    cell.viewDefaultColorful()
                    return cell
                }else{
                    let cell = tv.dequeueReusableCell(withIdentifier: "SetingNotLoginIdentifier", for: indexPath)
                    cell.separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.size.width, bottom: 0, right: 0)
                    cell.viewDefaultColorful()
                    return cell
                }
            }else if element.type == .linkLoss {
                let cell:LinkLossNotificationsCell = tv.dequeueReusableCell(withIdentifier: "LinkLossNotifications_Identifier", for: indexPath) as! LinkLossNotificationsCell
                cell.model = (element.label,element.iconName,element.type)
                return cell
            }else {
                let valueCell:SetingValue1Cell = tv.dequeueReusableCell(withIdentifier: "SetingValue1_Identifier", for: indexPath) as! SetingValue1Cell
                valueCell.model = (element.label,element.iconName,element.type)
                
                return valueCell
            }
        }
        
        dataSource.setSections(settingItems.value)
        
        settingItems.asObservable().bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        
        _ = SwiftEventBus.onMainThread(self, name: EVENT_BUS_CONNECTION_STATE_CHANGED_KEY) { (notification) in
            self.checkConnection()
        }
        
        _ = SwiftEventBus.onMainThread(self, name: EVENT_BUS_BLUETOOTH_STATE_CHANGED) { (notification) in
            self.checkConnection()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        ConnectionManager.manager.startConnect(false)
        tableView.reloadData()
    }
    
    
    // MARK: - SetingViewController function
    func findMydevice(){
        let minDelay:Double = 6
        let offset:Double = (Date().timeIntervalSince1970 - mFindMydeviceDatetime.timeIntervalSince1970)
        XCGLogger.default.debug("findMydevice offset:\(offset)")
        if (offset < minDelay) {
            return
        }
        
        if UserDefaults.standard.getSoftwareVersion() > 25 {
            ConnectionManager.manager.sendRequest(FindWatchRequest(ledtype: FindWatchLEDType.allWhiteLED, motorOnOff: true))
        }else{
            ConnectionManager.manager.sendRequest(LedLightOnOffNevoRequest(ledpattern: 0x3F0000, motorOnOff: true))
        }
        mFindMydeviceDatetime = Date()
    }
    
    func addActivityView(_ indexPath:IndexPath) {
        if let cellView = tableView.cellForRow(at: indexPath) {
            for activityView in cellView.contentView.subviews{
                if(activityView.isKind(of: UIActivityIndicatorView.classForCoder())) {
                    let activity:UIActivityIndicatorView = activityView as! UIActivityIndicatorView
                    if(!activity.isAnimating){
                        activity.startAnimating()
                        let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(3.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                            activity.stopAnimating()
                        })
                    }
                    break
                }else{
                    let activity:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
                    activity.center = CGPoint(x: UIScreen.main.bounds.size.width-25, y: cellView.contentView.frame.size.height/2.0)
                    cellView.contentView.addSubview(activity)
                    if(!activity.isAnimating){
                        activity.startAnimating();
                        let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(3.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                            activity.stopAnimating()
                        })
                    }
                }
            }
        }
    }
    
    /**
     Checks if any device is currently connected
     */
    func checkConnection() {
        tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: UITableViewRowAnimation.fade)
        if !ConnectionManager.manager.isConnected {
            //We are currently not connected
            reconnect()
        }
    }
    
    func reconnect() {
        ConnectionManager.manager.connect()
    }
    
    func showSelectedUnitAlertView() {
        let alertController = UIAlertController(title: NSLocalizedString("Unit", comment: ""), message: "Please choose to use the unit", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Metrics", comment: ""), style: .default, handler: { _ in
            UserDefaults.standard.setUserSelectedUnitValue(0)
        }))
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Imperical", comment: ""), style: .default, handler: { _ in
            UserDefaults.standard.setUserSelectedUnitValue(1)
            
        }))
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        
        alertController.actions.forEach { action in
            action.setValue(UIColor.baseColor, forKey: "titleTextColor")
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showUpdateNevoAlertView(){
        let alertController = UIAlertController(title: NSLocalizedString("Update", comment: ""), message: "Update your Nevo to use this feature", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Update", comment: ""), style: .default, handler: { _ in
            
            if ConnectionManager.manager.isConnected {
                let otaCont:NevoOtaViewController = NevoOtaViewController()
                let navigation:UINavigationController = UINavigationController(rootViewController: otaCont)
                self.present(navigation, animated: true, completion: nil)
            }else{
                let banner = MEDBanner(title: NSLocalizedString("nevo_is_not_connected", comment: ""), subtitle: nil, image: nil, backgroundColor: UIColor.baseColor)
                banner.dismissesOnTap = true
                banner.show(duration: 1.5)
            }
            
        }))
        alertController.actions.forEach { action in
            action.setValue(UIColor.baseColor, forKey: "titleTextColor")
        }
        self.present(alertController, animated: true, completion: nil)
    }
}
extension SettingViewController {
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 80
        }
        return 50.0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section{
        case 0:
            let users = MEDUserProfile.getAll()
            if users.count == 0 {
                let login:LoginController = LoginController()
                let naviController = UINavigationController(rootViewController: login)
                self.present(naviController, animated: true, completion: nil)
            }else{
                let userprofile:UserProfileController = UserProfileController()
                userprofile.isPushed = true
                userprofile.title = "Profile"
                userprofile.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(userprofile, animated: true)
            }
        case 1:
            switch indexPath.row {
            case 0:
                let myNevoController = MyNevoController()
                myNevoController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(myNevoController, animated: true)
                return
            case 1:
                let notificationViewController = NotificationViewController()
                notificationViewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(notificationViewController, animated: true)
            case 2:
                if UserDefaults.standard.getFirmwareVersion() >= buildin_firmware_version && UserDefaults.standard.getSoftwareVersion() >= buildin_software_version{
                    let bluetoothScanDurationViewController = BluetoothScanDurationViewController()
                    bluetoothScanDurationViewController.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(bluetoothScanDurationViewController, animated: true)
                }else{
                    showUpdateNevoAlertView()
                }
                
                break;
            case 4:
                findMydevice()
                
                addActivityView(indexPath)
                
            default:
                break
            }
            
        case 2:
            switch indexPath.row {
            case 0:
                let goalController = UserGoalController()
                goalController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(goalController, animated: true)
            case 1:
                showSelectedUnitAlertView()
                break
            default:
                break
            }
        case 3:
            UIApplication.shared.openURL(URL(string: "http://support.nevowatch.com/support/home")!)
        default: break
        }
    }
    
}

extension SettingViewController:UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) {
            transitionContext.containerView.addSubview(self.view)
            toView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            self.view.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            
            UIView.animate(withDuration: 3, animations: {
                self.view.frame = transitionContext.containerView.frame
                toView.frame = UIScreen.main.bounds
            }, completion: { (_) in
                self.view.removeFromSuperview()
                transitionContext.containerView.addSubview(toView)
                transitionContext.completeTransition(true)
            })
        }
    }
}
