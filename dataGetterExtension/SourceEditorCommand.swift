//
//  SourceEditorCommand.swift
//  dataGetterExtension
//
//  Created by Const. on 07.05.2020.
//  Copyright © 2020 Oleginc. All rights reserved.
//

import Foundation
import XcodeKit
import Cocoa

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
                    
                    let converter = JsonConverter(json: jsonString)
                    let convertedJson = converter.generateOutput(with: "<#Enter your name#>")
                    

                    let readableJson = ReadableJSON.performJSON(jsonString: jsonString)
                    
                    self.openGUI(with: convertedJson)
                    
                    //self.insertToBuffer(readableJson, to: buffer)
                    self.insertToBuffer(convertedJson, to: buffer)
                    completionHandler(nil)
                    
                } else {
                    self.insertToBuffer("Something wrong with JSON", to: buffer)
                    completionHandler(nil)
                    
                }
            }
        }.resume()
        
    }
    
    private var _applicationWillTerminate: (() -> Void)?
    @objc private func applicationWillTerminate(notification: Notification) {
        _applicationWillTerminate?()
        print(notification.object as! String)
    }
    
    private func openGUI(with json: String) {
        let semaphore = DispatchSemaphore(value: 0)


        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(SourceEditorCommand.applicationWillTerminate(notification:)),
            name: Notification.Name("dataGetter.applicationWillTerminate"),
            object: nil,
            suspensionBehavior: .deliverImmediately
        )
        _applicationWillTerminate = {
            semaphore.signal()
        }

        // Open App via URL Scheme
        var c = URLComponents(string: "dataGetter://")!
        c.queryItems = [
            URLQueryItem(name: "title", value: json)
        ]
        NSWorkspace.shared.open(c.url!)
        
        _ = semaphore.wait()

        DistributedNotificationCenter.default().removeObserver(self)
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
