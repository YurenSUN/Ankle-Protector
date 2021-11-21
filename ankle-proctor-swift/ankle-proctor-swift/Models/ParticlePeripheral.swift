//
//  ParticlePeripheral.swift
//  ankle-proctor-swift
//
//  Created by Yuren on 2021/11/21.
//
//  Ref for bluetooth: https://www.freecodecamp.org/news/ultimate-how-to-bluetooth-swift-with-hardware-in-20-minutes/

import Foundation
import UIKit
    import CoreBluetooth

    class ParticlePeripheral: NSObject {
        // In arduino, set service UUID to 180C and char UUID to 2A56
        public static let particleServiceUUID     = CBUUID.init(string: "180C")
        public static let sensorCharacteristicUUID   = CBUUID.init(string: "2A56")

    }

