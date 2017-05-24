//
//  NotiColorEditableCell.swift
//  Nevo
//
//  Created by Quentin on 6/12/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class NotiColorEditableCell: UITableViewCell {

    var model: MEDNotificationColor?
    
    @IBOutlet weak var dotImageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.viewDefaultColorful()
        textField.delegate = self
    }
}

extension NotiColorEditableCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            model?.name = text
        }
    }
}

