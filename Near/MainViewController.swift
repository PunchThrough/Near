//
//  ViewController.swift
//  Near
//
//  Created by LOGAN CAUTRELL on 6/6/17.
//  Copyright © 2017 Punch Through Design LLC. All rights reserved.
//

import UIKit
import CoreNFC

class MainViewController: UIViewController {
    fileprivate let reuseId = "reuseId"

    @IBOutlet weak var tableView: UITableView!
    
    var nfc: NearFieldCommunicator!
    var messagesList = [[NFCNDEFMessage]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        nfc = NearFieldCommunicator(delegate: self)
        tableView.register(MainTableViewCell.self, forCellReuseIdentifier: reuseId)
    }
    
    @IBAction func scanTapped(_ sender: Any) {
        self.nfc.createSession()
    }

    func handleTags(tags: [NFCNDEFMessage]) {
        messagesList.append(tags)
        tableView.reloadData()
    }
}

func string(fromData: Data) -> String {
    return String(data: fromData, encoding: .utf8) ?? "can't decode"
}

extension MainViewController: NFCProtocol {

    func ready() -> Void {
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
        
        // 204 is a raised when a single read is completed.
        guard let err = error as? NSError, err.code != 204 else {
            return
        }
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
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
    public func readerSessionDidBecomeActive(_ session: NFCReaderSession) {
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
    public func readerSession(_ session: NFCReaderSession, didDetect tags: [NFCTag]) {
        print("didDetect tags: \(tags)")
    }
}

extension MainViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath)
        let tags = messagesList[indexPath.row]
        cell.textLabel?.text = formatTagsCount(tags: tags)
        cell.detailTextLabel?.text = formatTagsDetails(tags: tags)
        return cell
    }
    
    func formatTagsCount(tags: [NFCNDEFMessage]) -> String {
        return tags.count == 1 ? "1 Message" : "\(tags.count) Messages"
    }

    func formatTagsDetails(tags: [NFCNDEFMessage]) -> String {
        return tags.reduce("") { (result, message) -> String in
            let messages = message.records.reduce("", { (records, record) -> String in
                return "\(records), \(string(fromTypeNameFormat: record.typeNameFormat))"
            }).dropFirst(2).toString()
            return "\(result), (\(messages))"
        }.dropFirst(2).toString()
    }
}

extension MainViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let details = storyboard?.instantiateViewController(withIdentifier:"DetailsViewController") as? DetailsViewController else {
            print("can't make details view controller")
            return
        }
        details.messages = messagesList[indexPath.row]
        navigationController?.pushViewController(details, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension Substring {
    func toString() -> String {
        return String(self)
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
