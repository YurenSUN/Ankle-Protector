//
//  thresholds.swift
//  ankle-proctor-swift
//
//  Created by 孙钰仁 on 2021/11/24.
//

import Foundation

class Thresholds: NSObject {
    // Set default thresholds
    public var leftPressureMax = 1000
    public var rightPressureMax = 1000
    public var leftFlexMax = 1000
    public var rightFlexMax = 1000
    public var leftFlexMin = -1000
    public var rightFlexMin = -1000

    func setLeftPressureMax(threshold: Int){
        self.leftPressureMax = Int(threshold)
    }

    func setRightPressureMax(threshold: Int){
        Thresholds.rightPressureMax = threshold
    }
    
    func setRightFlexMax(threshold: Int){
        Thresholds.rightFlexMax = threshold
    }
    
    func setLeftFlexMax(threshold: Int){
        Thresholds.leftFlexMax = threshold
    }
    
    func setRightFlexMin(threshold: Int){
        Thresholds.rightFlexMin = threshold
    }
    
    func setLeftFlexMin(threshold: Int){
        Thresholds.leftFlexMin = threshold
    }
    

}

