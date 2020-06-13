//
//  ValuesViewController.swift
//  dataGetter
//
//  Created by Const. on 09.06.2020.
//  Copyright © 2020 Oleginc. All rights reserved.
//

import Cocoa

class ValuesViewController: NSViewController {
    
    private var readableJson: String!
    private var convertedJson: JsonConverter!
    private var codingTree: CodingKeysTree!
    
    
    @IBOutlet var jsonTextView: NSTextView!
    @IBOutlet weak var outlineView: NSOutlineView!
    
    // MARK: - LifeCycle
    
    init(json: String) {
        if let convertedJson = JsonConverter(json: json) {
            self.convertedJson = convertedJson
            _ = convertedJson.generateOutput()
        } else {
            NSApplication.shared.terminate(nil)
        }
        self.readableJson = ReadableJSON.performJSON(jsonString: json)
        self.codingTree = JsonConverter.codingKeysTree
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let content = readableJson {
            jsonTextView.string = content
            jsonTextView.font = NSFont(name: "Microsoft Sans Serif", size: 14)
            DispatchQueue.global(qos: .userInteractive).async {
                self.setColors(in: content)
            }
        }
        
        outlineView.delegate = self
        outlineView.dataSource = self
    }
    
    // MARK: - Buttons
    
    @IBAction func ConfirmButton(_ sender: Any) {
        convertedJson.filterMode = true
        var output = convertedJson.generateOutput()
        if output == "" {
            output = "cancel"
        }
        DistributedNotificationCenter.default().postNotificationName(
            Notification.Name("dataGetter.applicationWillTerminate"),
            object: output,
            userInfo: nil,
            deliverImmediately: true
        )
        NSApplication.shared.terminate(nil)
    }
    @IBAction func CancelButton(_ sender: Any) {
        NSApplication.shared.terminate(nil)
    }
    
    // MARK: - Work with UI
    
    private func setColors(in string: String) {
        let colorOfKey = NSColor(calibratedRed: 60/255, green: 150/255, blue: 230/255, alpha: 1)
        let colorOfString = NSColor(calibratedRed: 150/255, green: 67/255, blue: 60/255, alpha: 1)
        let colorOfNumbers = NSColor(calibratedRed: 78/255, green: 163/255, blue: 130/255, alpha: 1)
        let nullColor = NSColor(calibratedRed: 255/255, green: 46/255, blue: 125/255, alpha: 1)
        
        var isString = false
        var start = 0
        
        for (index, char) in string.enumerated() {
            
            if char == "\"" {

                if isString {
                    isString = false
                    if string[index+1] == ":" {
                        changeColor(color: colorOfKey, start: start, length: index-start+1)
                    } else {
                        changeColor(color: colorOfString, start: start, length: index-start+1)
                    }
                    
                }
                else {
                    isString = true
                    start = index
                }
                
            }
            
            if char.isNumber && !isString {
                
                if string[index-1] == " " || string[index-1] == "-" {
                    start = index
                    if string[index+1] == "," || string[index+1] == "\n"  { changeColor(color: colorOfNumbers, start: start, length: 1) }
                } else if string[index+1] == "," || string[index+1] == "\n" {
                    changeColor(color: colorOfNumbers, start: start-1, length: index-start+2)
                }
                
            }
            
            if char.isLetter && !isString {
                changeColor(color: nullColor, start: index, length: 1)
            }
            
        }
        
    }
    
    private func changeColor(color: NSColor, start: Int, length: Int) {
        DispatchQueue.main.async {
            self.jsonTextView.setTextColor(color, range: NSMakeRange(start, length))
        }
    }
    
}

// MARK: - OutlineView Data Source

extension ValuesViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let item = item as? CodKey {
            return item.childrens.count
        }
        return codingTree.roots.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let item = item as? CodKey {
            return item.childrens[index]
        }
        return codingTree.roots[index]
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let item = item as? CodKey {
            if item.childrens.count != 0 {
                return true
            }
        }
        return false
    }
}

// MARK: - OutlineView Delegate

extension ValuesViewController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let item = item as? CodKey else {
            return NSView()
        }
        
        let frameRect = NSRect(x: 0, y: 0, width: tableColumn!.width, height: 20)
        let view = ValueCell(frame: frameRect, key: item, parent: outlineView)
        
        return view
    }
    
    func selectionShouldChange(in outlineView: NSOutlineView) -> Bool {
        return false
    }
}



// MARK: - String subscript

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


