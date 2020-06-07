//
//  SourceEditorExtension.swift
//  dataGetterExtension
//
//  Created by Const. on 07.05.2020.
//  Copyright © 2020 Oleginc. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorExtension: NSObject, XCSourceEditorExtension {
    func extensionDidFinishLaunching() {
        // If your extension needs to do any work at launch, implement this optional method.
        print("launched!")
    }
}
