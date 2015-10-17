//
//  CustomMenuCell.swift
//  Ohel Shem
//
//  Created by Lior Pollak on 1/2/15.
//  Copyright (c) 2015 Lior Pollak. All rights reserved.
//

import Foundation
import UIKit

class CustomMenuCell: UITableViewCell {
    //MARK: UITableViewCell Methods
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if (highlighted) {
            self.textLabel?.textColor = UIColor.whiteColor()
        } else {
            self.textLabel?.textColor = UIColor.blackColor()
        }
    }
}
