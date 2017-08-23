//
//  NearFieldCommunicator.swift
//  Near
//
//  Created by LOGAN CAUTRELL on 6/6/17.
//  Copyright © 2017 Punch Through Design LLC. All rights reserved.
//

import Foundation
import CoreNFC

typealias NFCCallback = ([NFCNDEFMessage]) -> Void

protocol NFCProtocol: NFCNDEFReaderSessionDelegate {
    func ready() -> Void
}

class NearFieldCommunicator: NSObject {
    var session: NFCNDEFReaderSession!
    let delegate: NFCProtocol

    init(delegate: NFCProtocol) {
        self.delegate = delegate
        super.init()
    }

    func createSession() {
        if let aSession = session {
            aSession.invalidate()
        }
        session = NFCNDEFReaderSession(delegate: delegate, queue: nil, invalidateAfterFirstRead: true)
        self.session.begin()
    }

    func ready() {
        if session.isReady {
            session.begin()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.ready()
            }
        }
    }
}
