//
//  DeviceListViewController.swift
//  BluetoothTest1
//
//  Created by Salvador Marquez on 5/7/19.
//  Copyright © 2019 Citsa Digital. All rights reserved.
//

import UIKit
import CoreBluetooth

class DeviceListViewController: UITableViewController, ScanResultsConsumer {
    
    var adapter : BLEAdapter!
    var utils: Utils!
    var devices : NSMutableArray = []
    var scan_timer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()
        adapter = BLEAdapter.sharedInstance
        adapter.initBluetooth(self)
        utils = Utils.sharedInstance
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return devices.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceTableViewCell", for: indexPath) as! DeviceTableViewCell
        cell.deviceName.text = "Pedro"
        let device = devices.object(at: indexPath.row) as! Device
        cell.deviceName.text = device.deviceName
        print(cell.deviceName.text)
        cell.deviceAddress.text = device.deviceAddress.uuidString
        cell.deviceName.text = device.deviceName
        return cell
    }
    
    func onDeviceDiscovered(_ peripheral: CBPeripheral) {
        /*if let discovered_device_name = peripheral.name {
            let device = Device(peripheral: peripheral, deviceAddress: peripheral.identifier, deviceName: discovered_device_name)
            devices.insert(device, at: 0)
        }else {
            let device = Device(peripheral: peripheral, deviceAddress: peripheral.identifier, deviceName: "<No Name>")
        }
        */
        
        var device_name = "BDSK on "+peripheral.name!
        let device = Device(peripheral: peripheral, deviceAddress: peripheral.identifier, deviceName: device_name)
        devices.insert(device, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        var indexesPath : [IndexPath] = [IndexPath]()
        indexesPath.append(indexPath)
        self.tableView.insertRows(at: indexesPath, with: UITableViewRowAnimation.automatic)
    }

    @IBAction func onScan(_ sender: Any) {
        if adapter.scanning == true {
            print("Already Scanning - Ignoring")
            return
        }
        if adapter.powered_on == false {
            utils.info(message: "Bluetooth is not available yet - is it switched on?", ui: self , cbOK: {print("OK callback")})
            return
        }
        if adapter.scanning == false {
            adapter.scanning = true
            print("Will Start Scanning shortly")
            devices.removeAllObjects()
            self.tableView.reloadData()
        }
        let rc = adapter.findDevices(10,"BDSK", self)
        if rc == -1{
            utils.info(message: "Bluetooth is not available yet - is it turned ON?", ui: self, cbOK: {
                print("OK callback")
            })
        }else {
            print("Setting up timer for when scanning is finished")
            scan_timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(DeviceListViewController.scanningFinished(_:)), userInfo: nil, repeats: false)
        }
    }
    
    @objc func scanningFinished(_ timer: Timer){
        print("Finished Scanning")
        adapter.scanning = false
        if adapter.peripherals.count > 0{
            let msg = "Finished Scanning - found " + String(adapter.peripherals.count) + " devices."
            utils.info(message: msg, ui: self, cbOK: {
                print("OK callback")
            })
        }else{
            let msg = "No devices were found."
            utils.info(message: msg, ui: self, cbOK: {
                print("OK callback")
            })
        }
    }
    
}
