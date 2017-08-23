//
//  TableViewCell.swift
//  Near
//
//  Created by LOGAN CAUTRELL on 8/23/17.
//  Copyright © 2017 Punch Through Design LLC. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
