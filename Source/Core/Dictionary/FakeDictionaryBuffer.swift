//
//  FakeDictionaryRef.swift
//  FakeFoundation-macOS
//
//  Created by Zhu Shengqi on 27/08/2017.
//

import Foundation

private let MAX_LOAD_INVERSE = 1.0 / 0.75


final class FakeDictionaryBuffer<K: Hashable, V> {
  
  private var _capacityExp: Int // capacity == 1 << _capacityExp
  
  private var _size: Int
  
  private var _bits: UnsafeMutablePointer<UInt8> // size / 8
  
  private var _ptrToKeys: UnsafeMutablePointer<K>
  
  private var _ptrToValues: UnsafeMutablePointer<V>
  
  init() {
    _capacityExp = 3
    _size = 0
    
    _bits = UnsafeMutablePointer<UInt8>.allocate(capacity: (1 << _capacityExp) / 8)
    _bits.initialize(to: 0, count: (1 << _capacityExp) / 8)
    
    _ptrToKeys = UnsafeMutablePointer<K>.allocate(capacity: (1 << _capacityExp))
    
    _ptrToValues = UnsafeMutablePointer<V>.allocate(capacity: (1 << _capacityExp))
  }
  
  deinit {
    for i in 0..<(1 << _capacityExp) {
      if !_isHole(at: i) {
        (_ptrToKeys+i).deinitialize()
        (_ptrToValues+i).deinitialize()
      }
    }
    
    _bits.deinitialize(count: (1 << _capacityExp) / 8)

    _bits.deallocate(capacity: (1 << _capacityExp) / 8)
    _ptrToKeys.deallocate(capacity: (1 << _capacityExp))
    _ptrToValues.deallocate(capacity: (1 << _capacityExp))
  }
  
  func copy() -> FakeDictionaryBuffer<K, V> {
    let newDictionaryRef = FakeDictionaryBuffer<K, V>()
    
    for i in 0..<(1 << _capacityExp) {
      if !_isHole(at: i) {
        newDictionaryRef[_ptrToKeys[i]] = _ptrToValues[i]
      }
    }
    
    return newDictionaryRef
  }
  
  // MARK: - Bits functions
  private func _next(forIndex index: Int) -> Int {
    return (index + 1) % (1 << _capacityExp)
  }
  
  private func _prev(forIndex index: Int) -> Int {
    if index > 0 {
      return index - 1
    } else {
      return (1 << _capacityExp) - 1
    }
  }
  
  private func _isHole(at index: Int) -> Bool {
    let byteIdx = index / 8
    let offset = index % 8
    
    let targetByte = _bits[byteIdx]
    let result = targetByte & (1 << offset)
    
    return result == 0
  }
  
  private func set(bit: Bool, at index: Int) {
    let byteIdx = index / 8
    let offset = index % 8
    
    var targetByte = _bits[byteIdx]
    if bit {
      // set 1
      let mask: UInt8 = 1 << offset
      targetByte |= mask
    } else {
      // set 0
      let mask: UInt8 = ~(1 << offset)
      targetByte &= mask
    }
    
    _bits[byteIdx] = targetByte
  }
  
  // MARK: - Keys and Values functions
  private func _find(key: K) -> V? {
    let squeezedHashValue = key.hashValue.squeezedValue(forBinaryLength: _capacityExp)
    
    var idx = squeezedHashValue
    
    while true {
      guard !_isHole(at: idx) else {
        return nil
      }
      
      let keyForIdx = _ptrToKeys[idx]
      if keyForIdx == key {
        return _ptrToValues[idx]
      }
      
      idx = _next(forIndex: idx)
    }
  }
  
  private func _clear(key: K) {
    let squeezedHashValue = key.hashValue.squeezedValue(forBinaryLength: _capacityExp)
    
    var idx = squeezedHashValue
    
    while true {
      guard !_isHole(at: idx) else {
        return
      }
      
      let keyForIdx = _ptrToKeys[idx]
      if keyForIdx == key {
        set(bit: false, at: idx)
        _size -= 1
        (_ptrToKeys+idx).deinitialize()
        (_ptrToValues+idx).deinitialize()
        
        while true {
          let nextIdx = _next(forIndex: idx)
          guard !_isHole(at: nextIdx) else {
            break
          }
          
          guard _ptrToKeys[nextIdx].hashValue.squeezedValue(forBinaryLength: _capacityExp) != nextIdx else {
            break
          }
          
          (_ptrToKeys+idx).initialize(to: _ptrToKeys[nextIdx])
          (_ptrToValues+idx).initialize(to: _ptrToValues[nextIdx])
          set(bit: true, at: idx)
          
          (_ptrToKeys+nextIdx).deinitialize()
          (_ptrToValues+nextIdx).deinitialize()
          set(bit: false, at: nextIdx)
          
          idx = nextIdx
        }
        
        return
      }
      
      idx = _next(forIndex: idx)
    }
  }
  
  private func _doubleCapacity() {
    var kvPairs: [(K, V)] = []
    
    for i in 0..<(1 << _capacityExp) {
      if !_isHole(at: i) {
        kvPairs.append((_ptrToKeys[i], _ptrToValues[i]))
        
        (_ptrToKeys+i).deinitialize()
        (_ptrToValues+i).deinitialize()
      }
    }
    
    _ptrToKeys.deallocate(capacity: (1 << _capacityExp))
    _ptrToValues.deallocate(capacity: (1 << _capacityExp))
    
    _bits.deinitialize(count: (1 << _capacityExp) / 8)
    _bits.deallocate(capacity: (1 << _capacityExp) / 8)
    
    _size = 0
    _capacityExp += 1
    
    _bits = UnsafeMutablePointer<UInt8>.allocate(capacity: (1 << _capacityExp) / 8)
    _bits.initialize(to: 0, count: (1 << _capacityExp) / 8)
    
    _ptrToKeys = UnsafeMutablePointer<K>.allocate(capacity: (1 << _capacityExp))
    _ptrToValues = UnsafeMutablePointer<V>.allocate(capacity: (1 << _capacityExp))
    
    for (key, value) in kvPairs {
      _insert(value, forKey: key)
    }
  }
  
  private func _insert(_ value: V, forKey key: K) {
    let squeezedHashValue = key.hashValue.squeezedValue(forBinaryLength: _capacityExp)
    
    var idx = squeezedHashValue
    
    while true {
      if _isHole(at: idx) {
        set(bit: true, at: idx)
        _size += 1
        
        (_ptrToKeys+idx).initialize(to: key)
        (_ptrToValues+idx).initialize(to: value)
        
        break
      }
      
      idx = _next(forIndex: idx)
    }
  }
  
  // MARK: - API methods
  subscript(_ key: K) -> V? {
    get {
      return _find(key: key)
    }
    set {
      if let value = newValue {
        if Double(1 << _capacityExp) / Double(_size) < MAX_LOAD_INVERSE {
          _doubleCapacity()
        }
        _insert(value, forKey: key)
      } else {
        _clear(key: key)
      }
    }
  }
  
  func pp() -> [String] {
    var result: [String] = []
    for i in 0..<(1 << _capacityExp) {
      if _isHole(at: i) {
        result.append("\(i): hole")
      } else {
        result.append("\(i): \(_ptrToKeys[i]) => \(_ptrToValues[i])")
      }
    }
    return result
  }
}

