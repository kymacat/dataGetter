//
//  ValuesViewController.swift
//  dataGetter
//
//  Created by Const. on 09.06.2020.
//  Copyright © 2020 Oleginc. All rights reserved.
//

import Cocoa

class ValuesViewController: NSViewController {
    
    var content: String?
    
    
    
    @IBOutlet var contentTextView: NSTextView!
    
    init(content: String) {
        self.content = content
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let content = content {
            contentTextView.string = content
        }
    }
    
    @IBAction func ConfirmButton(_ sender: Any) {
        NSApplication.shared.terminate(nil)
    }
    
}
