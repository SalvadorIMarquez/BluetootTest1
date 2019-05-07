//
//  Utils.swift
//  BluetoothTest1
//
//  Created by Salvador Marquez on 5/7/19.
//  Copyright © 2019 Citsa Digital. All rights reserved.
//

import Foundation
import UIKit
class Utils {
    static let sharedInstance = Utils()
    func info(message: String, ui: UIViewController, cbOK: @escaping () -> Void ){
        let dialog = UIAlertController(title: "Information", message: message, preferredStyle: UIAlertController.Style.alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) {
            (action) in cbOK()
        }
        dialog.addAction(OKAction)
        //present the dialog
        ui.present(dialog,animated: false, completion: nil)
    }
    
    func  error(message: String, ui: UIViewController, cbOK:@escaping () -> Void) {
        let dialog  = UIAlertController(title: "ERROR", message: "message", preferredStyle: UIAlertController.Style.alert)
        let OKAction = UIAlertAction(title: "OK", style: .default){
            (action) in cbOK()
        }
        dialog.addAction(OKAction)
        //present the dialog
        ui.present(dialog, animated: false, completion: nil)
    }
}
