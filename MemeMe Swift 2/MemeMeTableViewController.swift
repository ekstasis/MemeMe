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
    
    // Necessary to allow Cancel button before image picked
    var tableEmptyAfterLaunch = true

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "newMeme")
        navigationItem.leftBarButtonItem = editButtonItem()
        
        refreshTable()
        
        setEditing(false, animated: true)

        navigationItem.leftBarButtonItem!.enabled = !sentMemes.isEmpty
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // EditVC should present after initial empty launch with empty table
        if tableEmptyAfterLaunch {
            let editVC = storyboard?.instantiateViewControllerWithIdentifier("MemeEditor")
            tabBarController?.presentViewController(editVC!, animated: true, completion: nil)
            tableEmptyAfterLaunch = false
        }
    }
    
    func refreshTable() {
        sentMemes = appDelegate.allMemes
        guard sentMemes != nil else {
            return
        }
        tableView.reloadData()
    }
    
    // Triggered by rightBarButtonItem
    func newMeme() {
        let editVC = storyboard?.instantiateViewControllerWithIdentifier("MemeEditor")
        presentViewController(editVC!, animated: true, completion: nil)
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        tableView.setEditing(editing, animated: animated)
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
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            appDelegate.allMemes.removeAtIndex(indexPath.row)
            sentMemes.removeAtIndex(indexPath.row)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            if sentMemes.isEmpty {
                editButtonItem().enabled = false
                setEditing(false, animated: true)
            }
            
            tableView.reloadData()
        }
    }
    
    // Table View Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let detailVC = storyboard?.instantiateViewControllerWithIdentifier("DetailView") as! MemeMeDetailViewController
        detailVC.memeIndex = indexPath.row
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        
        return .Delete
    }
    
}