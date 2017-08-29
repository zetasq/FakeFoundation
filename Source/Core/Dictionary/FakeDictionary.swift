//
//  FakeDictionary.swift
//  FakeFoundation-macOS
//
//  Created by Zhu Shengqi on 27/08/2017.
//

import Foundation

public struct FakeDictionary<K: Hashable, V> {
  
  private var _dictionaryRef: FakeDictionaryRef<K, V>
  
  public init() {
    _dictionaryRef = FakeDictionaryRef<K, V>()
  }
  
  public subscript(_ key: K) -> V? {
    get {
      return _dictionaryRef[key]
    }
    set {
      if !isKnownUniquelyReferenced(&_dictionaryRef) {
        _dictionaryRef = _dictionaryRef.copy()
      }
      
      _dictionaryRef[key] = newValue
    }
  }
  
  public func pp() -> [String] {
    return _dictionaryRef.pp()
  }
}
