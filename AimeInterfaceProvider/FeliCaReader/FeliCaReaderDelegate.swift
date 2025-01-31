//
//  FeliCaReaderDelegate.swift
//  nfc
//
//  Created by kalan on 2019/10/22.
//  Copyright © 2019 kalan. All rights reserved.
//

public protocol FeliCaReaderDelegate {
    var reader: FeliCaReader? { get }
    
    func readerDidBecomeActive(_ reader: FeliCaReader) -> Void
    func feliCaReader(_ reader: FeliCaReader, withError error: Error) -> Void
    func feliCaReader(_ reader: FeliCaReader, idmpmm card: Data) -> Void
}
