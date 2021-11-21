//
//  ViewController.swift
//  ankle-proctor-swift
//
//  Created by Yuren Sun on 2021/11/21.
//
//  Ref for bluetooth: https://www.freecodecamp.org/news/ultimate-how-to-bluetooth-swift-with-hardware-in-20-minutes/
//  and https://developer.apple.com/documentation/corebluetooth/transferring_data_between_bluetooth_low_energy_devices

import UIKit
import CoreBluetooth
import os

class ViewController: UIViewController, CBPeripheralDelegate, CBCentralManagerDelegate {
    // Properties for bluetooth
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    private var sensorChar: CBCharacteristic?
    
    // Fields
    private var isScanning = false
    
    // Show the sensor data
    // Arduino data
    @IBOutlet weak var leftFlexData: UILabel!
    @IBOutlet weak var RightFlexData: UILabel!
    @IBOutlet weak var leftForceData: UILabel!
    @IBOutlet weak var rightForceData: UILabel!
    @IBOutlet weak var changeScanBtn: UIButton!
    
    
    /*
     * updates when the bluetooth peripheral is switched on or off,
     * start scanning here.
     */
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central state update")
        if central.state != .poweredOn {
            print("Central is not powered on")
        } else {
            print("Central scanning for", ParticlePeripheral.particleServiceUUID);
            centralManager.scanForPeripherals(withServices: [ParticlePeripheral.particleServiceUUID],
                                              options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }
    
    
    /*
     * Handle the result of scan in didDiscover.
     */
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        // We've found it so stop scan
        self.centralManager.stopScan()
        
        // Copy the peripheral instance
        self.peripheral = peripheral
        self.peripheral.delegate = self
        
        // Connect!
        self.centralManager.connect(self.peripheral, options: nil)
        
    }
    
    /*
     * Handle if we connect successfully, will find services here.
     */
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        if peripheral == self.peripheral {
            print("Connected to the Particle Board")
            peripheral.discoverServices([ParticlePeripheral.particleServiceUUID])
        }
    }
    
    
    /*
     * Handle if we find service, find characteristic here.
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        // Discovery event
        if let services = peripheral.services {
            for service in services {
                if service.uuid == ParticlePeripheral.particleServiceUUID {
                    print("sensor service found")
                    //Now kick off discovery of characteristics
                    peripheral.discoverCharacteristics([ParticlePeripheral.sensorCharacteristicUUID], for: service)
                    return
                }
            }
        }
    }
    
    
    /*
     * Match and init characteristic after finding services
     * and characteristic
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == ParticlePeripheral.sensorCharacteristicUUID {
                    print("Sensor characteristic found")
                    sensorChar = characteristic
                    // Enable the button after the char is found
                    changeScanBtn.isEnabled = true;
                }
            }
        }
    }
    
    
    /*
     * Handle reading data.
     */
    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        // Deal with errors (if any).
        if let error = error {
            os_log("Error discovering characteristics: %s", error.localizedDescription)
            cleanup()
            return
        }
        
        guard let characteristicData = characteristic.value,
              let stringFromData = String(data: characteristicData, encoding: .utf8) else { return }
        
        os_log("Received %d bytes: %s", characteristicData.count, stringFromData)
        
        self.setDataLabels(stringFromData:stringFromData)
        
        // re-fetch the data again.
        if (self.isScanning){
            peripheral.readValue(for: sensorChar!)
        }
    }
    
    
    /*
     *  Call this when things either go wrong, or you're done with the connection.
     *  This cancels any subscriptions if there are any, or straight disconnects if not.
     *  (didUpdateNotificationStateForCharacteristic will cancel the connection if a subscription is involved)
     */
    private func cleanup() {
        // Don't do anything if we're not connected
        guard let discoveredPeripheral = peripheral,
              case .connected = discoveredPeripheral.state else { return }
        
        for service in (discoveredPeripheral.services ?? [] as [CBService]) {
            for characteristic in (service.characteristics ?? [] as [CBCharacteristic]) {
                if characteristic.uuid == ParticlePeripheral.sensorCharacteristicUUID && characteristic.isNotifying {
                    // It is notifying, so unsubscribe
                    self.peripheral?.setNotifyValue(false, for: characteristic)
                }
            }
        }
        
        // If we've gotten this far, we're connected, but we're not subscribed, so we just disconnect
        centralManager.cancelPeripheralConnection(discoveredPeripheral)
    }
    
    
    /*
     * Button click to handle scan or stop scan
     */
    @IBAction func changeScanOnClick(_ sender: UIButton){
        changeScanBtn.setTitle(isScanning ? "Start Scanning" : "Stop Scanning", for: .normal)
        isScanning = !isScanning
        if (isScanning){
            peripheral.readValue(for: sensorChar!)
        }
        
        //        while(isScanning){
        //            print("in loop");
        //            await peripheral.readValue(for: self.sensorChar!)
        //            sleep(2)
        //        }
    }
    
    
    /*
     * Set the label texts with the data read in stringFromData
     */
    func setDataLabels(stringFromData: String){
        let dataItems = stringFromData.components(separatedBy: ",")
        self.leftFlexData.text = dataItems[0];
        self.RightFlexData.text = dataItems[1];
        self.leftForceData.text = dataItems[2];
        self.rightForceData.text = dataItems[3];
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Bluetooth
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        // Change the texts in labels while searching devices
        let waitingStr = "Finding Device...";
        leftFlexData.text = waitingStr;
        RightFlexData.text = waitingStr;
        leftForceData.text = waitingStr;
        rightForceData.text = waitingStr;
        
        // Disable the button until device is found.
        changeScanBtn.isEnabled = false;
    }
    
    
}

