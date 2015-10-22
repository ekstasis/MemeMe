//
//  MemeMeCollectionController.swift
//  MemeMe Swift 2
//
//  Created by Ekstasis on 9/29/15.
//  Copyright © 2015 Baxter Heavy Industries. All rights reserved.
//

import UIKit

class MemeMeCollectionController: UICollectionViewController {

    @IBOutlet weak var cellImage: UIImageView!
    
    var sentMemes : [Meme]!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "newMeme")
        refreshCollection()
    }
    
    func refreshCollection() {
        sentMemes = appDelegate.allMemes
        collectionView!.reloadData()
    }
    
    func newMeme() {
        let editVC = storyboard?.instantiateViewControllerWithIdentifier("MemeEditor")
        presentViewController(editVC!, animated: true, completion: nil)
    }

    // Collection view data source

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        super.collectionView(collectionView, numberOfItemsInSection: section)
        return sentMemes.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        super.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
        
        let meme = sentMemes[indexPath.row]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Collection Cell", forIndexPath: indexPath) as! MemeMeCollectionViewCell
        cell.collectionCellImage.image = meme.memedImage
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        super.collectionView(collectionView, didSelectItemAtIndexPath: indexPath)
        
        let detailVC = storyboard?.instantiateViewControllerWithIdentifier("DetailView") as! MemeMeDetailViewController
        detailVC.memeIndex = indexPath.row
        navigationController?.pushViewController(detailVC, animated: true)
    }
}