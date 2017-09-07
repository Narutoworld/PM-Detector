//
//  ArrowView.swift
//  Project
//
//  Created by Billy Cai on 2017-07-28.
//  Copyright © 2017 Billy Cai. All rights reserved.
//

import UIKit

class ArrowView: UIView {

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        let arrowPath = UIBezierPath.bezierPathWithArrowFromPoint(startPoint: CGPoint(x:bounds.size.width/2,y:bounds.size.height/3), endPoint: CGPoint(x:bounds.size.width/2, y:bounds.size.height/3*2), tailWidth: 8, headWidth: 24, headLength: 18)

        let fillColor = UIColor(red: 0.00, green: 0.59, blue: 1.0, alpha: 1.0)
        fillColor.setFill()
        arrowPath.fill()
    }
}

extension UIBezierPath {
    
    class func getAxisAlignedArrowPoints( points: inout Array<CGPoint>, forLength: CGFloat, tailWidth: CGFloat, headWidth: CGFloat, headLength: CGFloat ) {
        
        let tailLength = forLength - headLength
        points.append(CGPoint(x:0, y:tailWidth/2))
        points.append(CGPoint(x:tailLength, y:tailWidth/2))
        points.append(CGPoint(x:tailLength, y:headWidth/2))
        points.append(CGPoint(x:forLength, y:0))
        points.append(CGPoint(x:tailLength, y:-headWidth/2))
        points.append(CGPoint(x:tailLength, y:-tailWidth/2))
        points.append(CGPoint(x:0, y:-tailWidth/2))
        
    }
    
    
    class func transformForStartPoint(startPoint: CGPoint, endPoint: CGPoint, length: CGFloat) -> CGAffineTransform{
        let cosine: CGFloat = (endPoint.x - startPoint.x)/length
        let sine: CGFloat = (endPoint.y - startPoint.y)/length
        
        return CGAffineTransform(a: cosine, b: sine, c: -sine, d: cosine, tx: startPoint.x, ty: startPoint.y)
    }
    
    
    class func bezierPathWithArrowFromPoint(startPoint:CGPoint, endPoint: CGPoint, tailWidth: CGFloat, headWidth: CGFloat, headLength: CGFloat) -> UIBezierPath {
        
        let xdiff: Float = Float(endPoint.x) - Float(startPoint.x)
        let ydiff: Float = Float(endPoint.y) - Float(startPoint.y)
        let length = hypotf(xdiff, ydiff)
        
        var points = [CGPoint]()
        self.getAxisAlignedArrowPoints(points: &points, forLength: CGFloat(length), tailWidth: tailWidth, headWidth: headWidth, headLength: headLength)
        
        let transform: CGAffineTransform = self.transformForStartPoint(startPoint: startPoint, endPoint: endPoint, length:  CGFloat(length))
        
        let cgPath: CGMutablePath = CGMutablePath()
        cgPath.addLines(between: points, transform: transform)
        cgPath.closeSubpath()
        
        let uiPath: UIBezierPath = UIBezierPath(cgPath: cgPath)
        return uiPath
    }
}
