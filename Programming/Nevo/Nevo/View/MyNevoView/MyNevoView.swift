//
//  MyNevoView.swift
//  Nevo
//
//  Created by leiyuncun on 15/5/25.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class MyNevoView: UIView {
    @IBOutlet weak var titleBgView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var UpgradeButton: UIButton!
    @IBOutlet weak var mywatchName: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var update: UILabel!
    @IBOutlet weak var batteryImage: UIImageView!
    @IBOutlet weak var batteryBackground: UIImageView!
    
    private var mDelegate:ButtonManagerCallBack?
    private var watchVersion:UILabel?//Display watch MCU and BLE version number

    var animationView:AnimationView?

    func bulidMyNevoView(delegate:ButtonManagerCallBack){
        mDelegate = delegate

        animationView = AnimationView(frame: self.frame, delegate: delegate)

        title.text = NSLocalizedString("My nevo", comment: "")
        title.font = AppTheme.FONT_RALEWAY_LIGHT(mSize: 25)
        title.textAlignment = NSTextAlignment.Center

        mywatchName.text = NSLocalizedString("namenevo", comment: "")
        mywatchName.font = AppTheme.FONT_RALEWAY_LIGHT(mSize: 20)

        progressLabel.text = String(format: "%d%c",0,37)
        progressLabel.font = AppTheme.FONT_RALEWAY_LIGHT(mSize: 18)

        let objArray:NSArray = AppTheme.LoadKeyedArchiverName("LatestUpdate") as! NSArray
        update.numberOfLines = 0
        update.lineBreakMode = NSLineBreakMode.ByWordWrapping
        update.font = AppTheme.FONT_RALEWAY_LIGHT(mSize: 15)
        if(objArray.count>0){
            update.text = NSString(format: "%@ %@", NSLocalizedString("LatestUpdateon",comment: ""),objArray[1] as! String) as String
        }else{
            update.text = NSString(format: "%@ %@", NSLocalizedString("LatestUpdateon",comment: ""),"_/_/_") as String
        }

        UpgradeButton.setTitle(NSLocalizedString("upgrade",comment: ""), forState: UIControlState.Normal)
        UpgradeButton.setTitle(NSLocalizedString("latestversion",comment: ""), forState: UIControlState.Selected)
        UpgradeButton.backgroundColor = AppTheme.NEVO_CUSTOM_COLOR()
        UpgradeButton.titleLabel?.font = AppTheme.FONT_RALEWAY_LIGHT(mSize: 15)
        UpgradeButton.selected = true
        UpgradeButton.layer.masksToBounds = true
        UpgradeButton.layer.cornerRadius = 20.0

        watchVersion = UILabel(frame: CGRectMake(0, 90, 150, 50))
        watchVersion!.numberOfLines = 0
        watchVersion!.lineBreakMode = NSLineBreakMode.ByWordWrapping
        watchVersion!.textAlignment = NSTextAlignment.Left
        watchVersion!.font = AppTheme.FONT_RALEWAY_LIGHT(mSize: 15)
        self.addSubview(watchVersion!)
    }

    @IBAction func buttonAction(sender: AnyObject) {

        mDelegate?.controllManager(sender)
    }

    func setBatteryLevelValue(value:Int){
        var bValue:Float = Float(value)
        if (value == 0){
            progressLabel.text = String(format: ">20%c",37)
            bValue = 0
        }else if (value == 1){
            progressLabel.text = String(format: "<50%c",37)
            bValue = 0.5
        }else if (value == 2){
            progressLabel.text = String(format: "100%c",37)
            bValue = 1.0
        }

        var frame:CGRect = batteryImage.frame;
        batteryImage.clipsToBounds = true
        //batteryImage.contentMode = UIViewContentMode.Right
        frame.size.width = CGFloat(bValue) * batteryBackground.bounds.size.width;
        batteryImage.frame = frame;
    }

    func setVersionLbael(mcuNumber:NSString,bleNumber:NSString){
        watchVersion!.text = String(format: "Mcu %@%@\n BLE %@%@",NSLocalizedString("Version:",comment:""), mcuNumber,NSLocalizedString("Version:",comment:""),bleNumber)
    }
    
}
