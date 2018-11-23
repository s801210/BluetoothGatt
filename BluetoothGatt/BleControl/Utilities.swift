//
//  Utilities.swift
//  BluetoothGatt
//
//  Created by Bill on 2018/6/8.
//  Copyright © 2018 bill. All rights reserved.
//

import UIKit

class Utilities: NSObject {

}

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
    // Data to Hex String
    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let hexDigits = Array((options.contains(.upperCase) ? "0123456789ABCDEF" : "0123456789abcdef").utf16)
        var chars: [unichar] = []
        chars.reserveCapacity(2 * count)
        for byte in self {
            chars.append(hexDigits[Int(byte / 16)])
            chars.append(hexDigits[Int(byte % 16)])
        }
        return String(utf16CodeUnits: chars, count: chars.count)
    }
    // Hex to Data
    init?(hexString: String) {
        let len = hexString.count / 2
        var data = Data(capacity: len)
        for i in 0..<len {
            let j = hexString.index(hexString.startIndex, offsetBy: i*2)
            let k = hexString.index(j, offsetBy: 2)
            let bytes = hexString[j..<k]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
        }
        self = data
    }
    // Data to String
    func ToString() -> String {
        return String(data:self ,encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
    }
}

extension String {

    func isEqualToString(find: String) -> Bool {
        return String(format: self) == find
    }

    func localized(withComment comment: String? = nil) -> String {
        return NSLocalizedString(self, comment: comment ?? "")
    }
    
    func subString(startIndex: Int, endIndex: Int) -> String {
        let end = (endIndex - self.count)
        let indexStartOfText = self.index(self.startIndex, offsetBy: startIndex)
        let indexEndOfText = self.index(self.endIndex, offsetBy: end)
        let substring = self[indexStartOfText..<indexEndOfText]
        return String(substring)
    }

    func replace(target: String, withString: String) -> String{
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }

    func formatHexSpacing() -> String{
        var data = ""
        for i in 0 ..< self.count/2 {
            data = data + self.subString(startIndex: i*2, endIndex: (i+1)*2) + " "
        }
        return data
    }
}
