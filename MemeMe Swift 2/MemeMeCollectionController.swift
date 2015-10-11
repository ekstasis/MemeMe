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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "newMeme")
        refreshCollection()
//        navigationController?.navigationBarHidden = false
    }
    
    func refreshCollection() {
        sentMemes = appDelegate.allMemes
        collectionView!.reloadData()
    }
    
    func newMeme() {
        let editVC = storyboard?.instantiateViewControllerWithIdentifier("MemeEditor")
        presentViewController(editVC!, animated: true, completion: nil)
    }

    // MARK: - Collection view data source

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sentMemes.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Collection Cell", forIndexPath: indexPath) as! MemeMeCollectionViewCell
        
        print("dequeued cell")

        let meme = sentMemes[indexPath.row]
        
        cell.collectionCellImage.image = meme.memedImage
//        cell.textLabel?.text = meme.topText
//        cell.detailTextLabel?.text = meme.topText
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let detailVC = storyboard?.instantiateViewControllerWithIdentifier("DetailView") as! MemeMeDetailViewController
        
        detailVC.memeIndex = indexPath.row
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
}