//
//  PPDrawableArrow.swift
//  drawArch
//
//  Created by Abhijit KG on 30/08/17.
//  Copyright © 2017 PhonePe. All rights reserved.
//

import Foundation
import UIKit

public enum PPCurveDirection {
    case up
    case down
    case left
    case right
    
    var firstAngle: CGFloat {
        switch self {
        case .up:
            return -45
        case .down:
            return 45
        case .left:
            return 135
        case .right:
            return 45
        }
    }
    
    var secondAngle: CGFloat {
        switch self {
        case .up:
            return 135
        case .down:
            return -135
        case .left:
            return -135
        case .right:
            return -45
        }
    }
    
    var firstFactor: CGFloat {
        switch self {
        case .up:
            return 1
        case .down:
            return 1
        case .left:
            return -1
        case .right:
            return 1
        }
    }
    
    var secondFactor: CGFloat {
        switch self {
        case .up:
            return -1
        case .down:
            return -1
        case .left:
            return -1
        case .right:
            return 1
        }
    }
}

final public class PPDrawableArrow {
    
    public static func drawCurve(inView: UIView,
                                 from: CGPoint,
                                 to: CGPoint,
                                 curveDirection: PPCurveDirection,
                                 animated: Bool = true,
                                 duration:TimeInterval = 0.25,
                                 lineColor: UIColor,
                                 lineWidth: CGFloat = 1.0,
                                 completion:((_ hasFinished: Bool, _ error: String?) -> Void)? = nil) -> CALayer? {
        
        if from == to {
            completion?(false, "from and to points cant be same")
            return nil
        }
        
        if PPDrawableArrow.isValidInputs(from: from, to: to, curveDirection: curveDirection) == false {
            completion?(false, "wrong arrow direction for the given points")
            return nil
        }
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: from.x, y: from.y))
        
        let controlPonint = PPDrawableArrow.getControlPoint(fromPoint: from, toPoint: to, direction: curveDirection)
        
        
        path.addQuadCurve(to: CGPoint(x: to.x, y: to.y), controlPoint: controlPonint)
        
        let arrowLenght:CGFloat = 8.0
        
        let firstEndOfArrow = CGPoint(x: to.x - arrowLenght * curveDirection.firstFactor , y: to.y - (tan(curveDirection.firstAngle * (.pi / 180)) * arrowLenght))
        
        path.addLine(to: firstEndOfArrow)
        
        path.move(to: CGPoint(x: to.x, y: to.y))
        
        let secondEndOfArrow = CGPoint(x: to.x - arrowLenght * curveDirection.secondFactor, y: to.y - (tan(curveDirection.secondAngle * (.pi / 180)) * arrowLenght))
        path.addLine(to: secondEndOfArrow)
        
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.strokeColor = UIColor.clear.cgColor
        layer.lineWidth = lineWidth
        layer.fillColor = nil
        layer.lineJoin = kCALineCapSquare
        inView.layer.addSublayer(layer)
        
        CATransaction.begin()
        // Add the animation to the curve
        CATransaction.setCompletionBlock {
            completion?(true, nil)
        }
        
        if animated {
            let animate = CABasicAnimation(keyPath: "strokeEnd")
            animate.repeatCount = 1.0
            
            // Animate from the full stroke being drawn to none of the stroke being drawn
            animate.fromValue = NSNumber(value: 0.0)
            animate.toValue = NSNumber(value: 1.0)
            animate.duration = duration
            
            animate.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            
            layer.strokeColor = lineColor.cgColor
            
            
            layer.add(animate, forKey: "drawAnimation")
        }
        
        CATransaction.commit()
        
        return layer
    }
    
    private static func getControlPoint(fromPoint: CGPoint, toPoint: CGPoint, direction: PPCurveDirection) -> CGPoint {
        switch direction {
        case .right, .left:
            return CGPoint(x: fromPoint.x, y: toPoint.y)
        case .up,.down:
            return CGPoint(x: toPoint.x , y: fromPoint.y)
        }
    }
    
    private static func isValidInputs(from: CGPoint, to: CGPoint, curveDirection: PPCurveDirection) -> Bool {
        if (from.y > to.y) && curveDirection == .down {
            return false
        }
        
        if (from.x > to.x) && curveDirection == .right {
            return false
        }
        
        if (to.y > from.y) && curveDirection == .up {
            return false
        }
        
        if (to.x > from.x) && curveDirection == .left {
            return false
        }
        
        return true
    }
    
}
