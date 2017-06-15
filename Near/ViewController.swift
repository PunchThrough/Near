//
//  ViewController.swift
//  Near
//
//  Created by LOGAN CAUTRELL on 6/6/17.
//  Copyright © 2017 Punch Through Design LLC. All rights reserved.
//

import UIKit
import CoreNFC

class ViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!

    var nfc: NearFieldCommunicator!
    var count = 0

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(coder:) has not been implemented")
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.text = ""
        nfc = NearFieldCommunicator(delegate: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func goTapped(_ sender: Any) {
        self.nfc.createSession()
    }
    
    func handleTags(tags: [NFCNDEFMessage]) {
        for tag in tags {
            self.textView.text.append("\(tag)\n")
            for record in tag.records {
                self.textView.text.append("  Record:\n")
                self.textView.text.append("    typeNameFormat   : \(string(fromTypeNameFormat: record.typeNameFormat))\n")
                self.textView.text.append("    type             : \(record.type)\n")
                self.textView.text.append("    typeString       : \(string(fromData: record.type))\n")
                self.textView.text.append("    identifier       : \(record.identifier)\n")
                self.textView.text.append("    identifierString : \(string(fromData: record.identifier))\n")
                self.textView.text.append("    payload          : \(record.payload)\n")
                self.textView.text.append("    payloadString    : \(string(fromData: record.payload))\n")
            }
        }
    }
}

func string(fromTypeNameFormat: NFCTypeNameFormat) -> String {
    switch fromTypeNameFormat {
    case .empty:
        return "empty"
    case .nfcWellKnown:
        return "nfcWellKnown"
    case .media:
        return "media"
    case .absoluteURI:
        return "absoluteURI"
    case .nfcExternal:
        return "nfcExternal"
    case . unknown:
        return "unknown"
    case .unchanged:
        return "unchanged"
    }
}

func string(fromData: Data) -> String {
    return String(data: fromData, encoding: .utf8) ?? "can't decode"
}

extension ViewController: NFCProtocol {

    func ready() -> Void {
        self.titleLabel.text = "READY!"
    }

    /*!
     * @method readerSession:didInvalidateWithError:
     *
     * @param session   The session object that is invalidated.
     * @param error     The error indicates the invalidation reason.
     *
     * @discussion      Gets called when a session becomes invalid.  At this point the client is expected to discard
     *                  the returned session object.
     */
    public func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("\(error)")

        self.count = self.count + 1

        DispatchQueue.main.async {
            self.titleLabel.text = "Error \(self.count)"
            self.textView.text.append("errror \(error.localizedDescription)\n")
        }
    }

    /*!
     * @method readerSession:didDetectNDEFs:
     *
     * @param session   The session object used for tag detection.
     * @param messages  Array of @link NFCNDEFMessage @link/ objects. The order of the discovery on the tag is maintained.
     *
     * @discussion      Gets called when the reader detects NFC tag(s) with NDEF messages in the polling sequence.  Polling
     *                  is automatically restarted once the detected tag is removed from the reader's read range.
     */
    public func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        print("\(messages)")
        DispatchQueue.main.async {
            self.handleTags(tags: messages)
        }
    }
    
    
    /*!
     * @method readerSessionDidBecomeActive:
     *
     * @param session   The session object in the active state.
     *
     * @discussion      Gets called when the NFC reader session has become active. RF is enabled and reader is scanning for tags.
     *                  The @link readerSession:didDetectTags: @link/ will be called when a tag is detected.
     */
    public func readerSessionDidBecomeActive(_ session: NFCReaderSession)
    {
        print("readerSessionDidBecomeActive")
        
    }
    
    /*!
     * @method readerSession:didDetectTags:
     *
     * @param session   The session object used for tag detection.
     * @param tags      Array of @link NFCTag @link/ objects.
     *
     * @discussion      Gets called when the reader detects NFC tag(s) in the polling sequence.
     */
    public func readerSession(_ session: NFCReaderSession, didDetect tags: [NFCTag])
    {
        print("didDetect tags: \(tags)")
        
    }
    
}
