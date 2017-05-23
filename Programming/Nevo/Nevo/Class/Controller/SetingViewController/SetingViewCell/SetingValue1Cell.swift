//
//  SetingValue1Cell.swift
//  Nevo
//
//  Created by Cloud on 2017/5/22.
//  Copyright © 2017年 Nevo. All rights reserved.
//

import UIKit
import MSCellAccessory

enum SetingType {
    case myNevo
    case notifications
    case linkLoss
    case scanDuration
    case findWatch
    case goal
    case unit
    case support
}

class SetingValue1Cell: UITableViewCell {
    
    var model:(cellName:String,imageName:String,setingType:SetingType)? {
        didSet{
            textLabel?.text = model!.cellName
            imageView?.image = UIImage(named: model!.imageName)
            setDefaultsDetailText(model!.setingType)
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.white
        textLabel?.textColor = UIColor.black
        textLabel!.backgroundColor = UIColor.clear
        accessoryType = .disclosureIndicator
        viewDefaultColorful()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setDefaultsDetailText(_ type:SetingType) {
        detailTextLabel?.text = nil
        detailTextLabel?.alpha = 1
        accessoryType = .none
        
        if type == .myNevo {
            var statusString = NSLocalizedString("Disconnected", comment: "")
            var color = UIColor.darkRed
            if ConnectionManager.manager.isConnected {
                if UserDefaults.standard.getFirmwareVersion() < buildin_firmware_version || UserDefaults.standard.getSoftwareVersion() < buildin_software_version {
                    statusString = NSLocalizedString("New Version Available!", comment: "")
                    color = UIColor.baseColor
                }else {
                    statusString = NSLocalizedString("Connected", comment: "")
                    color = UIColor.darkGreen
                }
            }
            detailTextLabel?.text = statusString
            detailTextLabel?.textColor = color
            detailTextLabel?.alpha = 0.7
        }
        
        if type == .scanDuration {
            if UserDefaults.standard.getFirmwareVersion() >= 40 && UserDefaults.standard.getSoftwareVersion() >= 27{
                enable(on: true)
                detailTextLabel?.textColor = UIColor.lightGray
                detailTextLabel?.text = UserDefaults.standard.getDurationSearch().shortTimeRepresentation()
                accessoryView = nil
                accessoryType = .disclosureIndicator
            }else{
                enable(on: false)
                accessoryType = .none
                isUserInteractionEnabled = true
                accessoryView = MSCellAccessory.init(type: FLAT_DETAIL_BUTTON , color: UIColor.baseColor)
                accessoryView?.addGestureRecognizer(UITapGestureRecognizer(target: viewController(), action: #selector((viewController() as! SettingViewController).showUpdateNevoAlertView)))
                selectionStyle = .none
            }
        }
        
        let typeArray:[SetingType] = [.notifications, .goal, .unit, .support]
        if typeArray.contains(type) {
            accessoryType = .disclosureIndicator
        }
    }
    
}
