//
//  FakeArrayTests.swift
//  FakeFoundation-macOSTests
//
//  Created by Zhu Shengqi on 27/08/2017.
//

import XCTest
@testable import FakeFoundation

class FakeArrayTests: XCTestCase {
  
  func testArrayInsertion() {
    var a = FakeArray<Int>(capacity: 1)
    
    a.insert(0, at: 0)
    
    XCTAssert(a[0] == 0 && a.size == 1)
    
    a.insert(1, at: 1)
    
    XCTAssert(a[0] == 0 && a[1] == 1 && a.size == 2)
    
    a.insert(3, at: 0)
    
    XCTAssert(a[0] == 3 && a[1] == 0 && a[2] == 1 && a.size == 3)
  }
  
  func testArrayDeletion() {
    var a = FakeArray<Int>(capacity: 1)
    
    a.insert(0, at: 0)
    a.insert(1, at: 1)
    a.insert(2, at: 2)
    
    a.remove(at: 2)
    a.remove(at: 0)
    
    XCTAssert(a[0] == 1 && a.size == 1)
  }
  
  func testArrayAppend() {
    var a = FakeArray<Int>(capacity: 1)
    
    a.append(0)
    
    XCTAssert(a[0] == 0 && a.size == 1)
    
    a.append(1)
    
    XCTAssert(a[0] == 0 && a[1] == 1 && a.size == 2)
    
    a.append(2)
    
    XCTAssert(a[0] == 0 && a[1] == 1 && a[2] == 2 && a.size == 3)
  }
  
  func testAppendPerformance() {
    // This is an example of a performance test case.
    self.measure {
      var a = FakeArray<Int>()
      
      for i in 0..<10000 {
        a.append(i)
      }
    }
  }

}

