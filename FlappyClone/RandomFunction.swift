//
//  RandomFunction.swift
//  FlappyClone
//
//  Created by H on 6/29/16.
//  Copyright © 2016 H. All rights reserved.
//

import Foundation
import CoreGraphics

// create a random 32-bit number between -200 and 200

public extension CGFloat {
    
    // want this func to return CGFloat
    
    public static func random() -> CGFloat {
        
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    public static func random(min min : CGFloat, max: CGFloat) -> CGFloat {
        
        return CGFloat.random() * (max - min) + min // avoid negative value 
    }
    
}