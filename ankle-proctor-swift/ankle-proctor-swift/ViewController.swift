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

let waitingStr = "Finding Device...";

class ViewController: UIViewController, CBPeripheralDelegate, CBCentralManagerDelegate {
    // Properties for bluetooth.
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    private var sensorChar: CBCharacteristic?
    
    // Properties for matedata.
    private var waitingStringRepeatFour = waitingStr + "," + waitingStr + "," + waitingStr + "," + waitingStr
    
    // Properties for control.
    private var isScanning = false
    private var isConnecting = false
    private var isMonitoring = false
    
    // Thresholds
    public var leftPressureMax = 1000
    public var rightPressureMax = 1000
    public var leftFlexMax = 1000
    public var rightFlexMax = 1000
    public var leftFlexMin = -1000
    public var rightFlexMin = -1000
    
    // Properties in UI.
    // Show connection data.
    @IBOutlet weak var serviceUUIDText: UILabel!
    @IBOutlet weak var charUUIDText: UILabel!
    
    // Show the sensor data
    @IBOutlet weak var leftFlexData: UILabel!
    @IBOutlet weak var RightFlexData: UILabel!
    @IBOutlet weak var leftForceData: UILabel!
    @IBOutlet weak var rightForceData: UILabel!
    @IBOutlet weak var changeScanBtn: UIButton!
    @IBOutlet weak var changeConnectBtn: UIButton!
    @IBOutlet weak var changeMonitorBtn: UIButton!
    
    // Start of Bluetooth setting to get data.
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
                    self.sensorChar = characteristic
                    // Enable the button after the char is found
                    self.changeScanBtn.isEnabled = true;
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
        guard let discoveredPeripheral = self.peripheral,
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
    // End of Bluetooth Control Functions.
    
    /*
     * Button click to handle scan or stop scan.
     * Set the title of button and change scanning status.
     */
    @IBAction func changeScanOnClick(_ sender: UIButton){
        self.changeScanBtn.setTitle(self.isScanning ? "Start Scanning" : "Stop Scanning", for: .normal)
        self.isScanning = !self.isScanning
        if (isScanning){
            peripheral.readValue(for: sensorChar!)
        }
    }
    
    /*
     * Button click to handle start or end connection.
     * Set the title of button and change connection status.
     */
    @IBAction func changeConnectioOnClick(_ sender: UIButton) {
        self.changeConnectBtn.setTitle(self.isConnecting ? "Start Connection" : "Stop Connection", for: .normal)
        self.isConnecting = !self.isConnecting
        // Reset precious connections status.
        cleanup()
        self.isScanning = false
        setDataLabels(stringFromData: self.waitingStringRepeatFour)
        
        if (self.isConnecting){
            // Disable scanning till connected.
            self.changeScanBtn.isEnabled = false;
            centralManager = CBCentralManager(delegate: self, queue: nil)
        }else{
            
        }
    }
    
    
    /*
     * Set the label texts with the data read in stringFromData
     */
    func setDataLabels(stringFromData: String){
        let dataItems = stringFromData.components(separatedBy: ",")
        leftFlexData.text = dataItems[0];
        RightFlexData.text = dataItems[1];
        leftForceData.text = dataItems[2];
        rightForceData.text = dataItems[3];
    }
    
    func sendThresholdAlert(){
        let defaultAction = UIAlertAction(title: "OK",style: .cancel) { (action) in
            // Respond to user selection of the action.
        }
        let alert = UIAlertController(title: "Invalid threshold",
                                      message: "Please wait till sensor data is read to set the thresholds.",
                                      preferredStyle: .alert)
        alert.addAction(defaultAction)
        
        self.present(alert, animated: true) {
            // The alert was presented
        }
    }
    
    // Buttons to set thresholds with sensor data.
    // Send alert if sensor data is not received yet.
    @IBAction func SetLeftMaxSensor(_ sender: UIButton) {
        let curText = self.leftFlexData.text ?? ""
        
        if ((Int(String(curText))) != nil){
            self.leftFlexMax = Int(String(curText)) ?? 0
            
        }else{
            self.sendThresholdAlert()
        }
    }
    
    
    @IBAction func setLeftFlexMin(_ sender: Any) {
        let curText = self.leftFlexData.text ?? ""
        
        if ((Int(String(curText))) != nil){
            self.leftFlexMin = Int(String(curText)) ?? 0
            
        }else{
            self.sendThresholdAlert()
        }
    }
    
    
    @IBAction func setRightFlexMax(_ sender: Any) {
        let curText = self.RightFlexData.text ?? ""
        if ((Int(String(curText))) != nil){
            self.rightFlexMax = Int(String(curText)) ?? 0
            
        }else{
            self.sendThresholdAlert()
        }
    }
    
    
    @IBAction func setRightFlexMin(_ sender: Any) {
        let curText = self.RightFlexData.text ?? ""
        if ((Int(String(curText))) != nil){
            self.rightFlexMin = Int(String(curText)) ?? 0
            
        }else{
            self.sendThresholdAlert()
        }
    }
    
    
    @IBAction func setRightForce(_ sender: Any) {
        let curText = self.rightForceData.text ?? ""
        if ((Int(String(curText))) != nil){
            self.rightPressureMax = Int(String(curText)) ?? 0
        }else{
            self.sendThresholdAlert()
            print(self.leftPressureMax)
        }
    }
    
    
    
    // Onload, initialize everything if needed.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        setDataLabels(stringFromData: self.waitingStringRepeatFour)
        
        // Disable the button until device is found.
        self.changeScanBtn.isEnabled = false
        self.changeMonitorBtn.isEnabled = false
        
        // Connect Bluetooth onload. So far, not doing this
        // untill the start connection btn is clicked.
        // centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}

