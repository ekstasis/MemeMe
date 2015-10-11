//
//  MemeTableViewCell.swift
//  MemeMe Swift 2
//
//  Created by Ekstasis on 9/29/15.
//  Copyright © 2015 Baxter Heavy Industries. All rights reserved.
//
import UIKit

class MemeTableViewCell: UITableViewCell {

    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var topText: UILabel!
    @IBOutlet weak var bottomText: UILabel!
    
    /*
    * Fixes an issue where contentView was shifting after cell deletion
    */
    override func layoutSubviews() {
        contentView.frame.size.width = bounds.size.width
        contentView.frame.origin.x = 0
    }

}
