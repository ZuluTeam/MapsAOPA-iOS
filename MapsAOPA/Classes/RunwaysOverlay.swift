//
//  RunwaysOverlay.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 2/23/17.
//  Copyright © 2017 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import MapKit

class RunwaysOverlay : NSObject, MKOverlay {
    let pointDetailsViewModel : PointDetailsViewModel
    
    var coordinate: CLLocationCoordinate2D {
        return pointDetailsViewModel.location
    }
    
    
    public var boundingMapRect: MKMapRect {
        let coordinates : (minX: Double, minY: Double, maxX: Double, maxY: Double) =
            pointDetailsViewModel.runways.reduce((Double.infinity, Double.infinity, -Double.infinity, -Double.infinity)) { (result, runway) -> (Double, Double, Double, Double) in
                if let thresholds = runway.thresholds {
                    let threshold0X = thresholds.longitude1
                    let threshold0Y = thresholds.latitude1
                    let threshold1X = thresholds.longitude2
                    let threshold1Y = thresholds.latitude2
                    return (min(threshold0X, threshold1X, result.0),
                            min(threshold0Y, threshold1Y, result.1),
                            max(threshold0X, threshold1X, result.2),
                            max(threshold0Y, threshold1Y, result.3))
                }
                return result
        }
        
        let coordinateTopLeft = MKMapPointForCoordinate(CLLocationCoordinate2D(latitude: coordinates.minY, longitude: coordinates.minX))
        let coordinateBottomRight = MKMapPointForCoordinate(CLLocationCoordinate2D(latitude: coordinates.maxY, longitude: coordinates.maxX))
        
        
        return MKMapRect(origin: MKMapPoint(x:coordinateTopLeft.x, y: coordinateTopLeft.y),
                         size: MKMapSize(width: coordinateBottomRight.x - coordinateTopLeft.x,
                                         height: coordinateBottomRight.y - coordinateTopLeft.y))
    }
    

    init(pointDetailsViewModel: PointDetailsViewModel) {
        self.pointDetailsViewModel = pointDetailsViewModel
    }
}

class RunwaysOverlayRenderer : MKOverlayRenderer {
    
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        
        if let overlay = self.overlay as? RunwaysOverlay {
            for runway in overlay.pointDetailsViewModel.runways {
                if let thresholds = runway.thresholds {
                    let threshold0 = thresholds.threshold1
                    
                    let metersInDegree : Double = 111111
                    let width = Double(runway.width <= 0 ? 30 : runway.width)
                    let locationRadius = width / metersInDegree
                    let deltaThreshold0 = CLLocationCoordinate2D(latitude: threshold0.latitude + locationRadius,
                                                                 longitude: threshold0.longitude + locationRadius)
                    let mapDeltaThreshold0 = MKMapPointForCoordinate(deltaThreshold0)
                    let mapThreshold0 = MKMapPointForCoordinate(thresholds.threshold1)
                    let mapThreshold1 = MKMapPointForCoordinate(thresholds.threshold2)
                    let mapThresholds = [mapThreshold0, mapThreshold1]
                    
                    
                    let angle : Double
                    if mapThreshold0.x - mapThreshold1.x == 0 {
                        angle = .pi/2
                    } else {
                        angle = atan((mapThreshold0.y - mapThreshold1.y) / (mapThreshold0.x - mapThreshold1.x))
                    }
                    
                    let radius = mapDeltaThreshold0.distance(from: mapThreshold0) * 0.5

                    let cosLeft = cos(.pi/2 + angle)
                    let sinLeft = sin(.pi/2 + angle)
                    let cosRight = -cosLeft
                    let sinRight = -sinLeft
                    let left = MKMapPoint(x: (radius * cosLeft), y: (radius * sinLeft))
                    let right = MKMapPoint(x: (radius * cosRight), y: (radius * sinRight))
                    
                    context.saveGState()
                    let runwayColor = runway.surfaceType.color
                    context.setStrokeColor(runwayColor.darkened().cgColor)
                    context.setFillColor(runwayColor.cgColor)
                    context.setLineWidth(2.0)
                    context.beginPath()
                    context.move(to: self.point(for: mapThreshold0 + left))
                    context.addLine(to: self.point(for: mapThreshold1 + left))
                    context.addLine(to: self.point(for: mapThreshold1 + right))
                    context.addLine(to: self.point(for: mapThreshold0 + right))
                    context.addLine(to: self.point(for: mapThreshold0 + left))
                    context.fillPath()
                    context.strokePath()
                    
                    context.restoreGState()
                    
                    let screenThresholds = mapThresholds.map({ self.point(for: $0) })
                    
                    let textSize : CGFloat = 750.0
                    let textAttributes : [String:Any] = [
                        NSFontAttributeName : UIFont.systemFont(ofSize: textSize)
                    ]

                    UIGraphicsPushContext(context)
                    let titleComponents = runway.title.components(separatedBy: "/")
                    let angles = [angle + .pi/2, angle - .pi/2]
                    if titleComponents.count == 2 {
                        for (index, title) in titleComponents.enumerated() {
                            context.saveGState()
                            let titleSize = title.size(attributes: textAttributes)
                            let point = screenThresholds[index]
                            context.translateBy(x: point.x, y: point.y)
                            context.rotate(by: CGFloat(angles[index]))
                            title.draw(at: -CGPoint(x: titleSize.width * 0.5, y: titleSize.height), withAttributes: textAttributes)
                            context.restoreGState()
                        }
                    }
                    UIGraphicsPopContext()
                }
            }
        }
    }
    
    override func canDraw(_ mapRect: MKMapRect, zoomScale: MKZoomScale) -> Bool {
        return true
    }
}
