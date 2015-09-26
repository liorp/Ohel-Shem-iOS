//
//  UIExtensions.swift
//  Ohel Shem
//
//  Created by Lior Pollak on 19/09/2015.
//  Copyright © 2015 Lior Pollak. All rights reserved.
//

import Foundation
import UIKit

extension UIMotionEffect {
    class func twoAxesShift(strength: Float) -> UIMotionEffect {
        // internal method that creates motion effect
        func motion(type: UIInterpolatingMotionEffectType) -> UIInterpolatingMotionEffect {
            let keyPath = type == .TiltAlongHorizontalAxis ? "center.x" : "center.y"
            let motion = UIInterpolatingMotionEffect(keyPath: keyPath, type: type)
            motion.minimumRelativeValue = -strength
            motion.maximumRelativeValue = strength
            return motion
        }

        // group of motion effects
        let group = UIMotionEffectGroup()
        group.motionEffects = [
            motion(.TiltAlongHorizontalAxis),
            motion(.TiltAlongVerticalAxis)
        ]
        return group
    }
}

func backgroundThread(delay: Double = 0.0, background: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
    dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
        if(background != nil){ background!(); }

        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
        dispatch_after(popTime, dispatch_get_main_queue()) {
            if(completion != nil){ completion!(); }
        }
    }
}