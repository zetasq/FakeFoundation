//
//  FakeArrayRef.swift
//  FakeFoundation-macOS
//
//  Created by Zhu Shengqi on 27/08/2017.
//

import Foundation

private let ARRAY_INITIAL_SIZE = 8

extension FakeArray {
  final class FakeArrayRef<T> {
    
    private var _capicity: Int
    private var _size: Int
    
    private var _p: UnsafeMutablePointer<T>
    
    init(capacity: Int = ARRAY_INITIAL_SIZE) {
      self._capicity = Swift.max(capacity, ARRAY_INITIAL_SIZE)
      self._size = 0
      
      self._p = UnsafeMutablePointer<T>.allocate(capacity: self._capicity)
    }
    
    deinit {
      _p.deinitialize(count: _size)
      _p.deallocate(capacity: _capicity)
    }
    
    func _copy() -> FakeArrayRef {
      let newRef = FakeArrayRef(capacity: _capicity)
      
      for i in 0..<size {
        (newRef._p+i).initialize(to: _p[i])
      }
      
      newRef._size = self._size
      
      return newRef
    }
    
    var size: Int {
      return _size
    }
    
    subscript(index: Int) -> T {
      get {
        precondition(0 <= index && index < _size, "Invalid index to insert: \(index)")
        
        return _p[index]
      }
      set {
        precondition(0 <= index && index < _size, "Invalid index to insert: \(index)")
        
        _p[index] = newValue
      }
    }
    
    func append(_ obj: T) {
      insert(obj, at: _size)
    }
    
    func insert(_ obj: T, at index: Int) {
      precondition(0 <= index && index <= _size, "Invalid index to insert: \(index)")
      
      if _size == _capicity {
        let newP = UnsafeMutablePointer<T>.allocate(capacity: _capicity * 2)
        
        for i in 0..<_size {
          (newP+i).initialize(to: _p[i])
        }
        
        _p.deinitialize(count: _size)
        _p.deallocate(capacity: _size)
        
        _p = newP
        _capicity *= 2
      }
      
      for i in stride(from: _size - 1, through: index, by: -1) {
        if i == _size - 1 {
          (_p+_size).initialize(to: _p[_size-1])
        } else {
          _p[i+1] = _p[i]
        }
      }
      
      if index < _size {
        _p[index] = obj
      } else {
        (_p+_size).initialize(to: obj)
      }
      
      _size += 1
    }
    
    func remove(at index: Int) {
      precondition(0 <= index && index < _size, "Invalid index to insert: \(index)")
      
      for i in index+1..<_size {
        _p[i-1] = _p[i]
      }
      
      (_p+_size-1).deinitialize(count: 1)
      _size -= 1
    }
  }
}
