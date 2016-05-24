//
//  PointAnnotation.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 4/21/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import DynamicColor

class PointAnnotation: MKPointAnnotation {
    let point : Point
    
    init?(point : Point)
    {
        self.point = point
        if let latitude = point.latitude as? CLLocationDegrees
        {
            if let longitude = point.longitude as? CLLocationDegrees
            {
                super.init()
                self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                return
            }
        }
        return nil
    }
}

@IBDesignable
class PointAnnotationView : MKAnnotationView
{
    private static let lineWidthPercent : CGFloat = 0.05
    private static let pinPercent : CGFloat = 0.1
    private static let crossWidthPercent : CGFloat = 0.2
    private static let textPercent : CGFloat = 0.5
    
    private static let militaryColor : UIColor = UIColor(hex: 0xFF1123)
    private static let civilColor : UIColor = UIColor(hex: 0x00C2FE)
    private static let inactiveColor : UIColor = UIColor(hex: 0xC2C2C2)
    private static let selectedColor : UIColor = UIColor(hex: 0x38FA3C)
    
    
    override var annotation: MKAnnotation? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override var selected: Bool {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    class func view(withAnnotation annotaion: PointAnnotation?) -> PointAnnotationView?
    {
        if let annotaion = annotaion
        {
            let view = NSBundle.mainBundle().loadNibNamed("PointAnnotationView", owner: nil, options: nil).first as? PointAnnotationView
            view?.annotation = annotaion
            return view
        }
        return nil
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        let context = UIGraphicsGetCurrentContext()
        
        let point = (self.annotation as? PointAnnotation)?.point
        
        let serviced = point?.isServiced() ?? false
        let active = point?.active?.boolValue ?? false
        let military = PointBelongs(rawValue: point?.belongs?.integerValue ?? -1)?.isMilitary() ?? false
        
        let pointColor : UIColor
        if self.selected
        {
            pointColor = PointAnnotationView.selectedColor
        }
        else if active
        {
            if military
            {
                pointColor = PointAnnotationView.militaryColor
            }
            else
            {
                pointColor = PointAnnotationView.civilColor
            }
        }
        else
        {
            pointColor = PointAnnotationView.inactiveColor
        }
        
        let darkerColor = pointColor.darkerColor()
        
        CGContextSetStrokeColorWithColor(context, darkerColor.CGColor)
        CGContextSetLineWidth(context, ceil(max(rect.width, rect.height) * PointAnnotationView.lineWidthPercent))
        
        if serviced
        {
            CGContextSetFillColorWithColor(context, darkerColor.CGColor)
            let crossWidth = ceil(max(rect.width, rect.height) * PointAnnotationView.crossWidthPercent)
            let path = UIBezierPath()
            path.moveToPoint(CGPoint(x: ceil((rect.width - crossWidth) * 0.5), y: 0.0))
            path.addLineToPoint(CGPoint(x: ceil((rect.width + crossWidth) * 0.5), y: 0.0))
            path.addLineToPoint(CGPoint(x: ceil((rect.width + crossWidth) * 0.5), y: ceil((rect.height - crossWidth) * 0.5)))
            path.addLineToPoint(CGPoint(x: rect.width, y: ceil((rect.height - crossWidth) * 0.5)))
            path.addLineToPoint(CGPoint(x: rect.width, y: ceil((rect.height + crossWidth) * 0.5)))
            path.addLineToPoint(CGPoint(x: ceil((rect.width + crossWidth) * 0.5), y: ceil((rect.height + crossWidth) * 0.5)))
            path.addLineToPoint(CGPoint(x: ceil((rect.width + crossWidth) * 0.5), y: rect.height))
            path.addLineToPoint(CGPoint(x: ceil((rect.width - crossWidth) * 0.5), y: rect.height))
            path.addLineToPoint(CGPoint(x: ceil((rect.width - crossWidth) * 0.5), y: ceil((rect.height + crossWidth) * 0.5)))
            path.addLineToPoint(CGPoint(x: 0.0, y: ceil((rect.height + crossWidth) * 0.5)))
            path.addLineToPoint(CGPoint(x: 0.0, y: ceil((rect.height - crossWidth) * 0.5)))
            path.addLineToPoint(CGPoint(x: ceil((rect.width - crossWidth) * 0.5), y: ceil((rect.height - crossWidth) * 0.5)))
            path.closePath()
            CGContextAddPath(context, path.CGPath)
            CGContextFillPath(context)
            CGContextBeginPath(context)
            CGContextAddPath(context, path.CGPath)
            CGContextDrawPath(context, .Stroke)
        }
        
        CGContextSetFillColorWithColor(context, pointColor.CGColor)
        
        let horizontalOffset = ceil(rect.width * PointAnnotationView.pinPercent)
        let verticalOffset = ceil(rect.height * PointAnnotationView.pinPercent)
        
        let pointRect = CGRect(
            x: horizontalOffset,
            y: verticalOffset,
            width: ceil(rect.width - 2.0 * horizontalOffset),
            height: ceil(rect.height - 2.0 * verticalOffset))
        CGContextFillEllipseInRect(context, pointRect)
        CGContextBeginPath(context)
        CGContextAddEllipseInRect(context, pointRect)
        CGContextDrawPath(context, .Stroke)
        
        if PointType.Heliport.rawValue == point?.type
        {
            let textMaxWidth = ceil(rect.width * self.dynamicType.textPercent)
            let textMaxHeight = ceil(rect.height * self.dynamicType.textPercent)
            let text : NSString = "H"
            let textRect = text.boundingRectWithSize(CGSize(width: textMaxWidth, height: textMaxHeight), options: NSStringDrawingOptions(), attributes: nil, context: nil)
            let textSize = CGSize(width: ceil(textRect.width), height: ceil(textRect.height))
            text.drawInRect(CGRect(x: ceil((rect.width - textSize.width) * 0.5), y: ceil((rect.height - textSize.height) * 0.5), width: textSize.width, height: textSize.height), withAttributes: nil)
        }
        
    }
}