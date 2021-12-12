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
import AVFoundation


let waitingStr = "Waiting...";

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
    public static var leftPressureMax = 1000
    public static var rightPressureMax = 1000
    public static var leftFlexMax = 1000
    public static var rightFlexMax = 1000
    public static var leftFlexMin = -1000
    public static var rightFlexMin = -1000
    
    // Notifications
    public var leftForceCnt = 0
    public var leftFlexCnt = 0
    public var rightForceCnt = 0
    public var rightFlexCnt = 0
    public var notificationThreshold = 10
    var audio:AVPlayer!
    let audioUrl = Bundle.main.url(forResource: "alarm", withExtension: "wav")
    var isNotifying = false
    
    // UUID inputs
    @IBOutlet weak var serviceUUIDIn: UITextField!
    @IBOutlet weak var charUUIDIn: UITextField!
    
    // UUID Info in Home scene
    @IBOutlet weak var serviceUUIDValue: UILabel!
    @IBOutlet weak var charUUIDValue: UILabel!
    public static var curServiceUUIDStr = "Current Service UUID: 180C"
    public static var curCharUUIDStr = "Current Characteristic UUID: 2A56"
    
    // Thresholds text input
    @IBOutlet weak var leftFlexMaxIn: UITextField!
    @IBOutlet weak var leftFlexMinIn: UITextField!
    @IBOutlet weak var rightFlexMaxIn: UITextField!
    @IBOutlet weak var rightFlexMinIn: UITextField!
    @IBOutlet weak var leftForceIn: UITextField!
    @IBOutlet weak var rightForceIn: UITextField!
    
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
                    self.changeMonitorBtn.isEnabled = true;
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
        if (self.isMonitoring){
            self.monitor(stringFromData: stringFromData)
        }
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
     * Monitor the sensor data and play sounds for alarm
     */
    func monitor(stringFromData: String){
        print("monitoring data: " + stringFromData)
        
        let dataItems = stringFromData.components(separatedBy: ",")
        let leftFlex = Int(dataItems[0])
        let rightFlex = Int(dataItems[1])
        let leftForce = Int(dataItems[2])
        let rightForce = Int(dataItems[3])
        var notifyStr = ""
        
        // Update counts for each of sensor data,
        // notify if count reach thresholds for notification
        if (leftFlex! > ViewController.leftFlexMax ||
            leftFlex! < ViewController.leftFlexMin){
            self.leftFlexCnt += 1
            if (self.leftFlexCnt > self.notificationThreshold){
                notifyStr += "left flex sensor, "
                self.leftFlexCnt = 0
            }
        }else{
            // Reset count
            self.leftFlexCnt = 0
        }
        
        if (rightFlex! > ViewController.rightFlexMax ||
            rightFlex! < ViewController.rightFlexMin){
            self.rightFlexCnt += 1
            if (self.rightFlexCnt > self.notificationThreshold){
                notifyStr += "right flex sensor, "
                self.rightFlexCnt = 0
            }
        }else{
            // Reset count
            self.rightFlexCnt = 0
        }
        
        if (leftForce! > ViewController.leftPressureMax){
            self.leftForceCnt += 1
            if (self.leftForceCnt > self.notificationThreshold){
                notifyStr += "left force sensor, "
                self.leftForceCnt = 0
            }
        }else{
            // Reset count
            self.leftForceCnt = 0
        }
        
        if (rightForce! > ViewController.rightPressureMax){
            self.rightForceCnt += 1
            if (self.rightForceCnt > self.notificationThreshold){
                notifyStr += "right force sensor, "
                self.rightForceCnt = 0
            }
        }else{
            // Reset count
            self.rightForceCnt = 0
        }
        
        // Notify
        print(self.rightForceCnt, self.leftForceCnt, self.rightFlexCnt, self.leftFlexCnt)
        
        if (notifyStr.count > 0){
            self.notify(position: String(notifyStr.prefix(notifyStr.count - 2)))
        }
    }
    
    /*
     * Notify user that wrong gestures might detected.
     */
    func notify(position: String){
        print("notifying", self.isNotifying)
        if (self.isNotifying){
            return
        }
        
        // Notify, play the alram for 2 seconds
        self.isNotifying = true
        self.sendNotificationAlert(position: position)
        audio = AVPlayer.init(url: self.audioUrl!)
        audio.play()
        sleep(2)
        audio.pause()
        // Set notifying to false when close the alert
        // self.isNotifying = false
    }
    
    func sendNotificationAlert(position: String){
        let defaultAction = UIAlertAction(title: "OK",style: .cancel) { (action) in
            // Respond to user selection of the action.
            self.isNotifying = false
        }
        
        let alert = UIAlertController(title: "Harmful movement detected",
                                      message: "Sensor data exceed threesholds at: "
                                      + position,
                                      preferredStyle: .alert)
        alert.addAction(defaultAction)
        
        self.present(alert, animated: true) {
            // The alert was presented
        }
    }
    
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
        self.isMonitoring = false
        setDataLabels(stringFromData: self.waitingStringRepeatFour)
        self.changeScanBtn.isEnabled = false;
        self.changeMonitorBtn.isEnabled = false;
        
        if (self.isConnecting){
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
                                      message: "Please wait till sensor data is read to set the thresholds or manually input feasible threasholds.",
                                      preferredStyle: .alert)
        alert.addAction(defaultAction)
        
        self.present(alert, animated: true) {
            // The alert was presented
        }
    }
    
    func settingSuccessAlert(title: String){
        let defaultAction = UIAlertAction(title: "OK",style: .cancel) { (action) in
            // Respond to user selection of the action.
        }
        let alert = UIAlertController(title: title + " set",
                                      message: "Your " + title + " are successfully set.",
                                      preferredStyle: .alert)
        alert.addAction(defaultAction)
        
        self.present(alert, animated: true) {
            // The alert was presented
        }
    }
    
    func sendUUIDAlert(){
        let defaultAction = UIAlertAction(title: "OK",style: .cancel) { (action) in
            // Respond to user selection of the action.
        }
        let alert = UIAlertController(title: "Invalid UUIDs",
                                      message: "Please enter valid UUIDs",
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
            ViewController.leftFlexMax = Int(String(curText)) ?? 0
            
        }else{
            self.sendThresholdAlert()
        }
    }
    
    
    @IBAction func setLeftFlexMin(_ sender: Any) {
        let curText = self.leftFlexData.text ?? ""
        
        if ((Int(String(curText))) != nil){
            ViewController.leftFlexMin = Int(String(curText)) ?? 0
            
        }else{
            self.sendThresholdAlert()
        }
    }
    
    
    @IBAction func setRightFlexMax(_ sender: Any) {
        let curText = self.RightFlexData.text ?? ""
        if ((Int(String(curText))) != nil){
            ViewController.rightFlexMax = Int(String(curText)) ?? 0
            
        }else{
            self.sendThresholdAlert()
        }
    }
    
    
    @IBAction func setRightFlexMin(_ sender: Any) {
        let curText = self.RightFlexData.text ?? ""
        if ((Int(String(curText))) != nil){
            ViewController.rightFlexMin = Int(String(curText)) ?? 0
            
        }else{
            self.sendThresholdAlert()
        }
    }
    
    
    @IBAction func setRightForce(_ sender: Any) {
        let curText = self.rightForceData.text ?? ""
        if ((Int(String(curText))) != nil){
            ViewController.rightPressureMax = Int(String(curText)) ?? 0
        }else{
            self.sendThresholdAlert()
        }
    }
    
    @IBAction func setLeftForce(_ sender: Any) {
        let curText = self.leftForceData.text ?? ""
        if ((Int(String(curText))) != nil){
            ViewController.leftPressureMax = Int(String(curText)) ?? 0
        }else{
            self.sendThresholdAlert()
        }
    }
    
    // Set thresholds manually
    @IBAction func setAllThresholds(_ sender: UIButton) {
        let leftForceText = self.leftForceIn.text ?? ""
        let rightForceText = self.rightForceIn.text ?? ""
        let rightFlexMaxText = self.rightFlexMaxIn.text ?? ""
        let rightFlexMinText = self.rightFlexMinIn.text ?? ""
        let leftFlexMaxText = self.leftFlexMaxIn.text ?? ""
        let leftFlexMinText = self.leftFlexMinIn.text ?? ""
        
        if ((Int(String(leftForceText))) != nil &&
            (Int(String(rightForceText))) != nil &&
            (Int(String(rightFlexMaxText))) != nil &&
            (Int(String(rightFlexMinText))) != nil &&
            (Int(String(leftFlexMaxText))) != nil &&
            (Int(String(leftFlexMinText))) != nil){
            ViewController.leftPressureMax = Int(String(leftForceText)) ?? 0
            ViewController.rightPressureMax = Int(String(rightForceText)) ?? 0
            ViewController.leftFlexMax = Int(String(leftFlexMaxText)) ?? 0
            ViewController.leftFlexMin = Int(String(leftFlexMinText)) ?? 0
            ViewController.rightFlexMax = Int(String(rightFlexMaxText)) ?? 0
            ViewController.rightFlexMin = Int(String(rightFlexMinText)) ?? 0
            
            print(ViewController.leftPressureMax, ViewController.rightPressureMax,
                  ViewController.leftFlexMax, ViewController.leftFlexMin, ViewController.rightFlexMax,
                  ViewController.rightFlexMin)
            self.settingSuccessAlert(title: "thresholds")
        }else{
            self.sendThresholdAlert()
        }
    }
    
    @IBAction func changeMonitorStatus(_ sender: UIButton){
        self.changeMonitorBtn.setTitle(self.isMonitoring ? "Start Monitoring" : "Stop Monitoring", for: .normal)
        self.isMonitoring = !self.isMonitoring
    }
    
    // Set uuids of ble
    @IBAction func setUUIDs(_ sender: UIButton) {
        let serviceUUIDstr = String(self.serviceUUIDIn.text ?? "180C")
        let charUUIDstr = String(self.charUUIDIn.text ?? "2A56")
        // Set uuid of particlePeripheral
        
        print(serviceUUIDstr,charUUIDstr)
        
        // Only accept formal UUID, or 4 or 8 digits strings
        //        if(UUID(uuidString: serviceUUIDstr) != nil &&
        //           UUID(uuidString: charUUIDstr) != nil) {
        if((UUID(uuidString: serviceUUIDstr) != nil ||
            serviceUUIDstr.count == 4 || serviceUUIDstr.count == 8
           ) && (UUID(uuidString: charUUIDstr) != nil ||
                 charUUIDstr.count == 4 || charUUIDstr.count == 8
              )) {
            ParticlePeripheral.particleServiceUUID = CBUUID.init(string:serviceUUIDstr)
            
            ParticlePeripheral.sensorCharacteristicUUID =   CBUUID.init(string: charUUIDstr)
            

            // Change text in home page
            ViewController.curServiceUUIDStr = "Current Service UUID: " + serviceUUIDstr

            ViewController.curCharUUIDStr = "Current Characteristic UUID: " + charUUIDstr
            
            print("uuids set")
            print(ParticlePeripheral.sensorCharacteristicUUID, ParticlePeripheral.particleServiceUUID)
            
            self.settingSuccessAlert(title: "UUIDs")
            
        }else{
            self.sendUUIDAlert()
        }
    }
    
    // Switch scenes, update uuids and thresholds
    override func viewWillAppear(_ animated: Bool){
        // UUIDs
        if(self.serviceUUIDValue != nil){
            self.serviceUUIDValue.text = ViewController.curServiceUUIDStr
        }
        
        if(self.serviceUUIDValue != nil){
            print(ViewController.curServiceUUIDStr)
            self.charUUIDValue.text = ViewController.curCharUUIDStr
        }
        
        // Thresholds
        if(self.leftForceIn != nil){
            self.leftForceIn.text = String(ViewController.leftPressureMax)
        }
        
        if(self.rightForceIn != nil){
            self.rightForceIn.text = String(ViewController.rightPressureMax)
        }
        
        if(self.rightFlexMaxIn != nil){
            self.rightFlexMaxIn.text = String(ViewController.rightFlexMax)
        }
        
        if(self.rightFlexMinIn != nil){
            self.rightFlexMinIn.text = String(ViewController.rightFlexMin)
        }

        if(self.leftFlexMaxIn != nil){
            self.leftFlexMaxIn.text = String(ViewController.leftFlexMax)
        }
        
        if(self.leftFlexMinIn != nil){
            self.leftFlexMinIn.text = String(ViewController.leftFlexMin)
        }
        
    }
    
    // Onload, initialize everything if needed.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Disable the button at first.
        if(self.changeScanBtn !== nil){
            self.changeScanBtn.isEnabled = false
        }
        if(self.changeMonitorBtn !== nil){
            self.changeMonitorBtn.isEnabled = false
        }

        // Connect Bluetooth onload. So far, not doing this
        // untill the start connection btn is clicked.
        // centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}

