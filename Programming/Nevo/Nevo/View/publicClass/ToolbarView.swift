//
//  ToolbarView.swift
//  Nevo
//
//  Created by leiyuncun on 15/11/26.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

protocol toolbarSegmentedDelegate:NSObjectProtocol {
    func didSelectedSegmentedControl(segment:UISegmentedControl)
}

class ToolbarView: UIView {

    var delegate:toolbarSegmentedDelegate?

    init(frame: CGRect,items:[String]) {
        super.init(frame: frame)

        let segment:UISegmentedControl = UISegmentedControl(items: items)
        segment.frame = CGRectMake(0, 0, self.frame.size.width-30, 29)
        segment.selectedSegmentIndex = 0
        segment.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        segment.addTarget(self, action: Selector("segmentAction:"), forControlEvents: UIControlEvents.TouchUpInside)

        let itemSeg:UIBarButtonItem = UIBarButtonItem(customView: segment)
        itemSeg.style = UIBarButtonItemStyle.Done
        itemSeg.action = nil
        let navToolbar:UIToolbar = UIToolbar(frame:  CGRectMake( 0, 0, self.frame.size.width, 35))

        let flexible:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        navToolbar.setItems([flexible,itemSeg,flexible], animated: true)
        self.addSubview(navToolbar)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func segmentAction(segment:UISegmentedControl){
        delegate?.didSelectedSegmentedControl(segment)
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
