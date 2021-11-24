//
//  thresholds.swift
//  ankle-proctor-swift
//
//  Created by 孙钰仁 on 2021/11/24.
//

import Foundation

class Thresholds: NSObject {
    // Set default thresholds
    public static var leftPressureMax = 1000
    public static var rightPressureMax = 1000
    public static var leftFlexMax = 1000
    public static var rightFlexMax = 1000
    public static var leftFlexMin = -1000
    public static var rightFlexMin = -1000

    func setLeftPressureMax(threshold: Int){
        Thresholds.leftPressureMax = threshold
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

