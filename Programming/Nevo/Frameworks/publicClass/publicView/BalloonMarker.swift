//
//  BalloonMarker.swift
//  ChartsDemo
//
//  Created by Daniel Cohen Gindi on 19/3/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import UIKit
import Charts

enum ChartMarkerType:Int{
    case stepsChartType = 0,
    sleepChartType = 1
}

open class BalloonMarker: ChartMarker
{
    var markerType:ChartMarkerType?
    open var color: UIColor?
    open var arrowSize = CGSize(width: 15, height: 11)
    open var font: UIFont?
    open var insets = UIEdgeInsets()
    open var minimumSize = CGSize()
    
    fileprivate var labelns: String?
    fileprivate var _labelSize: CGSize = CGSize()
    fileprivate var _size: CGSize = CGSize()
    fileprivate var _paragraphStyle: NSMutableParagraphStyle?
    fileprivate var _drawAttributes = [String : AnyObject]()
    
    public init(color: UIColor, font: UIFont, insets: UIEdgeInsets)
    {
        super.init()
        
        self.color = color
        self.font = font
        self.insets = insets
        
        _paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
        _paragraphStyle?.alignment = .center
    }
    
    open override var size: CGSize { return _size; }

    open override func draw(context: CGContext?, point: CGPoint) {
        if (labelns == nil)
        {
            return
        }

        var rect = CGRect(origin: point, size: _size)
        rect.origin.x -= _size.width / 2.0
        rect.origin.y -= _size.height

        context?.saveGState()

        context?.setFillColor((color?.cgColor)!)
        context?.beginPath()
        context?.move(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
        context?.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y))
        context?.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height - arrowSize.height))
        context?.addLine(to: CGPoint(x: rect.origin.x + (rect.size.width + arrowSize.width) / 2.0, y: rect.origin.y + rect.size.height - arrowSize.height))
        context?.addLine(to: CGPoint(x: rect.origin.x + rect.size.width / 2.0, y: rect.origin.y + rect.size.height))
        context?.addLine(to: CGPoint(x: rect.origin.x + (rect.size.width - arrowSize.width) / 2.0, y: rect.origin.y + rect.size.height - arrowSize.height))
        context?.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height - arrowSize.height))
        context?.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
        context?.fillPath()

        rect.origin.y += self.insets.top
        rect.size.height -= self.insets.top + self.insets.bottom

        UIGraphicsPushContext(context!)

        labelns?.draw(in: rect, withAttributes: _drawAttributes)

        UIGraphicsPopContext()

        context?.restoreGState()
    }
    
    open override func refreshContent(entry: ChartDataEntry, highlight: ChartHighlight)
    {
        let label = entry.value.description
        if markerType == .stepsChartType {
            labelns = String(format: "%d", label.toInt())
        }else{
            labelns = String(format: "%@", AppTheme.timerFormatValue(value: label.toDouble()))
        }
        
        _drawAttributes.removeAll()
        _drawAttributes[NSFontAttributeName] = UIFont(name: "Raleway", size: 10)!
        _drawAttributes[NSParagraphStyleAttributeName] = _paragraphStyle
        _drawAttributes[NSForegroundColorAttributeName] = UIColor.white
        
        _labelSize = labelns?.size(attributes: _drawAttributes) ?? CGSize.zero
        _size.width = _labelSize.width + self.insets.left + self.insets.right
        _size.height = _labelSize.height + self.insets.top + self.insets.bottom
        _size.width = max(minimumSize.width, _size.width)
        _size.height = max(minimumSize.height, _size.height)
    }
}
