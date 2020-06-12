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
    
    func getFilter() -> Set<String> {
        var result = Set<String>()
        findKeys(keys: roots, for: &result)
        return result
    }
    
    private func findKeys(keys: [CodKey], for set: inout Set<String>) {
        for key in keys {
            if !key.state {
                set.insert(key.name)
            }
            if key.childrens.count != 0 {
                findKeys(keys: key.childrens, for: &set)
            }
        }
    }
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
