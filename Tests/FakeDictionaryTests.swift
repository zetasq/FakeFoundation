//
//  FakeDictionaryTests.swift
//  FakeFoundation-macOS
//
//  Created by Zhu Shengqi on 29/08/2017.
//

import XCTest
@testable import FakeFoundation

class FakeDictionaryTests: XCTestCase {
  
  func testDictionarySubscript() {
    var dictionary = FakeDictionary<String, Int>()
    
    let size = 16
    for i in 0..<size {
      dictionary["\(i)"] = i
      print(dictionary.pp())
    }
    
    for i in 0..<size {
      XCTAssert(dictionary["\(i)"] == i)
    }
    
    for i in stride(from: 0, to: size, by: 2) {
      dictionary["\(i)"] = nil
    }
    
    for i in stride(from: 1, to: size, by: 2) {
      XCTAssert(dictionary["\(i)"] == i)
    }
  }
  
}
