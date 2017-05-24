//
//  MRProgressOverlayView.swift
//  Nevo
//
//  Created by Quentin on 27/10/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import Foundation
import MRProgress

extension MRProgressOverlayView {
    @objc class func MEDShowOverlayAddedTo(view:UIView, title:NSString, mode:MRProgressOverlayViewMode, animated:Bool) -> UIView {
        let newView = MRProgressOverlayView.MEDShowOverlayAddedTo(view: view, title: title, mode: mode, animated: animated)
        return newView
    }
    
    override open class func initialize() {
        super.initialize()
        
        if (self == MRProgressOverlayView.classForCoder()) {
            let newMethod:Method = class_getClassMethod(self, #selector(MEDShowOverlayAddedTo(view:title:mode:animated:)))
            /*+ (instancetype)showOverlayAddedTo:(UIView *)view title:(NSString *)title mode:(MRProgressOverlayViewMode)mode animated:(BOOL)animated */
            
            let oldSEL = #selector(MRProgressOverlayView.showOverlayAdded(to:title:mode:animated:))
            let oldMethod:Method = class_getClassMethod(self, oldSEL)
            method_exchangeImplementations(newMethod, oldMethod)
        }
    }
}
