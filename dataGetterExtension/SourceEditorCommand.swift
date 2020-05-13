//
//  SourceEditorCommand.swift
//  dataGetterExtension
//
//  Created by Const. on 07.05.2020.
//  Copyright © 2020 Oleginc. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        
        let buffer = invocation.buffer
        let range = buffer.selections.firstObject as! XCSourceTextRange
        
        
        guard range.end.line - range.start.line == 0 else {
            insertToBuffer("The URL can be in only one row", to: buffer)
            completionHandler(nil)
            return
        }
        
        
        dataRequestFromLine(buffer: buffer, range: range, completionHandler: completionHandler)
        
    }
    
    private func dataRequestFromLine(buffer: XCSourceTextBuffer, range: XCSourceTextRange,  completionHandler: @escaping (Error?) -> Void) {
        
        let line = buffer.lines[range.start.line] as! String
        
        var currLine = String(line[range.start.column..<range.end.column])
        
        currLine = currLine.replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: nil)
        .replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil)
        
        let potentialURL = currLine
        
        guard let url = URL(string: potentialURL) else {
            insertToBuffer("invalid URL", to: buffer)
            completionHandler(nil)
            return
        }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                self.insertToBuffer(error.localizedDescription, to: buffer)
                completionHandler(nil)
            }
            if let data = data {
                if let jsonString = String(data: data, encoding: .utf8) {
                    
                    let readableJson = self.performJSON(jsonString: jsonString)
                    self.insertToBuffer(readableJson, to: buffer)
                    
                    
                    let appSettings = AppSettings()
                    if let property = JSONProperty(from: jsonString, appSettings: appSettings) {
                        let lineIndent = LineIndent(useTabs: buffer.usesTabsForIndentation, indentationWidth: buffer.indentationWidth, level: 0)
                        let output = property.generateOutput(lineIndent: lineIndent)
                        self.insertToBuffer(output, to: buffer)
                    }
                    
                    completionHandler(nil)
                    
                } else {
                    self.insertToBuffer("Something wrong with JSON", to: buffer)
                    completionHandler(nil)
                    
                }
            }
        }.resume()
        
    }
    
    private func performJSON(jsonString: String) -> String {
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
    
    private func insertToBuffer(_ string: String, to buffer: XCSourceTextBuffer) {
        
        let lineCount = buffer.lines.count
        buffer.lines.insert(string, at: buffer.lines.count)
        let insertedLineCount = buffer.lines.count - lineCount
        
        let selection = XCSourceTextRange(start: XCSourceTextPosition(line: buffer.lines.count, column: 0), end: XCSourceTextPosition(line: buffer.lines.count + insertedLineCount, column: 0))
        buffer.selections.removeAllObjects()
        buffer.selections.insert(selection, at: 0)
    }
    
}

extension StringProtocol {
    subscript(offset: Int) -> Character { self[index(startIndex, offsetBy: offset)] }
    subscript(range: Range<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: ClosedRange<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: PartialRangeFrom<Int>) -> SubSequence { self[index(startIndex, offsetBy: range.lowerBound)...] }
    subscript(range: PartialRangeThrough<Int>) -> SubSequence { self[...index(startIndex, offsetBy: range.upperBound)] }
    subscript(range: PartialRangeUpTo<Int>) -> SubSequence { self[..<index(startIndex, offsetBy: range.upperBound)] }
}
