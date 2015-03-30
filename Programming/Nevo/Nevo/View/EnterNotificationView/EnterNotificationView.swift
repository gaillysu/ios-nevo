//
//  EnterNotificationView.swift
//  Nevo
//
//  Created by leiyuncun on 15/3/4.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class EnterNotificationView: UIView {

    @IBOutlet weak var NotificationTableView: UITableView!

    private var mDelegate:ButtonManagerCallBack?
    var animationView:AnimationView?
    @IBOutlet weak  var backButton:UIButton!
    @IBOutlet weak  var title:UILabel!

    func bulidEnterNotificationView(delegate:ButtonManagerCallBack){

        title.textColor = UIColor.whiteColor()
        title.text = NSLocalizedString("NotificationType", comment: "")
        title.font = UIFont.systemFontOfSize(23)
        title.textAlignment = NSTextAlignment.Center

        mDelegate = delegate
        animationView = AnimationView(frame: self.frame, delegate: delegate)

    }

    @IBAction func BackAction(back:UIButton) {
        mDelegate?.controllManager(back)
    }

    func EnterCurrentPaletteCell(indexPath:NSIndexPath) ->CurrentPaletteCell{
        let CurrentCellID:NSString = "CurrentCell"
        var CurrentCell = NotificationTableView.dequeueReusableCellWithIdentifier(CurrentCellID) as? CurrentPaletteCell

        if (CurrentCell == nil) {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("CurrentPaletteCell", owner: self, options: nil)
            CurrentCell = nibs.objectAtIndex(0) as? CurrentPaletteCell;
            CurrentCell?.selectionStyle = UITableViewCellSelectionStyle.None
        }
        return CurrentCell!
    }

    func EnterPaletteListCell(indexPath:NSIndexPath,dataSource:NSArray)->PaletteViewCell {
        let endCellID:NSString = "PaletteListCell"
        var endCell = NotificationTableView.dequeueReusableCellWithIdentifier(endCellID) as? PaletteViewCell

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
