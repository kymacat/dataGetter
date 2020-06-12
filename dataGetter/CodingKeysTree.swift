//
//  CodingKeysTree.swift
//  dataGetter
//
//  Created by Const. on 11.06.2020.
//  Copyright © 2020 Oleginc. All rights reserved.
//

import Foundation


class CodingKeysTree {
    var roots: [CodKey] = []
}

class CodKey {
    weak var parent: CodKey?
    var childrens: [CodKey] = []
    
    let name: String
    var state = true
    
    init(with name: String) {
        self.name = name
    }
}
