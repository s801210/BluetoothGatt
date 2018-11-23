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
    
    //存取 基本Device資訊
    var peripherals: [NSMutableDictionary] = []
    
    // 過濾與更新使用
    var filter: [String] = []
    
    // 掃描時間超時使用
    var timer = Timer()
    
    // 掃描時間
    let TimeOut = 20
    
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
        self.filter.removeAll()

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
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "System")
        }

        // 顯示資料，從字典內把資料取出
        let dictionary = self.peripherals[indexPath.row]
        let peripheral = dictionary["peripheral"] as! CBPeripheral
        let rssi = dictionary["rssi"] as! NSNumber
        // Rssi 要轉 int
        
        if(peripheral.name == nil){
            cell?.textLabel?.text = "Device Name = Unnamed"
        }else{
            cell?.textLabel?.text = "Device Name = \(peripheral.name!)"
        }

        cell?.detailTextLabel?.text = "Rssi:\(rssi.intValue)"

 
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.ScanButton.setTitle("Scan", for: .normal)
        let dictionary = self.peripherals[indexPath.row]
        let peripheral = dictionary["peripheral"] as! CBPeripheral
        BLECentraller.sharedStore.stopScan()
        BLECentraller.sharedStore.mPeripheral = peripheral
        self.performSegue(withIdentifier: "goDevice", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func readData(characteristic: CBCharacteristic, peripheral: CBPeripheral) {
        
    }
    
    // Found peripheral
    func peripheralFound(peripheral: CBPeripheral, rssi: NSNumber) {
        
        let dictionary = NSMutableDictionary()
        dictionary["peripheral"] = peripheral
        dictionary["rssi"] = rssi
        
        // 過濾
        if let i = filter.firstIndex(where: { $0.hasPrefix(peripheral.identifier.uuidString) }) {
            peripherals[i]["rssi"] = rssi // 更新Rssi
            tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)// 只更新Rssi有變動的Row，不要動畫
        }else{
            // 沒搜尋到就存起來，代表本身沒有
            filter.append(peripheral.identifier.uuidString)
            peripherals.append(dictionary)
            
//            tableView.beginUpdates()
//            tableView.insertRows(at: [IndexPath(row: peripherals.count-1, section: 0)], with: .none)
//            tableView.endUpdates()

            tableView.reloadData()
        }
        
    }
    
    func setConnect() {
        print("setConnect")
    }
    
    func setDisconnect() {
        print("setDisconnect")
        
    }
    
}

