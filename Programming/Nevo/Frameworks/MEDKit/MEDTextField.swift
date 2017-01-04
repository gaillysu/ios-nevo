//
//  MEDTextField.swift
//  Nevo
//
//  Created by Quentin on 3/1/17.
//  Copyright © 2017年 Nevo. All rights reserved.
//

import UIKit

/// 用途：
/// 当在 Cell 里使用 TextField 时，如果选择的是“无边框”模式，中文会在编辑时有奇怪的偏移，这儿是奇怪的解决办法，感谢 Google。
class MEDTextField: AutocompleteField {
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 0, dy: 7)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 0, dy: 7)
    }
}
