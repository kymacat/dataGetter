//
//  EnableViewController.swift
//  dataGetter
//
//  Created by Const. on 18.06.2020.
//  Copyright © 2020 Oleginc. All rights reserved.
//

import Cocoa

class EnableViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func enableExtensionButtonAction(_ sender: NSButton) {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preferences") {
            NSWorkspace.shared.open(url)
        }
    }
    
    
    @IBAction func gitHubButtonAction(_ sender: NSButton) {
        if let url = URL(string: "https://github.com/kymacat/dataGetter") {
            NSWorkspace.shared.open(url)
        }
    }
    
}
