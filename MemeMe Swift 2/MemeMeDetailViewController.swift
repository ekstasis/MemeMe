//
//  MemeMeDetailViewController.swift
//  MemeMe Swift 2
//
//  Created by Ekstasis on 9/29/15.
//  Copyright © 2015 Baxter Heavy Industries. All rights reserved.
//

import UIKit

class MemeMeDetailViewController: UIViewController {

    @IBOutlet weak var memeImageView: UIImageView!
    
    var memeImage : UIImage!
    
    override func viewWillAppear(animated: Bool) {
        memeImageView.image = memeImage
        tabBarController?.tabBar.hidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        tabBarController?.tabBar.hidden = false
    }
}
