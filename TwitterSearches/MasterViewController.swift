//
//  MasterViewController.swift
//  TwitterSearches
//
//  Created by David Hincapie on 11/10/15.
//  Copyright © 2015 David Hincapie. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController,
ModelDelegate {
    
    // DetailViewController contains UIWebView to display search results
    var detailViewController: DetailViewController? = nil
    
    var model: Model! = nil // manages the app's data
    let twitterSearchURL = "https://mobile.twitter.com/search/?q="
    
    // conform to ModelDelegate protocol; updates view when model changes
    func modelDataChanged() {
        tableView.reloadData() // reload the UITableView
    }
    
    // configure popover for UITableView on iPad
    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize =
                CGSize(width: 320.0, height: 600.0)
        }
    }
    
    // called after the view loads for further UI configuration
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up left and right UIBarButtonItems
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add,
            target: self, action: "addButtonPressed:")
        self.navigationItem.rightBarButtonItem = addButton
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController =
                controllers[controllers.count-1] as? DetailViewController
        }
        
        model = Model(delegate: self) // create the Model
        model.synchronize() // tell model to sync its data
    }
    
    // displays a UIAlertController to obtain new search from user
    func addButtonPressed(sender: AnyObject) {
        displayAddEditSearchAlert(isNew: true, index: nil)
    }
    
    // handles long press for editing or sharing a search
    func tableViewCellLongPressed(
        sender: UILongPressGestureRecognizer) {
            if sender.state == UIGestureRecognizerState.Began &&
                !tableView.editing {
                    let cell = sender.view as! UITableViewCell // get cell
                    
                    if let indexPath = tableView.indexPathForCell(cell) {
                        displayLongPressOptions(indexPath.row)
                    }
            }
    }
    
    // displays the edit/share options
    func displayLongPressOptions(row: Int) {
        // create UIAlertController for user input
        let alertController = UIAlertController(title: "Options",
            message: "Edit or Share your search",
            preferredStyle: UIAlertControllerStyle.Alert)
        
        // create Cancel action
        let cancelAction = UIAlertAction(title: "Cancel",
            style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let editAction = UIAlertAction(title: "Edit",
            style: UIAlertActionStyle.Default,
            handler: {(action) in
                self.displayAddEditSearchAlert(isNew: false, index: row)})
        alertController.addAction(editAction)
        
        let shareAction = UIAlertAction(title: "Share",
            style: UIAlertActionStyle.Default,
            handler: {(action) in self.shareSearch(row)})
        alertController.addAction(shareAction)
        presentViewController(alertController, animated: true,
            completion: nil)
    }
    
    // displays add/edit dialog
    func displayAddEditSearchAlert(isNew  isNew: Bool, index: Int?) {
        // create UIAlertController for user input
        let alertController = UIAlertController(
            title: isNew ? "Add Search" : "Edit Search",
            message: isNew ? "" : "Modify your query",
            preferredStyle: UIAlertControllerStyle.Alert)
        
        // create UITextFields in which user can enter a new search
        alertController.addTextFieldWithConfigurationHandler(
            {(textField) in
                if isNew {
                    textField.placeholder = "Enter Twitter search query"
                } else {
                    textField.text = self.model.queryForTagAtIndex(index!)
                }
        })
        
        alertController.addTextFieldWithConfigurationHandler(
            {(textField) in
                if isNew {
                    textField.placeholder = "Tag your query"
                } else {
                    textField.text = self.model.tagAtIndex(index!)
                    textField.enabled = false
                    textField.textColor = UIColor.lightGrayColor()
                }
        })
        
        // create Cancel action
        let cancelAction = UIAlertAction(title: "Cancel",
            style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let saveAction = UIAlertAction(title: "Save",
            style: UIAlertActionStyle.Default,
            handler: {(action) in
                let query =
                (alertController.textFields![0] ).text
                let tag =
                (alertController.textFields![1] ).text
                
                // ensure query and tag are not empty
                if !query!.isEmpty && !tag!.isEmpty {
                    self.model.saveQuery(
                        query!, forTag: tag!, syncToCloud: true)
                    
                    if isNew {
                        let indexPath =
                        NSIndexPath(forRow: 0, inSection: 0)
                        self.tableView.insertRowsAtIndexPaths([indexPath],
                            withRowAnimation: .Automatic)
                    }
                }
        })
        alertController.addAction(saveAction)
        
        presentViewController(alertController, animated: true,
            completion: nil)
    }
    
    // displays share sheet
    func shareSearch(index: Int) {
        let message = "Check out the results of this Twitter search"
        let urlString = twitterSearchURL +
            urlEncodeString(model.queryForTagAtIndex(index)!)
        let itemsToShare = [message, urlString]
        
        // create UIActivityViewController so user can share search
        let activityViewController = UIActivityViewController(
            activityItems: itemsToShare, applicationActivities: nil)
        presentViewController(activityViewController,
            animated: true, completion: nil)
    }
    
    // called when app is about to seque from
    // MainViewController to DetailViewController
    override func prepareForSegue(segue: UIStoryboardSegue,
        sender: AnyObject?) {
            
            if segue.identifier == "showDetail" {
                if let indexPath = self.tableView.indexPathForSelectedRow {
                    let controller = (segue.destinationViewController as!
                        UINavigationController).topViewController as!
                    DetailViewController
                    
                    // get query String
                    let query =
                    String(model.queryForTagAtIndex(indexPath.row)!)
                    
                    // create NSURL to perform Twitter Search
                    controller.detailItem = NSURL(string: twitterSearchURL +
                        urlEncodeString(query))
                    controller.navigationItem.leftBarButtonItem =
                        self.splitViewController?.displayModeButtonItem()
                    controller.navigationItem.leftItemsSupplementBackButton =
                    true
                }
            }
    }
    
    // returns a URL encoded version of the query String
    func urlEncodeString(string: String) -> String {
        return string.stringByAddingPercentEncodingWithAllowedCharacters(
            NSCharacterSet.URLQueryAllowedCharacterSet())!
    }
    
    
    // callback that returns total number of sections in UITableView
    override func numberOfSectionsInTableView(
        tableView: UITableView) -> Int {
            return 1
    }
    
    // callback that returns number of rows in the UITableView
    override func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            return model.count
    }
    
    // callback that returns a configured cell for the given NSIndexPath
    override func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) ->
        UITableViewCell {
            
            // get cell
            let cell = tableView.dequeueReusableCellWithIdentifier(
                "Cell", forIndexPath: indexPath) 
            
            // set cell label's text to the tag at the specified index
            cell.textLabel?.text = model.tagAtIndex(indexPath.row)
            
            // set up long press guesture recognizer
            let longPressGestureRecognizer = UILongPressGestureRecognizer(
                target: self, action: "tableViewCellLongPressed:")
            longPressGestureRecognizer.minimumPressDuration = 0.5
            cell.addGestureRecognizer(longPressGestureRecognizer)
            
            return cell
    }
    
    // callback that returns whether a cell is editable
    override func tableView(tableView: UITableView,
        canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
            return true // all cells are editable
    }
    
    // callback that deletes a row from the UITableView
    override func tableView(tableView: UITableView,
        commitEditingStyle editingStyle: UITableViewCellEditingStyle,
        forRowAtIndexPath indexPath: NSIndexPath) {
            if editingStyle == .Delete {
                model.deleteSearchAtIndex(indexPath.row)
                
                // remove UITableView row
                tableView.deleteRowsAtIndexPaths(
                    [indexPath], withRowAnimation: .Fade)
            }
    }
    
    // callback that returns whether cells can be moved
    override func tableView(tableView: UITableView,
        canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
            return true
    }
    
    // callback that reorders keys when user moves them in the table
    override func tableView(tableView: UITableView,
        moveRowAtIndexPath sourceIndexPath: NSIndexPath,
        toIndexPath destinationIndexPath: NSIndexPath) {
            // tell model to reorder tags based on UITableView order
            model.moveTagAtIndex(sourceIndexPath.row,
                toDestinationIndex: destinationIndexPath.row)
    }
    
}


