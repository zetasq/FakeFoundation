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
  
  func testDictionaryDeinit() {
    
    var dictionary: FakeDictionary<NSObject, NSObject>? = FakeDictionary<NSObject, NSObject>()
    
    var key1: NSObject? = NSObject()
    weak var weakKey1 = key1
    
    var value1: NSObject? = NSObject()
    weak var weakValue1 = value1
    
    var key2: NSObject? = NSObject()
    weak var weakKey2 = key2
    
    var value2: NSObject? = NSObject()
    weak var weakValue2 = value2
    
    dictionary?[key1!] = value1
    dictionary?[key2!] = value2
    
    key1 = nil
    value1 = nil
    key2 = nil
    value2 = nil
    
    dictionary = nil
    
    XCTAssert(weakKey1 == nil)
    XCTAssert(weakValue1 == nil)
    XCTAssert(weakKey2 == nil)
    XCTAssert(weakValue2 == nil)
  }
}
