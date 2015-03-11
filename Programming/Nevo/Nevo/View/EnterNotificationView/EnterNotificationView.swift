//
//  EnterNotificationView.swift
//  Nevo
//
//  Created by leiyuncun on 15/3/4.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class EnterNotificationView: UITableView {

    private var mDelegate:ButtonManagerCallBack?
    var animationView:AnimationView?
    var backButton:UIButton?

    func bulidEnterNotificationView(delegate:ButtonManagerCallBack,navigationItem:UINavigationItem){

        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 120, 30))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = NSLocalizedString("NotificationType", comment: "")
        titleLabel.font = UIFont.systemFontOfSize(25)
        titleLabel.textAlignment = NSTextAlignment.Center
        navigationItem.titleView = titleLabel

        backButton = UIButton(frame: CGRectMake(0, 0, 35, 35))
        backButton?.setImage(UIImage(named: "back"), forState: UIControlState.Normal)
        backButton?.addTarget(self, action: Selector("BackAction:"), forControlEvents: UIControlEvents.TouchUpInside)
        let item:UIBarButtonItem = UIBarButtonItem(customView: backButton as UIView!);
        navigationItem.leftBarButtonItem = item

        mDelegate = delegate
        animationView = AnimationView(frame: self.frame, delegate: delegate)

    }

    func BackAction(back:UIButton) {
        mDelegate?.controllManager(back)
    }

    func EnterCurrentPaletteCell(indexPath:NSIndexPath) ->CurrentPaletteCell{
        let CurrentCellID:NSString = "CurrentCell"
        var CurrentCell = self.dequeueReusableCellWithIdentifier(CurrentCellID) as? CurrentPaletteCell

        if (CurrentCell == nil) {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("CurrentPaletteCell", owner: self, options: nil)
            CurrentCell = nibs.objectAtIndex(0) as? CurrentPaletteCell;
            CurrentCell?.selectionStyle = UITableViewCellSelectionStyle.None
            CurrentCell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            var bhView:UIView = UIView(frame: CGRectMake(0, 0, 45, 45))
            bhView.backgroundColor = UIColor.purpleColor()
            CurrentCell?.accessoryView = bhView
        }
        return CurrentCell!
    }

    func EnterPaletteListCell(indexPath:NSIndexPath,dataSource:NSArray)->PaletteViewCell {
        let endCellID:NSString = "PaletteListCell"
        var endCell = self.dequeueReusableCellWithIdentifier(endCellID) as? PaletteViewCell

        if (endCell == nil) {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("PaletteViewCell", owner: self, options: nil)
            endCell = nibs.objectAtIndex(0) as? PaletteViewCell;
            endCell?.selectionStyle = UITableViewCellSelectionStyle.None;
        }

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
