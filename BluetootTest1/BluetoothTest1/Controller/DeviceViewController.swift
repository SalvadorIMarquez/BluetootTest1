//
//  DeviceViewController.swift
//  BluetoothTest1
//
//  Created by Salvador Marquez on 5/8/19.
//  Copyright © 2019 Citsa Digital. All rights reserved.
//

import UIKit

class DeviceViewController: UIViewController, BluetoothOperationsConsumer {
   
    var adapter: BLEAdapter!
    var utils: Utils!

    @IBOutlet weak var device_details :UILabel!
    @IBOutlet weak var rssi: UILabel!
    @IBOutlet weak var proximity_classification: UIView!
    @IBOutlet weak var btnLow: UIButton!
    @IBOutlet weak var btnMedium: UIButton!
    @IBOutlet weak var btnHigh: UIButton!
    @IBOutlet weak var switchShare: UISwitch!
    @IBOutlet weak var switchTemperature: UISwitch!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var btnNoise: UIButton!
    @IBOutlet weak var btnConnect: UIButton!
    
    var got_ll_alert_level: Bool?
    var got_ia_alert_level: Bool?
    var got_pm_client_proxitmity: Bool?
    var got_ht_temperature_measurement: Bool?
    
    var ll_alert_level: UInt8?
    let default_btn_colour = UIColor(red:247.0/255.0, green:247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        btnLow.isEnabled = false
        btnMedium.isEnabled = false
        btnHigh.isEnabled = false
        btnNoise.isEnabled = false
        switchShare.isEnabled = false
        switchTemperature.isEnabled = false
        rssi.text = "RSSI: unavailable"
        proximity_classification.backgroundColor = UIColor.gray
        adapter = BLEAdapter.sharedInstance
        utils = Utils.sharedInstance
        device_details.text = "Device: < " + adapter.selected_peripheral!.name! + " >"
        adapter.connect(self)
        print(adapter.connected)
        got_ia_alert_level = false
        got_ll_alert_level = false
        got_pm_client_proxitmity = false
        got_ht_temperature_measurement = false
        ll_alert_level = 0
        
    }
    
    @IBAction func onConnect(_ sender: Any) { // funcion para boton conectar
        print("onConnect")
        if adapter.connected == false{
            adapter.connect(self)
        }else {
            adapter.disconnect(self)
        }
    }
    
    @IBAction func onMakeNoise(_ sender: Any) { // funcion para hacer Ruido
        print("onMakeNoise Jalanding")
    }
    
    @IBAction func onTemperatureMonitoringChanged(_ sender: Any) {
        print("onTemperatureMonitoringCanged Jalanding")
    }
    @IBAction func onSharedChanged(_ sender: Any) {
        print("onSharedChanged Jalanding")
    }
    
    @IBAction func onLow(_ sender: Any) {
        print("onLow Jalanding")
    }
    
    @IBAction func onMedium(_ sender: Any) {
        print("onMedium Jalanding")
    }
    
    @IBAction func onHigh(_ sender: Any) {
        print("onHigh Jalanding")
    }
    
    func onConnected() {            //funcion parte del protocolo BLuetoothOperationConsumer
        print("onConnected")
        btnConnect.setTitle("DISCONNECT", for: .normal)
        adapter.startPollingRssi(self)
        adapter.discoverServices()
    
    }
    
    func onFailedToConnect(_ error: Error?) {       //funcion parte del protocolo BLuetoothOperationConsumer
        print("onFailedToConnect")
        utils.error(message: "Failed to Connect : \(error)", ui: self, cbOK: {})
        
    }
    
    func onDisconnected() {             //funcion parte del protocolo BLuetoothOperationConsumer
        print("onDisconnected")
        btnConnect.setTitle("CONNECT", for: .normal )
        adapter.stopPollingRssi()
        btnLow.isEnabled = false
        btnMedium.isEnabled = false
        btnHigh.isEnabled = false
        btnNoise.isEnabled = false
        switchShare.isEnabled = false
        switchTemperature.isEnabled = false
        rssi.text = "RSSI: unavailable"
        proximity_classification.backgroundColor = UIColor.gray
        
    }
    
    func onRSSIValue(_ rssi: NSNumber) {   //funcion partedel protocolo BluetoothOperationConsumer
        updateProximityClassification(rssi)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParentViewController{
            if adapter.connected == true {
                print("Disconnecting")
                adapter.disconnect(self)
            }
        }
    }
    
    func onServicesDiscovered() {
        print("onServicesDiscovered")
        adapter.discoverCharacteristics()
    }
    
    func onLlAlertLevelDiscovered() {
        got_ll_alert_level = true
        print("onLinkLostDiscovered")
        btnLow.isEnabled = true
        btnMedium.isEnabled = true
        btnHigh.isEnabled = true
    }
    
    func onPmClientProximityDiscovered() {
        got_pm_client_proxitmity = true
        switchShare.isEnabled = true
    }
    
    func onDiscoveryFinished() {
        print("onDiscoveryFinished")
        
        if got_ll_alert_level! {
            print("LinkLostAlert activated")
            adapter.getLlAlertLevel()
        }
    }
    func onIaAlertLevelDiscovered() {
        got_ia_alert_level = true
        btnNoise.isEnabled = true
    }
    func onHtTemperatureMeasurementDiscovered() {
        switchTemperature.isEnabled = true
        got_ht_temperature_measurement  = true
    }
    func onLlAlertLevelRead(_ ll_alert_level: UInt8) {
        print("onLlAlertLevelRead \(ll_alert_level)")
        self.ll_alert_level = ll_alert_level
        let ll_al_int = Int8(bitPattern: ll_alert_level)
        switch ll_al_int {
        case 0:
            btnLow.backgroundColor = UIColor.green
            btnMedium.backgroundColor = default_btn_colour
            btnHigh.backgroundColor = default_btn_colour
        case 1:
            btnLow.backgroundColor = default_btn_colour
            btnMedium.backgroundColor = UIColor.yellow
            btnHigh.backgroundColor = default_btn_colour
        case 2:
            btnLow.backgroundColor = default_btn_colour
            btnMedium.backgroundColor = default_btn_colour
            btnHigh.backgroundColor = UIColor.red
        default:
            btnLow.backgroundColor = default_btn_colour
            btnMedium.backgroundColor = default_btn_colour
            btnHigh.backgroundColor = default_btn_colour
        }
    }
        
    func updateProximityClassification(_ rssi_value: NSNumber){
        var proximity_band = 3
        rssi.text = "Rssi: \(rssi_value.floatValue.description) dBm"
        if rssi_value.floatValue < -80.0 {
            proximity_classification.backgroundColor = UIColor.red
        } else if rssi_value.floatValue < -50.0 {
            proximity_classification.backgroundColor = UIColor.yellow
        } else {
            proximity_classification.backgroundColor = UIColor.green
            proximity_band = 1
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

protocol BluetoothOperationsConsumer{
    func onConnected()
    func onFailedToConnect(_ error: Error?)
    func onDisconnected()
    func onRSSIValue(_ rssi: NSNumber)
    func onServicesDiscovered()
    func onLlAlertLevelDiscovered()
    func onIaAlertLevelDiscovered()
    func onPmClientProximityDiscovered()
    func onHtTemperatureMeasurementDiscovered()
    func onDiscoveryFinished()
    func onLlAlertLevelRead(_ ll_alert_level: UInt8)
}
