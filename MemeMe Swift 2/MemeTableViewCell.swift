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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

//    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
    override func layoutSubviews() {
        contentView.frame.size.width = bounds.size.width
        contentView.frame.origin.x = 0
    }

}
