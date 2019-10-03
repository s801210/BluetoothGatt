//
//  UUIDKey.swift
//  BluetoothGatt
//
//  Created by Bill on 2018/6/6.
//  Copyright © 2018 bill. All rights reserved.
//

import CoreBluetooth

let mService_UUID = "0000E0FF-3C17-D293-8E48-14FE2E4DA212"
let mCharacteristic_UUID = "0000FFE1-0000-1000-8000-00805F9B34FB"



class mStructure: NSObject
{
    var mService:CBService?
    var mCharacteristic: CBCharacteristic?
}
