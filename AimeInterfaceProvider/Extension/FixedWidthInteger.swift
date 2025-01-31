//
//  Data.swift
//  nfc
//
//  Created by kalan on 2019/10/22.
//  Copyright © 2019 kalan. All rights reserved.
//

import Foundation

extension FixedWidthInteger {
    init(bytes: UInt8...) {
        self.init(bytes: bytes)
    }
    
    init<T: DataProtocol>(bytes: T) {
        let count = bytes.count - 1
        self = bytes.enumerated().reduce(into: 0) { (result, item) in
            result += Self(item.element) << (8 * (count - item.offset))
        }
    }
    
    var data: Data {
        let data = withUnsafeBytes(of: self) { Data($0) }
        return data
    }
}
