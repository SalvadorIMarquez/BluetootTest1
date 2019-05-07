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

class BLEAdapter : NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {

    
    var central_manager: CBCentralManager?
    var selected_peripheral : CBPeripheral?
    var peripherals :  NSMutableArray = []
    var powered_on : Bool?
    var scanning : Bool?
    var connected : Bool?
    static let sharedInstance = BLEAdapter()
    
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
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]){
        self.peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as! NSMutableArray;
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
    }
}
