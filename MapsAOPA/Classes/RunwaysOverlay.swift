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
                if runway.thresholds.count == 2 {
                    let threshold0X = runway.thresholds[0].longitude
                    let threshold0Y = runway.thresholds[0].latitude
                    let threshold1X = runway.thresholds[1].longitude
                    let threshold1Y = runway.thresholds[1].latitude
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
                if runway.thresholds.count == 2 {
                    let threshold0 = runway.thresholds[0]
                    
                    let metersInDegree : Double = 111111
                    let width = Double(runway.width <= 0 ? 30 : runway.width)
                    let locationRadius = width / metersInDegree
                    let deltaThreshold0 = CLLocationCoordinate2D(latitude: threshold0.latitude + locationRadius,
                                                                 longitude: threshold0.longitude + locationRadius)
                    let mapDeltaThreshold0 = MKMapPointForCoordinate(deltaThreshold0)
                    let mapThresholds = runway.thresholds.map({ MKMapPointForCoordinate($0) })
                    let mapThreshold0 = mapThresholds[0]
                    let mapThreshold1 = mapThresholds[1]
                    
                    let angle : Double
                    if mapThreshold0.x - mapThreshold1.x == 0 {
                        angle = M_PI_2
                    } else {
                        angle = atan((mapThreshold0.y - mapThreshold1.y) / (mapThreshold0.x - mapThreshold1.x))
                    }
                    
                    let radius = mapDeltaThreshold0.distance(from: mapThreshold0) * 0.5

                    let cosLeft = cos(M_PI_2 + angle)
                    let sinLeft = sin(M_PI_2 + angle)
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
                    
                    let textSize : CGFloat = 1000.0
                    let textAttributes : [String:Any] = [
                        NSFontAttributeName : UIFont.systemFont(ofSize: textSize)
                    ]

                    UIGraphicsPushContext(context)
                    let titleComponents = runway.title.components(separatedBy: "/")
                    let angles = [angle + M_PI_2, angle - M_PI_2]
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
