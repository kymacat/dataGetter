//
//  ValueCell.swift
//  dataGetter
//
//  Created by Const. on 12.06.2020.
//  Copyright © 2020 Oleginc. All rights reserved.
//

import Cocoa

class ValueCell: NSTableCellView {
    
    private var codKey: CodKey?
    private var parentOutlineView: NSOutlineView?
    
    var valueNameTextView: NSTextView?
    var checkButton: NSButton?
    
    convenience init(frame: NSRect, key: CodKey, parent: NSOutlineView) {
        self.init(frame: frame)
        parentOutlineView = parent
        codKey = key
        valueNameTextView?.string = key.name
        if key.state {
            checkButton?.state = .on
        } else {
            checkButton?.state = .off
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        valueNameTextView = NSTextView(frame: NSRect(x: 20, y: -3, width: frameRect.width-20, height: frameRect.height))
        valueNameTextView?.isSelectable = false
        valueNameTextView?.backgroundColor = .clear
        self.addSubview(valueNameTextView!)
        
        checkButton = NSButton(frame: NSRect(x: 0, y: 0, width: 20, height: frameRect.height))
        checkButton?.setButtonType(.switch)
        checkButton?.target = self
        checkButton?.action = #selector(changeState(_:))
        self.addSubview(checkButton!)
     }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc func changeState(_ sender: NSButton) {
        guard let codKey = codKey else {
            return
        }
        
        var isSomethingChange = false
        codKey.state.toggle()
        
        if codKey.childrens.count != 0 {
            codKey.setStateToAll(state: codKey.state)
            isSomethingChange = true
        }
        
        if let parent = codKey.parent {
            parent.checkChildrens()
            isSomethingChange = true
        }
        
        if isSomethingChange {
            parentOutlineView?.reloadData()
        }
        
    }
    
}
