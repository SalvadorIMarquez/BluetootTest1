//
//  DeviceTableViewCell.swift
//  BluetoothTest1
//
//  Created by Salvador Marquez on 5/7/19.
//  Copyright © 2019 Citsa Digital. All rights reserved.
//

import UIKit
import CoreBluetooth

class DeviceTableViewCell: UITableViewCell {

    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var deviceAddress: UILabel!
    
    
    func update(name: String, address: String){
            deviceName.text = name
        deviceAddress.text = address
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
