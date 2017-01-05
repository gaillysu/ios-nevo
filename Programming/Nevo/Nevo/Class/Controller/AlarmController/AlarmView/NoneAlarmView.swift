//
//  NoneAlarmView.swift
//  Nevo
//
//  Created by Quentin on 4/1/17.
//  Copyright © 2017年 Nevo. All rights reserved.
//

import UIKit
import SnapKit

class NoneAlarmView: UIView {
    
    static func factory() -> UIView {
        let view = NoneAlarmView(frame: UIScreen.main.bounds)
        view.viewDefaultColorful()
        
        let label = UILabel()
        view.addSubview(label)
        label.viewDefaultColorful()
        
        label.snp.makeConstraints { (v) in
            v.leading.equalTo(30)
            v.trailing.equalTo(-30)
            v.height.equalTo(80)
            v.centerX.equalToSuperview()
            v.centerY.equalToSuperview()
        }
        
        label.font = UIFont(name: "Raleway", size: 16)
        label.textAlignment = .center
        label.numberOfLines = Int.max
        label.lineBreakMode = .byWordWrapping
        
        label.text = NSLocalizedString("none_alarm", comment: "")
        
        return view
    }
}
