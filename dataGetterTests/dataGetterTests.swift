//
//  dataGetterTests.swift
//  dataGetterTests
//
//  Created by Const. on 03.06.2020.
//  Copyright © 2020 Oleginc. All rights reserved.
//

import XCTest
@testable import dataGetter

class dataGetterTests: XCTestCase {


    func testConvertFromJsonToStruct() throws {
        //let converter = JsonConverter()
        let a = String(decoding: readLocalFile(forName: "JsonForTest")!, as: UTF8.self)
        
        XCTAssertEqual(a, "shit\n")
    }
    
    private func readLocalFile(forName name: String) -> Data? {
        let testBundle = Bundle(for: type(of: self))
        guard let ressourceURL = testBundle.url(forResource: name, withExtension: "json") else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: ressourceURL)
            return data
        } catch let error {
            print(error.localizedDescription)
            return nil
        }

    }

}
