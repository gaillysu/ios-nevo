//
//  SelectedNotificationView.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/1.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit
import SnapKit

class SelectedNotificationView: UITableView {

    func bulidSelectedNotificationView(_ navigationItem:UINavigationItem){
        
    }

    func getNotificationClockCell(_ indexPath:IndexPath, tableView:UITableView, title:String, clockIndex: Int)->UITableViewCell {
        let endCellID:NSString = "NotificationClockCell"
        var endCell = tableView.dequeueReusableCell(withIdentifier: endCellID as String) as? NotificationClockCell

        if (endCell == nil) {
            let nibs:[Any] = Bundle.main.loadNibNamed("NotificationClockCell", owner: self, options: nil)!
            endCell = nibs[0] as? NotificationClockCell;
        }
        for view in endCell!.contentView.subviews{
            if(view.isKind(of: UIImageView.classForCoder())){
                let clockImage:UIImageView = view as! UIImageView
                clockImage.image = UIImage(named: "\(clockIndex)_clock_dial")
                if !AppTheme.isTargetLunaR_OR_Nevo() {
                    clockImage.image = UIImage(named: "2_clock_dial")
                    let colorImage:UIImageView = UIImageView(image: UIImage(named: "\(clockIndex) o'clock"))
                    colorImage.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
                    endCell!.contentView.addSubview(colorImage)
                    colorImage.snp.makeConstraints { (make) -> Void in
                        make.top.equalTo(clockImage).offset(30)
                        make.left.equalTo(clockImage).offset(85)
                        make.right.equalTo(clockImage).offset(-85)
                    }
                    
                    /*
                    var blurEffect: UIBlurEffect?
                    if #available(iOS 10.0, *) {
                        blurEffect = UIBlurEffect(style: .regular)
                    } else {
                        blurEffect = UIBlurEffect(style: .dark)
                    }
                    let blurView: UIVisualEffectView = UIVisualEffectView(effect: blurEffect!)
                    endCell!.contentView.addSubview(blurView)
                    blurView.layer.masksToBounds = true;
                    blurView.layer.cornerRadius = 5.0;
                    blurView.layer.borderWidth = 1.0;
                    blurView.layer.borderColor = UIColor.clear.cgColor
                    blurView.snp.makeConstraints { (make) -> Void in
                        make.width.equalTo(10)
                        make.height.equalTo(10)
                        make.center.equalTo(colorImage)
                    }*/
                }
                
            }
        }
        endCell?.selectionStyle = UITableViewCellSelectionStyle.none;
        return endCell!
    }

    func getLineColorCell(_ indexPath:IndexPath,tableView:UITableView,cellTitle:String,clockIndex:Int)->UITableViewCell{
        let endCell:LineColorCell = tableView.dequeueReusableCell(withIdentifier: "LineColor_Identifier" ,for: indexPath) as! LineColorCell
        endCell.imageView?.image = UIImage(named: cellTitle)
        if((clockIndex/2 - 1) == indexPath.row){
            let image = UIImage(named: "notifications_check")
            endCell.accessoryView = UIImageView(image: image)
        }else{
            endCell.accessoryView = nil;
        }
        
        if !AppTheme.isTargetLunaR_OR_Nevo() {
        }else{
            endCell.textLabel!.text = cellTitle;
        }
        return endCell
    }

    /**
     LinkLoss Notifications TableViewCell

     :param: indexPath Path
     :param: tableView tableView object
     :param: title     title string

     :returns: return LinkLoss Notifications TableViewCell
     */
    func allowNotificationsTableViewCell(_ indexPath:IndexPath, tableView:UITableView, title:String, setting:NotificationSetting)->UITableViewCell {
        let allowCell:AllowNotificationsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AllowNotifications_Identifier", for: indexPath) as! AllowNotificationsTableViewCell
        allowCell.selectionStyle = UITableViewCellSelectionStyle.none;
        var titleColor:UIColor?
        var onColor:UIColor?
        if !AppTheme.isTargetLunaR_OR_Nevo() {
            titleColor = UIColor.white
            onColor = UIColor.getBaseColor()
            allowCell.backgroundColor = UIColor.getGreyColor()
        }else{
            titleColor = UIColor.black
            onColor = AppTheme.NEVO_SOLAR_YELLOW()
        }
        allowCell.setAllowSwitch(color: onColor!,isOn:setting.getStates())
        allowCell.setTitleLabel(title: title, titleColor: titleColor!, titleFont: nil)

        return allowCell
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
