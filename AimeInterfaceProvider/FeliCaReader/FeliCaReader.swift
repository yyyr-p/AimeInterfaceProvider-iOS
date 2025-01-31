//
//  FeliCaReader.swift
//  nfc
//
//  Created by kalan on 2019/10/22.
//  Copyright © 2019 kalan. All rights reserved.
//

import CoreNFC
import Foundation


public enum FeliCaTagError: Error {
    case countExceed
    case typeMismatch
    case statusError
    case userCancel
    case becomeInvalidate
    case cannotConnect
}

@available(iOS 13.0, *)
public class FeliCaReader: NSObject, NFCTagReaderSessionDelegate {
    internal var session: NFCTagReaderSession?
    internal let delegate: FeliCaReaderDelegate?
    
    private override init() {
        self.delegate = nil
    }
    
    public init(delegate: FeliCaReaderDelegate) {
        self.delegate = delegate
    }
    
    public func beginSession() {
        self.session = NFCTagReaderSession(pollingOption: .iso18092, delegate: self)
        self.session?.alertMessage = "将 Aime 卡片靠近"
        self.session?.begin()
    }

    public func isReadingAvailable() -> Bool {
        return NFCTagReaderSession.readingAvailable
    }
    
    public func finish(errorMessage: String?) {
        if errorMessage != nil {
            self.session?.invalidate()
        } else {
            self.session?.invalidate(errorMessage: errorMessage!)
        }
    }

    public func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        print("tagReaderSessionDidBecomeActive(_:)")
        self.delegate?.readerDidBecomeActive(self)
    }

    public func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        if let readerError = error as? NFCReaderError {
            if (readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead)
                && (readerError.code != .readerSessionInvalidationErrorUserCanceled) {
                self.delegate?.feliCaReader(self, withError: FeliCaTagError.becomeInvalidate)
            }
        }
        self.session = nil
    }

    public func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        if tags.count > 1 {
            self.delegate?.feliCaReader(self, withError: FeliCaTagError.countExceed)
            return
        }
        
        let tag = tags.first!
        
        session.connect(to: tag) { (error) in
            guard error == nil else {
                session.invalidate(errorMessage: "Failed to connect")
                self.delegate?.feliCaReader(self, withError: FeliCaTagError.cannotConnect)
                return
            }
            
            guard case .feliCa(let feliCaTag) = tag else {
                self.delegate?.feliCaReader(self, withError: FeliCaTagError.typeMismatch)
                return
            }
            
            feliCaTag.polling(systemCode: feliCaTag.currentSystemCode, requestCode: NFCFeliCaPollingRequestCode.systemCode, timeSlot: NFCFeliCaPollingTimeSlot.max1, completionHandler: { (pmm, requestData, error) in
                if error != nil {
                    self.delegate?.feliCaReader(self, withError: FeliCaTagError.statusError)
                    return
                }
                var data = feliCaTag.currentIDm
                data.append(pmm)
                self.delegate?.feliCaReader(self, idmpmm: data)
            })
        }
    }
}
