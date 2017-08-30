//
//  FakeArray.swift
//  FakeFoundation-macOS
//
//  Created by Zhu Shengqi on 27/08/2017.
//

import Foundation


public struct FakeArray<T> {
  
  private var _arrayBuffer: FakeArrayBuffer<T>
  
  public init(capacity: Int) {
    _arrayBuffer = FakeArrayBuffer<T>(capacity: capacity)
  }
  
  public init() {
    _arrayBuffer = FakeArrayBuffer<T>()
  }
  
  public var size: Int {
    return _arrayBuffer.size
  }
  
  public subscript(_ index: Int) -> T {
    get {
      return _arrayBuffer[index]
    }
    set {
      if !isKnownUniquelyReferenced(&_arrayBuffer) {
        _arrayBuffer = _arrayBuffer._copy()
      }
      
      _arrayBuffer[index] = newValue
    }
  }
  
  public mutating func append(_ obj: T) {
    if !isKnownUniquelyReferenced(&_arrayBuffer) {
      _arrayBuffer = _arrayBuffer._copy()
    }
    
    _arrayBuffer.append(obj)
  }
  
  public mutating func insert(_ obj: T, at Index: Int) {
    if !isKnownUniquelyReferenced(&_arrayBuffer) {
      _arrayBuffer = _arrayBuffer._copy()
    }
    
    _arrayBuffer.insert(obj, at: Index)
  }
  
  public mutating func remove(at index: Int) {
    if !isKnownUniquelyReferenced(&_arrayBuffer) {
      _arrayBuffer = _arrayBuffer._copy()
    }
    
    _arrayBuffer.remove(at: index)
  }
}

extension FakeArray: Sequence {

  public typealias Iterator = AnyIterator<T>
  
  public func makeIterator() -> AnyIterator<T> {
    var index = 0
    
    return AnyIterator<T> {
      if index < self.size {
        let oldIndex = index
        index += 1
        return self[oldIndex]
      } else {
        return nil
      }
    }
  }
}

