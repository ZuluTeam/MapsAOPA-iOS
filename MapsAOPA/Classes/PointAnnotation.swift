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
    let pointViewModel : PointViewModel
    
    override var coordinate: CLLocationCoordinate2D {
        get {
            return self.pointViewModel.location
        }
        set {
            self.pointViewModel.location = newValue
        }
    }
    
    init(pointViewModel : PointViewModel) {
        self.pointViewModel = pointViewModel
    }
}

@IBDesignable
class PointAnnotationView : MKAnnotationView
{
    fileprivate static let lineWidthPercent : CGFloat = 0.05
    fileprivate static let pinPercent : CGFloat = 0.1
    fileprivate static let crossWidthPercent : CGFloat = 0.2
    
    fileprivate static let militaryColor : UIColor = UIColor(hex: 0xFF1123)
    fileprivate static let civilColor : UIColor = UIColor(hex: 0x00C2FE)
    fileprivate static let inactiveColor : UIColor = UIColor(hex: 0xC2C2C2)
    fileprivate static let selectedColor : UIColor = UIColor(hex: 0x38FA3C)
    
    fileprivate static let Size : CGFloat = 20.0
    fileprivate static let textAttributes : [String:Any] = [
        NSFontAttributeName : UIFont.systemFont(ofSize: 10)
    ]
    
    
    override var annotation: MKAnnotation? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
        self.frame = CGRect(x: 0, y: 0, width: type(of: self).Size, height: type(of: self).Size)
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clear
        self.frame = CGRect(x: 0, y: 0, width: type(of: self).Size, height: type(of: self).Size)
        self.annotation = annotation
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let pointViewModel = (self.annotation as? PointAnnotation)?.pointViewModel else {
            return
        }
        
        let context = UIGraphicsGetCurrentContext()
        
        let pointColor : UIColor
        if self.isSelected {
            pointColor = PointAnnotationView.selectedColor
        }
        else if pointViewModel.isActive {
            if pointViewModel.isMilitary {
                pointColor = PointAnnotationView.militaryColor
            } else {
                pointColor = PointAnnotationView.civilColor
            }
        }
        else {
            pointColor = PointAnnotationView.inactiveColor
        }
        
        let darkerColor = pointColor.darkened()
        
        context?.setStrokeColor(darkerColor.cgColor)
        context?.setLineWidth(ceil(max(rect.width, rect.height) * PointAnnotationView.lineWidthPercent))
        
        if pointViewModel.isServiced {
            context?.setFillColor(darkerColor.cgColor)
            let crossWidth = ceil(max(rect.width, rect.height) * PointAnnotationView.crossWidthPercent)
            let path = UIBezierPath()
            path.move(to: CGPoint(x: ceil((rect.width - crossWidth) * 0.5), y: 0.0))
            path.addLine(to: CGPoint(x: ceil((rect.width + crossWidth) * 0.5), y: 0.0))
            path.addLine(to: CGPoint(x: ceil((rect.width + crossWidth) * 0.5), y: ceil((rect.height - crossWidth) * 0.5)))
            path.addLine(to: CGPoint(x: rect.width, y: ceil((rect.height - crossWidth) * 0.5)))
            path.addLine(to: CGPoint(x: rect.width, y: ceil((rect.height + crossWidth) * 0.5)))
            path.addLine(to: CGPoint(x: ceil((rect.width + crossWidth) * 0.5), y: ceil((rect.height + crossWidth) * 0.5)))
            path.addLine(to: CGPoint(x: ceil((rect.width + crossWidth) * 0.5), y: rect.height))
            path.addLine(to: CGPoint(x: ceil((rect.width - crossWidth) * 0.5), y: rect.height))
            path.addLine(to: CGPoint(x: ceil((rect.width - crossWidth) * 0.5), y: ceil((rect.height + crossWidth) * 0.5)))
            path.addLine(to: CGPoint(x: 0.0, y: ceil((rect.height + crossWidth) * 0.5)))
            path.addLine(to: CGPoint(x: 0.0, y: ceil((rect.height - crossWidth) * 0.5)))
            path.addLine(to: CGPoint(x: ceil((rect.width - crossWidth) * 0.5), y: ceil((rect.height - crossWidth) * 0.5)))
            path.close()
            context?.addPath(path.cgPath)
            context?.fillPath()
            context?.beginPath()
            context?.addPath(path.cgPath)
            context?.drawPath(using: .stroke)
        }
        
        context?.setFillColor(pointColor.cgColor)
        
        let horizontalOffset = ceil(rect.width * PointAnnotationView.pinPercent)
        let verticalOffset = ceil(rect.height * PointAnnotationView.pinPercent)
        
        let pointRect = CGRect(
            x: horizontalOffset,
            y: verticalOffset,
            width: ceil(rect.width - 2.0 * horizontalOffset),
            height: ceil(rect.height - 2.0 * verticalOffset))
        context?.fillEllipse(in: pointRect)
        context?.beginPath()
        context?.addEllipse(in: pointRect)
        context?.drawPath(using: .stroke)
        
        if PointType.heliport == pointViewModel.pointType
        {
            let text = "H"
            let textSize = text.size(attributes: PointAnnotationView.textAttributes)
            text.draw(at: CGPoint(x: (rect.width - textSize.width) * 0.5, y: (rect.height - textSize.height) * 0.5), withAttributes: PointAnnotationView.textAttributes)
        }
        
    }
}
