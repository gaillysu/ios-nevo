//
//  EnterNotificationView.swift
//  Nevo
//
//  Created by leiyuncun on 15/3/4.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class EnterNotificationView: UIView {

    private var mDelegate:ButtonManagerCallBack?
    var animationView:AnimationView?
    @IBOutlet weak  var backButton:UIButton!
    @IBOutlet weak  var title:UILabel!
    @IBOutlet weak var titleBgView: UIView!
    @IBOutlet weak var blueButton: UIButton!

    @IBOutlet weak var redButton: UIButton!

    @IBOutlet weak var greenButton: UIButton!

    @IBOutlet weak var yellowButton: UIButton!

    @IBOutlet weak var orangeButton: UIButton!

    @IBOutlet weak var peakgreenButton: UIButton!

    func bulidEnterNotificationView(delegate:ButtonManagerCallBack,seting:NotificationSetting){

        title.textColor = UIColor.whiteColor()
        title.text = NSLocalizedString("NotificationType", comment: "")
        title.font = UIFont.systemFontOfSize(23)
        title.textAlignment = NSTextAlignment.Center

        mDelegate = delegate
        animationView = AnimationView(frame: self.frame, delegate: delegate)

        title.text = NSLocalizedString(seting.typeName, comment: "")

        let currentColor:UInt32 = seting.getColor().unsignedIntValue
        if (currentColor == SetNortificationRequest.SetNortificationRequestValues.RED_LED){
            //endCell.typeTitle.backgroundColor = AppTheme.NEVO_CUSTOM_COLOR(Red: 229, Green: 0, Blue: 18)
            redButton.selected = true

        }else if (currentColor == SetNortificationRequest.SetNortificationRequestValues.BLUE_LED){
            //endCell.typeTitle.backgroundColor = AppTheme.NEVO_CUSTOM_COLOR(Red: 44, Green: 166, Blue: 224)
            blueButton.selected = true

        }else if (currentColor == SetNortificationRequest.SetNortificationRequestValues.GREEN_LED){
            //endCell.typeTitle.backgroundColor = AppTheme.NEVO_CUSTOM_COLOR(Red: 141, Green: 194, Blue: 31)
            greenButton.selected = true

        }else if (currentColor == SetNortificationRequest.SetNortificationRequestValues.YELLOW_LED){
            //endCell.typeTitle.backgroundColor = AppTheme.NEVO_CUSTOM_COLOR(Red: 250, Green: 237, Blue: 0)
            yellowButton.selected = true

        }else if (currentColor == SetNortificationRequest.SetNortificationRequestValues.ORANGE_LED){
            //endCell.typeTitle.backgroundColor = AppTheme.NEVO_CUSTOM_COLOR(Red: 242, Green: 150, Blue: 0)
            orangeButton.selected = true

        }
        else if (currentColor == SetNortificationRequest.SetNortificationRequestValues.LIGHTGREEN_LED){
            //endCell.typeTitle.backgroundColor = AppTheme.NEVO_CUSTOM_COLOR(Red: 13, Green: 172, Blue: 103)
            peakgreenButton.selected = true

        }


    }

    @IBAction func BackAction(back:UIButton) {
        mDelegate?.controllManager(back)
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
