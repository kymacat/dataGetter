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
        var readableJSON = ""
        var isString = false
        
        var countOfTabs = 0
        
        for char in jsonString {
            
            switch char {
            case "{", "[":
                countOfTabs += 1
            case "}", "]":
                countOfTabs -= 1
                readableJSON += "\n"
                addTabs(string: &readableJSON, countOfTabs: countOfTabs)
            case "\"":
                isString = !isString
            default:
                print()
            }
            
            readableJSON += String(char)
            
            if char == "{" || char == "[" || (char == "," && !isString)  {
                readableJSON += "\n"
                addTabs(string: &readableJSON, countOfTabs: countOfTabs)
            }
            
            if char == ":" && !isString {
                readableJSON += " "
            }
        }

        return readableJSON
    }
    
    private static func addTabs(string: inout String, countOfTabs: Int) {
        for _ in 0..<countOfTabs {
            string += "\t"
        }
    }
    
}
