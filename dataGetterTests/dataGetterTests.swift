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


    func testConvertFromJsonToStruct() {
    
        let jsonForConvert = String(decoding: readLocalFile(forName: "JsonForTest", with: "json")!, as: UTF8.self)
        let converter = JsonConverter(json: jsonForConvert)
        let result = converter.generateOutput()
        
        let expectedResult = String(decoding: readLocalFile(forName: "ExpectedResult", with: "txt")!, as: UTF8.self)
        

        // In the expected result all the tabs are replaced by spaces, so you need to remove all the tabs and spaces for these two strings
        let clearExpectedResult = expectedResult.replacingOccurrences(of: " ", with: "")
        let clearResult = result.replacingOccurrences(of: "\t", with: "").replacingOccurrences(of: " ", with: "")
        
        XCTAssertEqual(clearExpectedResult, clearResult)
    }
    
    private func readLocalFile(forName name: String, with exten: String) -> Data? {
        let testBundle = Bundle(for: type(of: self))
        guard let ressourceURL = testBundle.url(forResource: name, withExtension: exten) else {
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
