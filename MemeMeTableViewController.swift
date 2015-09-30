//
//  MemeMeTableViewController.swift
//  MemeMe Swift 2
//
//  Created by Ekstasis on 9/29/15.
//  Copyright © 2015 Baxter Heavy Industries. All rights reserved.
//

import UIKit

class MemeMeTableViewController: UITableViewController {

    @IBOutlet weak var cellImage: UIImageView!
    
    var sentMemes : [Meme]!
    
    override func viewWillAppear(animated: Bool) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "editNewMeme")
        sentMemes = (UIApplication.sharedApplication().delegate as! AppDelegate).allMemes
        tableView.reloadData()
    }
    
    func editNewMeme() {
        let editVC = storyboard?.instantiateViewControllerWithIdentifier("MemeEditor")
        navigationController?.pushViewController(editVC!, animated: true)
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("numRows: \(sentMemes.count)")
        
        return sentMemes.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SentMemeTableCell", forIndexPath: indexPath)
        
        print("dequeued cell")

        let meme = sentMemes[indexPath.row]
        let cellImageView = cell.contentView.subviews[0] as! UIImageView
//        cell.imageView?.image = meme.memedImage
        cellImageView.image = meme.memedImage
        cell.textLabel?.text = meme.topText
//        cell.detailTextLabel?.text = meme.topText
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let detailVC = storyboard?.instantiateViewControllerWithIdentifier("DetailView") as! MemeMeDetailViewController
        detailVC.memeImage = sentMemes[indexPath.row].memedImage
        navigationController?.pushViewController(detailVC, animated: true)
        
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
