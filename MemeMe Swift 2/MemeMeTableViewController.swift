//
//  MemeMeTableViewController.swift
//  MemeMe Swift 2
//
//  Created by Ekstasis on 9/29/15.
//  Copyright © 2015 Baxter Heavy Industries. All rights reserved.
//

import UIKit

class MemeMeTableViewController: UITableViewController {

    var sentMemes : [Meme]!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewWillAppear(animated: Bool) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "newMeme")
        tableView.allowsMultipleSelection = false
        refreshTable()
    }
    
    func refreshTable() {
        sentMemes = appDelegate.allMemes
        if sentMemes.isEmpty {
            let editVC = storyboard?.instantiateViewControllerWithIdentifier("MemeEditor")
            presentViewController(editVC!, animated: true, completion: nil)
        }
        tableView.reloadData()
    }
    
    // Triggered by rightBarButtonItem
    func newMeme() {
        let editVC = storyboard?.instantiateViewControllerWithIdentifier("MemeEditor")
        presentViewController(editVC!, animated: true, completion: nil)
    }

    // Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sentMemes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let meme = sentMemes[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("SentMemeTableCell", forIndexPath: indexPath)
            as! MemeTableViewCell
        cell.cellImageView?.image = meme.memedImage
        cell.topText.text = meme.topText
        cell.bottomText.text = meme.bottomText
        
        return cell
    }
    
    // Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let detailVC = storyboard?.instantiateViewControllerWithIdentifier("DetailView") as! MemeMeDetailViewController
        detailVC.memeIndex = indexPath.row
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // Enables deleting
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            appDelegate.allMemes.removeAtIndex(indexPath.row)
            refreshTable()
        }
    }
}