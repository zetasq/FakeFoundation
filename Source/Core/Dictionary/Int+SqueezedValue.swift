//
//  Int+SqueezedValue.swift
//  FakeFoundation-macOS
//
//  Created by Zhu Shengqi on 29/08/2017.
//

import Foundation

extension Int {
  func squeezedValue(forBinaryLength length: Int) -> Int {
    let mask = (1 << length) - 1
    return self & mask
  }
}
