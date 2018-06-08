//
//  ViewController.swift
//  BluetoothGatt
//
//  Created by Bill on 2018/6/6.
//  Copyright © 2018 bill. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, BLECentrallerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ScanButton: UIButton!
    
    var RSSIs = [NSNumber]()
    var peripherals: [CBPeripheral] = []
    var timer = Timer()
    let TimeOut = 10

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        BLECentraller.sharedStore.delegate = self
        BLECentraller.sharedStore.setup()
    }

    override func viewWillDisappear(_ animated: Bool) {
        BLECentraller.sharedStore.delegate = nil
    }
    
    @IBAction func ScanAction(_ sender: Any) {
        self.peripherals.removeAll()
        self.RSSIs.removeAll()
        
        BLECentraller.sharedStore.startScan()
        self.ScanButton.setTitle("Scanning", for: .normal)
        self.timer.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(TimeOut), target: self, selector: #selector(self.cancelScan), userInfo: nil, repeats: false)
    }
    
    @objc func cancelScan() {
        self.timer.invalidate()
        self.ScanButton.setTitle("Scan", for: .normal)
        BLECentraller.sharedStore.stopScan()
       
    }
    
    
    
    // MARK: Table View Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "System")
        if (cell == nil){
            cell = UITableViewCell(style: .default, reuseIdentifier: "System")
        }
        cell?.textLabel?.text = "\(self.peripherals[indexPath.row].name ?? ""),  RSSI:\(self.RSSIs[indexPath.row])"
        return cell!
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.ScanButton.setTitle("Scan", for: .normal)
        BLECentraller.sharedStore.stopScan()
        BLECentraller.sharedStore.mPeripheral = self.peripherals[indexPath.row]
        self.performSegue(withIdentifier: "goDevice", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func readData(characteristic: CBCharacteristic, peripheral: CBPeripheral) {
        
    }
    
    // Found peripheral
    func peripheralFound(peripheral: CBPeripheral, rssi: NSNumber, deviceName: NSString) {
        self.peripherals.append(peripheral)
        self.RSSIs.append(rssi)
        self.tableView.reloadData()
    }
    
    func setConnect() {
        print("setConnect")
    }
    
    func setDisconnect() {
        print("setDisconnect")
        
    }

}

