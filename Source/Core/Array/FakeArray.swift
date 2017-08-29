//
//  FakeArray.swift
//  FakeFoundation-macOS
//
//  Created by Zhu Shengqi on 27/08/2017.
//

import Foundation


public struct FakeArray<T> {
  
  private var _arrayRef: FakeArrayRef<T>
  
  public init(capacity: Int) {
    _arrayRef = FakeArrayRef<T>(capacity: capacity)
  }
  
  public init() {
    _arrayRef = FakeArrayRef<T>()
  }
  
  public var size: Int {
    return _arrayRef.size
  }
  
  public subscript(_ index: Int) -> T {
    get {
      return _arrayRef[index]
    }
    set {
      if !isKnownUniquelyReferenced(&_arrayRef) {
        _arrayRef = _arrayRef._copy()
      }
      
      _arrayRef[index] = newValue
    }
  }
  
  public mutating func append(_ obj: T) {
    if !isKnownUniquelyReferenced(&_arrayRef) {
      _arrayRef = _arrayRef._copy()
    }
    
    _arrayRef.append(obj)
  }
  
  public mutating func insert(_ obj: T, at Index: Int) {
    if !isKnownUniquelyReferenced(&_arrayRef) {
      _arrayRef = _arrayRef._copy()
    }
    
    _arrayRef.insert(obj, at: Index)
  }
  
  public mutating func remove(at index: Int) {
    if !isKnownUniquelyReferenced(&_arrayRef) {
      _arrayRef = _arrayRef._copy()
    }
    
    _arrayRef.remove(at: index)
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

