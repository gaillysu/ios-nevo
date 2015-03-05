//
//  EnterNotificationView.swift
//  Nevo
//
//  Created by leiyuncun on 15/3/4.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class EnterNotificationView: UITableView {

    private var mDelegate:ButtonManagerCallBack!
    var animationView:AnimationView!

    func bulidEnterNotificationView(delegate:ButtonManagerCallBack){
        mDelegate = delegate
        animationView = AnimationView(frame: self.frame, delegate: delegate)

    }

    func EnterPaletteListCell(indexPath:NSIndexPath,dataSource:NSArray)->PaletteViewCell {
        let endCellID:NSString = "endCell"
        var endCell = self.dequeueReusableCellWithIdentifier(endCellID) as? PaletteViewCell
        var StatesLabel:UILabel!

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
