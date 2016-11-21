//
//  UIView+Extension.swift
//  Nevo
//
//  Created by jinstm on 2016/10/23.
//  Copyright © 2016年 Nevo. All rights reserved.
//
//  jinstm = Quentin, :)

import Foundation

// MARK: - Find views
extension UIView {
    /// Find all views in this view's hierarchy tree, then let them do an operation
    open func allSubviews(do theOperation:(UIView) -> ()) {
        let allViews = allSubViewsByRecursion()
        for view in allViews {
            theOperation(view)
        }
    }
    
    /// Find all views in this view's hierarchy tree, include itself, that can satisfy the condition
    open func subviewsSatisfy(theCondition:(UIView) -> (Bool)) -> [UIView] {
        var resultViews:[UIView] = []
        let allViews = allSubViewsByRecursion()
        for view in allViews {
            if theCondition(view) {
                resultViews.append(view)
            }
        }
        
        return resultViews
    }
    
    /// Find all views in this view's hierarchy tree, include itself, that can satisfy the condition, then let them do an operation
    open func subviewsSatisfy(theCondition:(UIView) -> (Bool), do theOperation:(UIView) -> ()) {
        let views = subviewsSatisfy(theCondition: theCondition)
        for view in views {
            theOperation(view)
        }
    }
    
    /// Catch all views of this view's hierarchy tree, include itself
    open func allSubViewsByRecursion() -> [UIView] {
        var views:[UIView] = []
        allSubViewsByRecursion(views: &views)
        return views
    }
}

// MARK: - More api
extension UIView {
    /// Find the view's controller, if this view is not a view of one controller, then go up by its responder-chain
    open func parentController() -> UIViewController? {
        var responder = next
        while (responder != nil) {
            if responder!.isKind(of: UIViewController.classForCoder()) {
                return (responder as! UIViewController)
            }
            responder = responder?.next
        }
        return nil
    }
}

// MARK: - Private Function
extension UIView {
    /// Catch all views of this view's hierarchy tree, include itself
    fileprivate func allSubViewsByRecursion(views:inout [UIView]) {
        views.append(self)
        if subviews.count == 0 {
            return
        }
        for subview in subviews {
            subview.allSubViewsByRecursion(views: &views)
        }
    }
}
