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
    
}
