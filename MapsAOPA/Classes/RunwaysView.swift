//
//  RunwaysView.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 6/2/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import UIKit
import CoreLocation
import CoreText

@IBDesignable
class RunwaysView: UIView {
    
    var isHeliport : Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var runways : [RunwayViewModel] = [] {
        didSet {
            self.setNeedsDisplay()
        }
    }

    private static let offset : CGFloat = 10.0
    private static let textAttributes : [String:Any] = [
        NSFontAttributeName : UIFont.boldSystemFont(ofSize: 12)
    ]
    
    override func draw(_ rect: CGRect) {
        if isHeliport {
            self.drawHeliport(in: rect)
            return
        }
        
        if runways.isEmpty {
            return
        }
        let canvasSize = CGSize(width: rect.size.width - 2.0 * RunwaysView.offset, height: rect.size.height - 2.0 * RunwaysView.offset)
        if canvasSize.width <= 0 || canvasSize.height <= 0 {
            return
        }
        
        let drawingParameters : (minX: CGFloat, minY: CGFloat, maxX: CGFloat, maxY: CGFloat) =
            self.runways.reduce((CGFloat.infinity, CGFloat.infinity, -CGFloat.infinity, -CGFloat.infinity)) { (result, runway) -> (CGFloat, CGFloat, CGFloat, CGFloat) in
                if runway.thresholds.count == 2 {
                    let threshold0 = CGPoint(x: runway.thresholds[0].longitude, y: 90.0 - runway.thresholds[0].latitude)
                    let threshold1 = CGPoint(x: runway.thresholds[1].longitude, y: 90.0 - runway.thresholds[1].latitude)
                    return (min(threshold0.x, threshold1.x, result.0),
                            min(threshold0.y, threshold1.y, result.1),
                            max(threshold0.x, threshold1.x, result.2),
                            max(threshold0.y, threshold1.y, result.3))
                }
                return result
            }
        let drawingSize = CGSize(width: drawingParameters.maxX - drawingParameters.minX,
                                 height: drawingParameters.maxY - drawingParameters.minY)
        var scale = canvasSize.width / drawingSize.width
        if (drawingSize.height * scale) > canvasSize.height {
            scale = canvasSize.height / drawingSize.height
        }
        if scale == 0 {
            return
        }
        
        let leftOffset = RunwaysView.offset + round((canvasSize.width - (drawingSize.width * scale)) * 0.5)
        let topOffset = RunwaysView.offset + round((canvasSize.height - (drawingSize.height * scale)) * 0.5)
        
        let context = UIGraphicsGetCurrentContext()
        
        for runway in self.runways {
            if runway.thresholds.count == 2 {
                let thresholds : [(point: CGPoint, location: CLLocation)] = runway.thresholds.map({
                    (CGPoint(x: $0.longitude, y: 90.0 - $0.latitude),
                     CLLocation(latitude: $0.latitude, longitude: $0.longitude)) })
                let threshold0 = thresholds[0].point
                let threshold1 = thresholds[1].point
                
                let screenThresholds = thresholds.map({
                    CGPoint(
                        x: (leftOffset + ($0.point.x - drawingParameters.minX) * scale),
                        y: (topOffset + ($0.point.y - drawingParameters.minY) * scale))
                })
                let screenThreshold0 = CGPoint(
                    x: (leftOffset + (threshold0.x - drawingParameters.minX) * scale),
                    y: (topOffset + (threshold0.y - drawingParameters.minY) * scale))
                let screenThreshold1 = CGPoint(
                    x: (leftOffset + (threshold1.x - drawingParameters.minX) * scale),
                    y: (topOffset + (threshold1.y - drawingParameters.minY) * scale))
                
                
                let distanceMeters = CGFloat(thresholds[0].location.distance(from: thresholds[1].location))
                let screenDistance = screenThreshold0.distance(from: screenThreshold1)
                
                if distanceMeters <= 0 {
                    continue
                }
                
                let distanceScale = screenDistance / distanceMeters
                let width = runway.width <= 0 ? 30 : runway.width
                let radius = CGFloat(width) * distanceScale * 0.5
                
                
                let angle : CGFloat
                if screenThreshold0.x - screenThreshold1.x == 0 {
                    angle = CGFloat(M_PI_2)
                } else {
                    angle = atan((screenThreshold0.y - screenThreshold1.y) / (screenThreshold0.x - screenThreshold1.x))
                }
                
                let cosLeft = cos(CGFloat(M_PI_2) + angle)
                let sinLeft = sin(CGFloat(M_PI_2) + angle)
                let cosRight = -cosLeft
                let sinRight = -sinLeft
                let left = CGPoint(x: (radius * cosLeft), y: (radius * sinLeft))
                let right = CGPoint(x: (radius * cosRight), y: (radius * sinRight))
                
                context?.saveGState()
                let runwayColor = runway.surfaceType.color
                context?.setStrokeColor(runwayColor.darkened().cgColor)
                context?.setFillColor(runwayColor.cgColor)
                
                let path = UIBezierPath()
                path.move(to: screenThreshold0 + left)
                path.addLine(to: screenThreshold1 + left)
                path.addLine(to: screenThreshold1 + right)
                path.addLine(to: screenThreshold0 + right)
                path.close()
                path.lineWidth = 1.0
                path.fill()
                path.stroke()
                
                context?.restoreGState()
                
                let titleComponents = runway.title.components(separatedBy: "/")
                let angles = [angle + CGFloat(M_PI_2), angle - CGFloat(M_PI_2)]
                if titleComponents.count == 2 {
                    for (index, title) in titleComponents.enumerated() {
                        context?.saveGState()
                        let titleSize = title.size(attributes: RunwaysView.textAttributes)
                        let point = screenThresholds[index]
                        context?.translateBy(x: point.x, y: point.y)
                        context?.rotate(by: angles[index])
                        title.draw(at: -CGPoint(x: titleSize.width * 0.5, y: titleSize.height * 0.5), withAttributes: RunwaysView.textAttributes)
                        context?.restoreGState()
                    }
                }
            }
        }
    }
    
    private func drawHeliport(in rect: CGRect) {
        
        let textHeightRadiusPercent : CGFloat = 0.8
        
        let context = UIGraphicsGetCurrentContext()
        
        let radius = min(rect.width - RunwaysView.offset * 4.0, rect.height - RunwaysView.offset * 4.0)
        
        let ellipseRect = CGRect(x: (rect.width - radius) * 0.5, y: (rect.height - radius) * 0.5,
                                 width: radius, height: radius)
        context?.setStrokeColor(UIColor.black.cgColor)
        context?.setLineWidth(8.0)
        context?.strokeEllipse(in: ellipseRect)
        
        let textAttributes : ((CGFloat)->[String:Any]) = { fontSize in
            return [ NSFontAttributeName : UIFont.boldSystemFont(ofSize: fontSize) ]
        }
        
        var fontSize : CGFloat = 12
        let text = "H"
        let originalTextSize = text.size(attributes: textAttributes(fontSize))
        let textHeight = radius * textHeightRadiusPercent
        let textScale : CGFloat = textHeight / originalTextSize.height
        fontSize = fontSize * textScale
        let attributes = textAttributes(fontSize)
        let textSize = text.size(attributes: attributes)
        text.draw(at: CGPoint(x: (rect.width - textSize.width) * 0.5, y: (rect.height - textSize.height) * 0.5), withAttributes: attributes)
        
    }

}
