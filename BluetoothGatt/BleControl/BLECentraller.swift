//
//  BLECentraller.swift
//  BluetoothGatt
//
//  Created by Bill on 2018/6/6.
//  Copyright © 2018 bill. All rights reserved.
//

import UIKit
import CoreBluetooth

public protocol BLECentrallerDelegate: NSObjectProtocol
{
    func readData(characteristic:CBCharacteristic, peripheral:CBPeripheral)
    func peripheralFound(peripheral: CBPeripheral, rssi: NSNumber)
    func setConnect()
    func setDisconnect()
}


class BLECentraller: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate
{
    static let sharedStore = BLECentraller();
    weak var delegate: BLECentrallerDelegate?
    //Data
    var centralManager : CBCentralManager!
    var RSSIs = [NSNumber]()
    var peripherals: Set<String> = Set()
    var mPeripheral : CBPeripheral?
    let myStructure = mStructure()

    // setup
    func setup(){
         centralManager = CBCentralManager.init(delegate: self, queue: nil)
    }
    
    // startScan
    func startScan() {
        peripherals.removeAll()
        RSSIs.removeAll()
        print("Now Scanning...")
        //CBCentralManagerScanOptionAllowDuplicatesKey值為 false，表示不重複掃描已發現的設備
        centralManager.scanForPeripherals(withServices: nil , options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
//        centralManager.scanForPeripherals(withServices: [CBUUID(string:mService_UUID)] , options: [CBCentralManagerScanOptionAllowDuplicatesKey:false])
    }
    
    // stopScan
    func stopScan() {
        self.centralManager.stopScan()
        print("Scan Stopped")
    }
    
    //Peripheral Connections: Connecting, Connected, Disconnected
    //-Connection
    func connect(peripheral: CBPeripheral) {
        print("connect")
        print(peripheral)
        self.mPeripheral = peripheral
        centralManager.connect(self.mPeripheral!, options: nil)
    }
    
    //-Terminate all Peripheral Connection
    /*
     Call this when things either go wrong, or you're done with the connection.
     This cancels any subscriptions if there are any, or straight disconnects if not.
     (didUpdateNotificationStateForCharacteristic will cancel the connection if a subscription is involved)
     */
    func disconnect() {
        if mPeripheral != nil {
            // We have a connection to the device but we are not subscribed to the Transfer Characteristic for some reason.
            // Therefore, we will just disconnect from the peripheral
            centralManager.cancelPeripheralConnection(mPeripheral!)
            mPeripheral = nil
        }
    }
    //Restores Central Manager delegate if something went wrong
    func restoreCentralManager() {
        centralManager.delegate = self
    }
    
    /*
     Called when the central manager discovers a peripheral while scanning. Also, once peripheral is connected, cancel scanning.
     */
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // 如果名稱是空的就不是我們要的裝置
//        if(peripheral.name == nil || peripheral.name?.count == 0){
//            return
//        }
        
        
        // 找到後直後往後丟，後面處理就好了
        delegate?.peripheralFound(peripheral: peripheral, rssi: RSSI)

//            print("Found new pheripheral devices with services")
//            print("Peripheral name: \(String(describing: peripheral.name))")
//            print("Advertisement Data : \(advertisementData)")
        
    }

    /*
     Invoked when the central manager fails to create a connection with a peripheral.
     */
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if error != nil {
            print("Failed to connect to peripheral")
            return
        }
    }
    
    /*
     Invoked when you discover the peripheral’s available services.
     This method is invoked when your app calls the discoverServices(_:) method. If the services of the peripheral are successfully discovered, you can access them through the peripheral’s services property. If successful, the error parameter is nil. If unsuccessful, the error parameter returns the cause of the failure.
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        guard let services = peripheral.services else {
            return
        }
        print("Discovered Services: \(services)")
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    /*
     Invoked when you discover the characteristics of a specified service.
     This method is invoked when your app calls the discoverCharacteristics(_:for:) method. If the characteristics of the specified service are successfully discovered, you can access them through the service's characteristics property. If successful, the error parameter is nil. If unsuccessful, the error parameter returns the cause of the failure.
     */
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        guard let characteristics = service.characteristics else {
            return
        }
        for characteristic in characteristics {
            if characteristic.uuid.isEqual(CBUUID(string: mCharacteristic_UUID)){
                myStructure.mCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                
            }
            peripheral.discoverDescriptors(for: characteristic)
        }
    }
    
    // Getting Values From Characteristic
    
    /*After you've found a characteristic of a service that you are interested in, you can read the characteristic's value by calling the peripheral "readValueForCharacteristic" method within the "didDiscoverCharacteristicsFor service" delegate.
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        self.delegate?.readData(characteristic: characteristic, peripheral: peripheral)
        
    }
    
    
    //======= Descriptors
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("\(error.debugDescription)")
            return
        }
        if ((characteristic.descriptors) != nil) {
            for descript in characteristic.descriptors!{
                let mdescript = descript as CBDescriptor?
                print("DidDiscoverDescriptorForChar \(mdescript?.description ?? "")")
            }
        }
    }
    
    // ============= NotificationStateFor
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if (error != nil) {
            print("Error changing notification state:\(error?.localizedDescription ?? "")")
        } else {
            print("Characteristic's value subscribed")
        }
        if (characteristic.isNotifying) {
            print ("Subscribed. Notification has begun for: \(characteristic.uuid)")
        }
    }
    
    
    /*
     Invoked when a connection is successfully created with a peripheral.
     This method is invoked when a call to connect(_:options:) is successful. You typically implement this method to set the peripheral’s delegate and to discover its services.
     */
    //-Connected
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connection complete")
        print("Peripheral info: \(String(describing: peripheral))")
        mPeripheral = peripheral
        centralManager.stopScan()
        //Discovery callback
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        delegate?.setConnect()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected")
        delegate?.setDisconnect()
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print("Error write value for characteristic :\(error?.localizedDescription ?? "")")
            return
        }
        print("Succeeded!")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        guard error == nil else {
            print("Error write value for descriptor :\(error?.localizedDescription ?? ""))")
            return
        }
        print("Succeeded!")
    }
    
    /*
     Invoked when the central manager’s state is updated.
     This is where we kick off the scan if Bluetooth is turned on.
     */
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            // We will just handle it the easy way here: if Bluetooth is on, proceed...start scan!
            print("Bluetooth Enabled")
            
        } else {
            //If Bluetooth is off, display a UI alert message saying "Bluetooth is not enable" and "Make sure that your bluetooth is turned on"
            print("Bluetooth Disabled- Make sure your Bluetooth is turned on")
        }
    }
    
    /**
     Write characteristic value from the peripheral
     - parameter characteristic: The characteristic which user should
     */
    func writeValueForCharacteristic(hex: String, forCharacteristic characteristic: CBCharacteristic){
        if self.mPeripheral == nil {
            return
        }
        print(hex)
        let valueString = Data.init(hexString: hex)
        if ((characteristic.properties.rawValue & CBCharacteristicProperties.write.rawValue) == CBCharacteristicProperties.write.rawValue) {
            self.mPeripheral?.writeValue(valueString!, for: characteristic, type: CBCharacteristicWriteType.withResponse)
        }else {
            self.mPeripheral?.writeValue(valueString!, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
        }
        
    }
    
    /**
     Read characteristic value from the peripheral
     - parameter characteristic: The characteristic which user should
     */
    func readValueForCharacteristic(characteristic: CBCharacteristic) {
        if self.mPeripheral == nil {
            return
        }
        self.mPeripheral?.readValue(for: characteristic)
    }
}


