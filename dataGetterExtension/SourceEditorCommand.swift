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

enum extensionErrors: Error {
    case urlError
    case jsonError
}

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    private var buffer: XCSourceTextBuffer!
    private var completionHandler: ((Error?) -> Void )!
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        
        self.buffer = invocation.buffer
        self.completionHandler = completionHandler
        let range = buffer.selections.firstObject as! XCSourceTextRange
        
        guard range.end.line - range.start.line == 0 else {
            completionHandler(extensionErrors.urlError)
            return
        }
        
        let line = buffer.lines[range.start.line] as! String
        let currLine = String(line[range.start.column..<range.end.column])
        dataRequestFromLine(line: currLine)
        
    }
    
    private func dataRequestFromLine(line: String) {
        
        let currLine = line.replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: nil)
        .replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil)
        
        let potentialURL = currLine
        
        guard let url = URL(string: potentialURL) else {
            completionHandler(extensionErrors.urlError)
            return
        }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                self.completionHandler(error)
            }
            if let data = data {
                if let jsonString = String(data: data, encoding: .utf8) {
                    self.openGUI(with: jsonString)
                } else {
                    self.completionHandler(extensionErrors.jsonError)
                }
            }
        }.resume()
        
    }
    
    private var _applicationWillTerminate: (() -> Void)?
    @objc private func applicationWillTerminate(notification: Notification) {
        _applicationWillTerminate?()
        if let output = notification.object as? String {
            if output == "cancel" {
                completionHandler(nil)
            }
            insertToBuffer(output)
        }
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
            DistributedNotificationCenter.default().removeObserver(self)
        }

        // Open App by URL Scheme
        var c = URLComponents(string: "dataGetter://")!
        c.queryItems = [
            URLQueryItem(name: "json", value: json)
        ]
        NSWorkspace.shared.open(c.url!)
        
        _ = semaphore.wait()

    }
    
    private func insertToBuffer(_ string: String) {
        
        let lineCount = buffer.lines.count
        buffer.lines.insert(string, at: buffer.lines.count)
        let insertedLineCount = buffer.lines.count - lineCount
        
        let selection = XCSourceTextRange(start: XCSourceTextPosition(line: buffer.lines.count, column: 0), end: XCSourceTextPosition(line: buffer.lines.count + insertedLineCount, column: 0))
        buffer.selections.removeAllObjects()
        buffer.selections.insert(selection, at: 0)
        self.completionHandler(nil)
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
