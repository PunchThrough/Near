//
//  DetailsViewController.swift
//  Near
//
//  Created by LOGAN CAUTRELL on 8/23/17.
//  Copyright © 2017 Punch Through Design LLC. All rights reserved.
//

import UIKit
import CoreNFC

let reuseId = "reuseId"

class DetailsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var messages = [NFCNDEFMessage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseId)
        tableView.rowHeight = 25.0
        tableView.reloadData()
    }
}

extension DetailsViewController : UITableViewDataSource {
    
    func messageAndRecord(atSection section: Int) -> (NFCNDEFMessage, NFCNDEFPayload)? {
        var counter = 0
        for message in messages {
            for record in message.records {
                if counter == section {
                    return (message, record)
                }
                counter = counter + 1
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let messageRecord = messageAndRecord(atSection: section)
        guard let message = messageRecord?.0, let record = messageRecord?.1 else {
            return nil
        }
        return "Message \(messages.index(of: message) ?? 0) : Record \(message.records.index(of: record) ?? 0)"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return messages.reduce(0) { (count, message) -> Int in
            return count + message.records.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath)
        cell.textLabel?.font = UIFont(name: "Menlo-Regular", size: 11.0)
        guard let record = messageAndRecord(atSection: indexPath.section)?.1 else {
            return cell
        }
        
        let index = indexPath.row % 7
        switch index {
        case 0:
            cell.textLabel?.text = "typeNameFormat   : \(string(fromTypeNameFormat: record.typeNameFormat))"
        case 1:
            cell.textLabel?.text = "type             : \(record.type)"
        case 2:
            cell.textLabel?.text = "typeString       : \(string(fromData: record.type))"
        case 3:
            cell.textLabel?.text = "identifier       : \(record.identifier)"
        case 4:
            cell.textLabel?.text = "identifierString : \(string(fromData: record.identifier))"
        case 5:
            cell.textLabel?.text = "payload          : \(record.payload)"
        case 6:
            cell.textLabel?.text = "payloadString    : \(string(fromData: record.payload))"
        default:
            cell.textLabel?.text = "invalid"
        }
        return cell
    }
}


