//
//  FakeDictionary.swift
//  FakeFoundation-macOS
//
//  Created by Zhu Shengqi on 27/08/2017.
//

import Foundation

public struct FakeDictionary<K: Hashable, V> {
  
  private var _dictionaryBuffer: FakeDictionaryBuffer<K, V>
  
  public init() {
    _dictionaryBuffer = FakeDictionaryBuffer<K, V>()
  }
  
  public subscript(_ key: K) -> V? {
    get {
      return _dictionaryBuffer[key]
    }
    set {
      if !isKnownUniquelyReferenced(&_dictionaryBuffer) {
        _dictionaryBuffer = _dictionaryBuffer.copy()
      }
      
      _dictionaryBuffer[key] = newValue
    }
  }
  
  public func pp() -> [String] {
    return _dictionaryBuffer.pp()
  }
}
