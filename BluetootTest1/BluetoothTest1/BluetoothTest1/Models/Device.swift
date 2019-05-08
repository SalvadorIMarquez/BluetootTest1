//
//  Device.swift
//  BluetoothTest1
//
//  Created by Salvador Marquez on 5/7/19.
//  Copyright © 2019 Citsa Digital. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth
class Device {
    //MARK: Properties
    var peripheral: CBPeripheral
    var deviceAddress : UUID
    var deviceName: String
    
    //MARK: Initialization
    init (peripheral: CBPeripheral, deviceAddress : UUID, deviceName: String?){
        self.peripheral = peripheral
        self.deviceAddress = deviceAddress
        if let dn = deviceName{
            self.deviceName = dn
        } else {
            self.deviceName = "No Name"
        }
    }
    
}
