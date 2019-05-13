//
//  BLEAdapter.swift
//  BluetoothTest1
//
//  Created by Salvador Marquez on 5/7/19.
//  Copyright © 2019 Citsa Digital. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

protocol ScanResultsConsumer{
    func onDeviceDiscovered(_ device : CBPeripheral)
}

class BLEAdapter : NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {

    
    var central_manager: CBCentralManager?
    var selected_peripheral : CBPeripheral?
    var peripherals :  NSMutableArray = []
    var powered_on : Bool?
    var scanning : Bool?
    var connected : Bool?
    static let sharedInstance = BLEAdapter()
    var scan_results_consumer: ScanResultsConsumer?
    var required_name : String?
    var bluetooth_operations_consumer: BluetoothOperationsConsumer?
    var rssiTimer = Timer()
    
    let IMMEDIATE_ALERT_SERVICE_UUID      = "00001802-0000-1000-8000-00805F9B34FB"
    
    let LINK_LOSS_SERVICE_UUID            = "FFE0"
    let ALERT_LEVEL_CHARACTERISTIC        = "FFE1"
    //let ALERT_LEVEL_CHARACTERISTIC        = "00002A06-0000-1000-8000-00805F9B34FB"
    //let LINK_LOSS_SERVICE_UUID            = "00001803-0000-1000-8000-00805F9B34FB"
    let TX_POWER_SERVICE_UUID             = "00001804-0000-1000-8000-00805F9B34FB"
    
    let PROXIMITY_MONITORING_SERVICE_UUID = "3E099910-293F-11E4-93BD-AFD0FE6D1DFD"
    
    
    let HEALTH_THERMOMETER_SERVICE_UUID   = "FFE0"
    let TEMPERATURE_MEASUREMENT_CHARACTERISTIC = "FFE1"
    
    let CLIENT_PROXIMITY_CHARACTERISTIC   = "3E099911-293F-11E4-93BD-AFD0FE6D1DFD"
    
    let NUM_SERVICES_OF_INTEREST = 4
    
    var ll_alert_level_characteristic: CBCharacteristic?
    var ia_alert_level_characteristic: CBCharacteristic?
    var temperature_measurement_characteristic: CBCharacteristic?
    var client_proximity_characteristic: CBCharacteristic?
    
    var service_char_discovery_count: Int?
    
    
    func centralManagerStaToString(_ state: CBManagerState) -> [CChar]? {
        var returnVal = "Unknown State"
        if(state == CBManagerState.unknown) { returnVal = "State unknown (CBCentralManagerStateUnknown" }
        else if state == CBManagerState.resetting { returnVal = "State resetting (CBCentralManagerStatReseting)" }
        else if state == CBManagerState.unsupported { returnVal = "State BLE Unsuported (CBCentralMAnagerStateUnsupported)" }
        else if state == CBManagerState.unauthorized { returnVal = "State unauthorized (CBCentralManagerStateUnauthorized)" }
        else if state == CBManagerState.poweredOff { returnVal = "State BLE powered off (CBCentralManagerStatePoweredOff)" }
        else if state == CBManagerState.poweredOn { returnVal = "State powered up and ready (CBCEntralManagerStatePoweredOn)"}
        else { returnVal = "State Unknown"}
        return (returnVal.cString(using: String.Encoding.utf8))
    }
    
    func printKnownPeripherals(){
        print("List Of Currently known peripherals : ");
        let count = self.peripherals.count
        if count > 0 {
            for i in 0...count - 1 {
                let p = self.peripherals.object(at: i)as! CBPeripheral
                self.printDeviceDetails(p)
            }
        }
    }
    
    func printDeviceDetails(_ peripheral: CBPeripheral){
        print("Peripheral Info: ")
        print("Name: \(peripheral.name)")
        print("ID: \(peripheral.identifier)")
    }
    
    func initBluetooth(_ device_list : DeviceListViewController)-> Int{
        
        self.scan_results_consumer = device_list
        powered_on = false
        scanning = false
        connected = false
        self.central_manager = CBCentralManager(delegate : self , queue: nil, options : [CBCentralManagerOptionRestoreIdentifierKey :"BDSK"])
        return 0
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]){
        self.peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as! NSMutableArray;
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            powered_on = true
            return
        } else if central.state == CBManagerState.poweredOff {
            powered_on = false
            return
        }
    }
    
    func findDevices(_ timeout: Int, _ name: String, _ consumer : ScanResultsConsumer) -> Int{
        if self.central_manager?.state != CBManagerState.poweredOn{
            print("Bluetooth is not powered ON")
            return -1
        }
        peripherals.removeAllObjects()
        required_name = name
        Timer.scheduledTimer(timeInterval: Double(timeout), target: self, selector: #selector(BLEAdapter.stopScanning(_:)), userInfo: nil, repeats: false)
        scanning = true
        self.central_manager?.scanForPeripherals(withServices: nil, options: nil)
        return 0
        
    }
    
    @objc func stopScanning(_ Timer : Timer){
        if scanning == true {
            self.central_manager?.stopScan()
            scanning = false
            
        }
    }
    
    func stopScanning()
    {
        if (scanning == true) {
            self.central_manager?.stopScan()
            scanning = false
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if let localname = advertisementData["kCBAdvDataLocalName"]{
            print(advertisementData["kCBAdvDataLocalName"] as! String)
        }else {return}
        printDeviceDetails(peripheral)
        var i = 0
        while i < self.peripherals.count{
            let p = self.peripherals.object(at: i)
            if (p as AnyObject).identifier == peripheral.identifier{
                self.peripherals.replaceObject(at: i, with: peripheral)
                return
            }
            i = i+1
        }
        //did not find device in our array so it must be a new device
        self.peripherals.add(peripheral)
        scan_results_consumer?.onDeviceDiscovered(peripheral)
    }
    
    func connect(_ result_consumer: BluetoothOperationsConsumer){
        if selected_peripheral != nil{
            selected_peripheral?.delegate = self
            bluetooth_operations_consumer  = result_consumer
            central_manager?.connect(selected_peripheral!, options: nil)
        }
    }
    
    func disconnect(_ result_consumer: BluetoothOperationsConsumer ){
        if selected_peripheral != nil {
            bluetooth_operations_consumer = result_consumer
            central_manager?.cancelPeripheralConnection(selected_peripheral!)
        }
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected")
        connected = true
        bluetooth_operations_consumer?.onConnected()
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("didFailToConnect")
        bluetooth_operations_consumer?.onFailedToConnect(error)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected")
        connected = false
        bluetooth_operations_consumer?.onDisconnected()
    }
    
    func startPollingRssi(_ result_consumer: BluetoothOperationsConsumer){
        rssiTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){
            (_)in self.selected_peripheral?.readRSSI()
        }
    }
    
    func stopPollingRssi(){
        rssiTimer.invalidate()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?){
        bluetooth_operations_consumer?.onRSSIValue(RSSI)
    }
    
    func discoverServices(){
        self.selected_peripheral?.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("didDiscoveredServices")
        bluetooth_operations_consumer?.onServicesDiscovered()
    }
    
    func discoverCharacteristics(){
        if let services = selected_peripheral?.services{
            service_char_discovery_count = 0
            for service in services {
                if( service.uuid == CBUUID(string: LINK_LOSS_SERVICE_UUID) ||
                    service.uuid == CBUUID(string: IMMEDIATE_ALERT_SERVICE_UUID) ||
                    service.uuid == CBUUID(string: PROXIMITY_MONITORING_SERVICE_UUID) ||
                    service.uuid == CBUUID(string: HEALTH_THERMOMETER_SERVICE_UUID) ){
                        selected_peripheral?.discoverCharacteristics(nil, for: service)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        let ht_uuid = CBUUID(string:  HEALTH_THERMOMETER_SERVICE_UUID)
        let ll_uuid = CBUUID(string: LINK_LOSS_SERVICE_UUID)
        if let characteristics = service.characteristics{
            for characteristic in characteristics {
                print("\(service.uuid) characteristic: \(characteristic.uuid)")
                if service.uuid == CBUUID(string: LINK_LOSS_SERVICE_UUID) &&
                    characteristic.uuid == CBUUID(string: ALERT_LEVEL_CHARACTERISTIC) {
                    
                    ll_alert_level_characteristic = characteristic
                    print("discovered Link Loss Alert Level")
                    service_char_discovery_count = service_char_discovery_count! + 1
                    bluetooth_operations_consumer?.onLlAlertLevelDiscovered()
                    
                }else if service.uuid == CBUUID(string: IMMEDIATE_ALERT_SERVICE_UUID) &&
                    characteristic.uuid == CBUUID(string : ALERT_LEVEL_CHARACTERISTIC){
                    
                    ia_alert_level_characteristic = characteristic
                    print("discovered Immediat Alert Level")
                    service_char_discovery_count = service_char_discovery_count! + 1
                    bluetooth_operations_consumer?.onIaAlertLevelDiscovered()
                    
                }else if service.uuid == CBUUID(string: PROXIMITY_MONITORING_SERVICE_UUID) &&
                    characteristic.uuid == CBUUID(string: CLIENT_PROXIMITY_CHARACTERISTIC){
                    
                   client_proximity_characteristic = characteristic
                    print("discovered Proximity Monitoring Client Proximity")
                    service_char_discovery_count = service_char_discovery_count! + 1
                    bluetooth_operations_consumer?.onPmClientProximityDiscovered()
                    
                }else if service.uuid == CBUUID(string:HEALTH_THERMOMETER_SERVICE_UUID) &&
                    characteristic.uuid == CBUUID(string: TEMPERATURE_MEASUREMENT_CHARACTERISTIC){
                    
                    temperature_measurement_characteristic = characteristic
                    print("discovered Temperature Measurement Client Proximity")
                    service_char_discovery_count = service_char_discovery_count! + 1
                    bluetooth_operations_consumer?.onHtTemperatureMeasurementDiscovered()
                    
                }
            }
                bluetooth_operations_consumer?.onDiscoveryFinished()
        }
        
    }
    
    func getLlAlertLevel(){
        selected_peripheral?.readValue(for: ll_alert_level_characteristic!)
        selected_peripheral?.setNotifyValue(true,
                            for: ll_alert_level_characteristic!)
        print("Value read")
    }
   
    

    
   func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("\n didUpdateValueFor characteristic: \n service= \(characteristic.service.uuid.uuidString) \n  characteristic= \(characteristic.uuid.uuidString)")
        if characteristic.service.uuid == CBUUID(string: LINK_LOSS_SERVICE_UUID) && characteristic.uuid == CBUUID(string: ALERT_LEVEL_CHARACTERISTIC){
            if let data = characteristic.value {
                var values = [UInt8](repeating: 0, count: data.count)
                data.copyBytes(to: &values, count: data.count)
                bluetooth_operations_consumer?.onLlAlertLevelRead(values[0])
            }else {
                print("ERROR: NO DATA from characteristics")
            }
        }
        
    }
    
    func setAlertLevel(alert_level: String){
        let new_alert_level = [alert_level]
       /* let alert_level_byte = Data(bytes: new_alert_level)
        selected_peripheral?.writeValue(alert_level_byte, for: ll_alert_level_characteristic!, type: .withoutResponse)
        */
        let prueba = alert_level.data(using: String.Encoding.utf8)
        selected_peripheral?.writeValue(prueba!, for: ll_alert_level_characteristic!, type: .withoutResponse)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?){
        print("didWriteValueFor characteristic: service= \(characteristic.service.uuid.uuidString) characteristic= \(characteristic.uuid.uuidString) ")
        if characteristic.service.uuid == CBUUID(string: LINK_LOSS_SERVICE_UUID) && characteristic.uuid == CBUUID(string: ALERT_LEVEL_CHARACTERISTIC){
            bluetooth_operations_consumer?.onLlAlertLevelWritten()
        }
        
    }
    
}
