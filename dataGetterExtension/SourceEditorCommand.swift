//
//  SourceEditorCommand.swift
//  dataGetterExtension
//
//  Created by Const. on 07.05.2020.
//  Copyright © 2020 Oleginc. All rights reserved.
//

import Foundation
import XcodeKit

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

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        
        let range = invocation.buffer.selections.firstObject as! XCSourceTextRange
        
        guard range.end.line - range.start.line == 0 else {
            completionHandler("The URL can be in only one row" as? Error)
            return
        }
        
        let line = invocation.buffer.lines[range.start.line] as! String
        
        var currLine = String(line[range.start.column..<range.end.column])
        currLine = currLine.replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: nil)
        .replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil)
        
        let potentialURL = currLine
        
        guard let url = URL(string: potentialURL) else {
            completionHandler("invalid URL" as? Error)
            return
        }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            }
            if let data = data {
                if let jsonString = String(data: data, encoding: .utf8) {
                    print(jsonString)
                }
            }
        }.resume()
        
        completionHandler(nil)
    }
    
}
