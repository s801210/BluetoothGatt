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

extension UIColor
{
    convenience init(hex: Int)
    {
        let rgbValue = hex
        let r = Float((rgbValue & 0xFF0000) >> 16)/255.0
        let g = Float((rgbValue & 0xFF00) >> 8)/255.0
        let b = Float((rgbValue & 0xFF))/255.0
        
        self.init(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: 1.0)
    }
}


extension UILabel {
    func underline() {
        if let textString = self.text {
            let attributedString = NSMutableAttributedString(string: textString)
            attributedString.addAttribute(NSAttributedStringKey.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: NSRange(location: 0, length: attributedString.length))
            attributedText = attributedString
        }
    }
    func disunderline() {
        if let textString = self.text {
            let attributedString = NSMutableAttributedString(string: textString)
            attributedString.addAttribute(NSAttributedStringKey.underlineStyle, value: NSUnderlineStyle.styleNone.rawValue, range: NSRange(location: 0, length: attributedString.length))
            attributedText = attributedString
        }
    }
}



/**
 Replace mainBundle with current language bundle after calling onLanguage
 */
class BundleEx: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        if let bundle = Bundle.getLanguageBundel() {
            return bundle.localizedString(forKey: key, value: value, table: tableName)
            
        }else {
            return super.localizedString(forKey: key, value: value, table: tableName) }
        
    }
    
}
// Change Language
extension Bundle {
    //Replace Bundle.main with custom BundleEx
    private static var onLanguageDispatchOnce: ()->Void = {
        object_setClass(Bundle.main, BundleEx.self)
    }
    func onLanguage(){
        Bundle.onLanguageDispatchOnce()
    }
    class func getLanguageBundel() -> Bundle? {
        
        //Get the system preferred language order
        let languages:[String] = UserDefaults.standard.object(forKey: "AppleLanguages") as! [String]
        let str2:String = languages[0]
        
        //If the preferred language is Chinese, set APP language to Chinese, otherwise set to English
        var str = "en"
        if ((str2.contains("zh-Hans"))||(str2=="zh-Hans"))
        {
            str = "zh-Hans"
        }else  if ((str2.contains("zh-Hant"))||(str2=="zh-Hant"))
        {
            str = "zh-Hant"
        }else
        {
            str = "en"
        }
        UserDefaults.standard.set(str, forKey: "langeuage")
        UserDefaults.standard.synchronize()
        let path = Bundle.main.path(forResource:str , ofType: "lproj") // Get the font in the app
        let languageBundle = Bundle.init(path: path!)
        
        guard languageBundle != nil else {
            return nil
        }
        return languageBundle!
    }
    
}


