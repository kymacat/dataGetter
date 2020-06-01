//
//  JsonConverter.swift
//  dataGetterExtension
//
//  Created by Const. on 02.06.2020.
//  Copyright © 2020 Oleginc. All rights reserved.
//

import Foundation

class JsonConverter {
    
    var dictinary: [String: Any]?
    
    init() {
    }
    
    init(json: String) {
        if let dictinary = json.jsonObject as? [String: Any] {
            self.dictinary = dictinary
        }
    }
    
    func generateOutput(with name: String) -> String {
        var result = ""
        
        if let dictinary = dictinary {
            
            result += "\nstruct \(name) : Codable {\n"
            var sublayers: [String] = []
            
            
            for (key, value) in dictinary {
                let currType = identifyType(objc: value)
                
                if currType != "Any" {
                    result += "\tlet \(key): \(currType)\n"
                } else if let sublayer = value as? [Any] {
                    if let subDictinary = sublayer.first as? [String: Any] {
                        let newConverter = JsonConverter()
                        newConverter.dictinary = subDictinary
                        sublayers.append(newConverter.generateOutput(with: key))
                        result += "\tlet \(key): [\(key)]\n"
                    }
                }
                
            }
            
            result += "}\n\n"
            
            for sublayer in sublayers {
                result += sublayer
            }
            
        }
        
        
        return result
    }
    
    private func identifyType(objc: Any) -> String {
        switch objc {
        case is String:
            return "String"
        case is NSNumber:
            if let number = objc as? NSNumber {
                return number.valueType
            } else {
                return "Any"
            }
        default:
            return "Any"
        }
    }
}


extension NSNumber {
    
    var valueType: String {
        let typeStr: String
        
        if type(of: self) == type(of: NSNumber(value: true)) {
            typeStr = "Bool"
        } else if "\(self)".contains(".") {
            typeStr = "Double"
        } else {
            typeStr = "Int"
        }
        return typeStr
    }
    
}

extension String {
    
    internal var jsonObject: Any? {
        let jsonData = self.data(using: .utf8)!
        return try? JSONSerialization.jsonObject(with: jsonData, options: [])
    }

}
