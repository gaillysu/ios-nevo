//
//  NotificationView.swift
//  Nevo
//
//  Created by leiyuncun on 15/3/3.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class NotificationView: UIView {

    @IBOutlet var tableListView: UITableView!

    private var mDelegate:ButtonManagerCallBack?
    var animationView:AnimationView!

    func bulidNotificationViewUI(delegate:ButtonManagerCallBack,navigationItem:UINavigationItem){
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 120, 30))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = NSLocalizedString("Notification", comment: "")
        titleLabel.font = UIFont.systemFontOfSize(25)
        titleLabel.textAlignment = NSTextAlignment.Center
        navigationItem.titleView = titleLabel

        mDelegate? = delegate
        animationView = AnimationView(frame: self.frame, delegate: delegate)
        
    }
    
    func NotificationlistCell(indexPath:NSIndexPath,dataSource:NSArray)->UITableViewCell {
        let endCellID:NSString = "endCell"
        var endCell = tableListView.dequeueReusableCellWithIdentifier(endCellID) as? TableListCell
        var StatesLabel:UILabel!

        if (endCell == nil) {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("TableListCell", owner: self, options: nil)
             endCell = nibs.objectAtIndex(0) as? TableListCell;
            endCell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator;

        }
        endCell?.selectionStyle = UITableViewCellSelectionStyle.None;
        let typeContent:NSDictionary = (dataSource[indexPath.row] as TypeModel).getNotificationTypeContent()
        if (typeContent.objectForKey("states") as Bool){
            endCell?.StatesLabel.text = NSLocalizedString("On", comment:"")
        }else{
            endCell?.StatesLabel.text = NSLocalizedString("Off", comment:"")
        }
        endCell?.textLabel?.text = NSLocalizedString(typeContent.objectForKey("type") as String, comment: "")
        endCell?.imageView?.image = UIImage(named:typeContent.objectForKey("icon") as String)
        endCell?.StatesLabel.textColor = AppTheme.NEVO_SOLAR_GRAY()

        return endCell!

    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
