//
//  ReadableJSON.swift
//  dataGetterExtension
//
//  Created by Const. on 01.06.2020.
//  Copyright © 2020 Oleginc. All rights reserved.
//

import Foundation

class ReadableJSON {
    
    static func performJSON(jsonString: String) -> String {
        var readableJSON = "//"
        
        let charSet = CharacterSet(charactersIn: "{},[]")
        var countOfTabs = 0
        
        for char in jsonString {
            if char == "}" {
                readableJSON += "\n// ... \n//}"
                break
            }
            
            if char == "{" {
                countOfTabs += 1
            }
            
            readableJSON += String(char)
            
            if (String(char).rangeOfCharacter(from: charSet) != nil) {
                readableJSON += "\n"
                readableJSON += "//"
                for _ in 0...countOfTabs {
                    readableJSON += "\t"
                }
            }
        }

        return readableJSON
    }
    
}
