//
//  FeliCaCard.swift
//  nfc
//
//  Created by kalan on 2019/10/22.
//  Copyright © 2019 kalan. All rights reserved.
//

import Foundation
import CoreNFC
// https://www.wdic.org/w/RAIL/%E3%82%B5%E3%82%A4%E3%83%90%E3%83%8D%E8%A6%8F%E6%A0%BC%20(IC%E3%82%AB%E3%83%BC%E3%83%89)

enum PaymentType: UInt, CaseIterable {
    case normal = 0x00
    case creditCard = 0x0c
    case pasmo = 0x0d
    case nimoca = 0x13
    case mobileApp = 0x3f
}

public struct FeliCaCard {
    var balance: Int?
    var entryExitHistory: [History]
    
    var systemCode: String?
    var idm: String?
    
    public init(_ dataList: [Data], _ idm: Data, _ systemCode: Data) {
        self.entryExitHistory = []

        for data in dataList {
            let paymentType = PaymentType.allCases.first(where: { UInt8($0.rawValue) == data[2] })
            
            let his = History(
                machineType: UInt16(data[0]),
                usageType: UInt16(data[1]),
                paymentType: String(describing: paymentType),
                entryExitType: UInt16(data[3]),
                entryStationCode: UInt16(bytes: data[6...7]),
                exitStationCode: UInt16(bytes: data[8...9]),
                date: convertToDate(data),
                balance: UInt(bytes: data[10...11].reversed())
            )

            self.entryExitHistory.append(his)
        }
        self.setIdm(idm: idm)
        self.setSystemCode(systemCode: systemCode)
    }
    
    private func convertToDate(_ data: Data) -> Date! {
        let year = data[4] >> 1
        let month = UInt(bytes: data[4...5]) >> 5 & 0b1111
        let date = data[5] & 0b11111
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: "20\(year)-\(month)-\(date)")!
    }
    
    mutating func setIdm(idm: Data) {
        self.idm = idm.map { String(format: "%2hhx", $0) }.joined()
    }
    
    mutating func setSystemCode(systemCode: Data) {
        self.systemCode = systemCode.map { String(format: "%2hhx", $0) }.joined()
    }
}


public struct History {
    let machineType: UInt16
    let usageType: UInt16
    let paymentType: String
    let entryExitType: UInt16
    let entryStationCode: UInt16
    let exitStationCode: UInt16
    let date: Date
    let balance: UInt?
}
