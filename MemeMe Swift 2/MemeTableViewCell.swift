//
//  MemeTableViewCell.swift
//  MemeMe Swift 2
//
//  Created by Ekstasis on 9/29/15.
//  Copyright © 2015 Baxter Heavy Industries. All rights reserved.
//
import UIKit

class MemeTableViewCell: UITableViewCell {

//    @IBOutlet weak var memeImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

//    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
    override func layoutSubviews() {
        print(imageView?.image?.leftCapWidth)
        print(imageView?.image?.topCapHeight)
        imageView?.bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
        imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        imageView?.backgroundColor = UIColor.purpleColor()
    }

}
