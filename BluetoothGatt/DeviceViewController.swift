//
//  DeviceViewController.swift
//  BluetoothGatt
//
//  Created by Bill on 2018/6/6.
//  Copyright © 2018 bill. All rights reserved.
//

import UIKit
import CoreBluetooth

class DeviceViewController: UIViewController,BLECentrallerDelegate {

    @IBOutlet weak var softUUIDLabel: UILabel!
    @IBOutlet weak var recvTextView: UITextField!
    @IBOutlet weak var MessageTextView: UITextView!
    
    @IBOutlet weak var DataTextField: UITextField!
    
    
    var myStructure = mStructure()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        softUUIDLabel.layer.borderWidth = 1;
        softUUIDLabel.layer.borderColor = UIColor.gray.cgColor
        softUUIDLabel.layer.cornerRadius = 8;
        softUUIDLabel.layer.masksToBounds = true
        softUUIDLabel.text = BLECentraller.sharedStore.mPeripheral?.identifier.uuidString

    }

    override func viewDidAppear(_ animated: Bool) {
        BLECentraller.sharedStore.delegate = self
        BLECentraller.sharedStore.connect(peripheral: BLECentraller.sharedStore.mPeripheral!)
        myStructure = BLECentraller.sharedStore.myStructure
    }

    override func viewWillDisappear(_ animated: Bool) {
        BLECentraller.sharedStore.delegate = nil
    }
    
    @IBAction func CancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func SendAction(_ sender: Any) {
        BLECentraller.sharedStore.writeValueForCharacteristic(hex: DataTextField.text!, forCharacteristic: myStructure.mCharacteristic!)
    }
    
    @IBAction func ReadAction(_ sender: Any) {
        BLECentraller.sharedStore.readValueForCharacteristic(characteristic: myStructure.mCharacteristic!)
    }
    
    func readData(characteristic: CBCharacteristic, peripheral: CBPeripheral) {
        var tokenString = ""
        let data = characteristic.value
        MessageTextView.text = characteristic.value?.hexEncodedString()
    }
    
    func peripheralFound(peripheral: CBPeripheral, rssi: NSNumber, deviceName: NSString) {
        
    }
    
    func setConnect() {
        print("連線")
        recvTextView.text = "連線成功"
    }
    
    func setDisconnect() {
        print("斷線")
        recvTextView.text = "連線失敗"
    }

}
