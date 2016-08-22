//
//  EntriesViewController.swift
//  InternDiary
//
//  Created by IppeiMUKAIDA on 8/19/16.
//  Copyright © 2016 IppeiMUKAIDA. All rights reserved.
//

import UIKit

class EntriesViewController: UITableViewController {

    var diaryID: Int?
    var page: Int = 1
    var entries: [Entry] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private func getEntries() {
        entries = []
        if let diaryID = self.diaryID {
            GetEntries(diaryID: diaryID, page: page ).request(NSURLSession.sharedSession()) { (result) in
                switch result {
                case .Success(let getEntriesResult):
                    dispatch_async(dispatch_get_main_queue()) {
                        self.entries.appendContentsOf(getEntriesResult.entries)
                    }
                case .Failure(let error):
                    print(error)
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let postButton: UIBarButtonItem = UIBarButtonItem(title: "Post", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EntriesViewController.clickPostButton))
        let chatButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "ChatIcon"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EntriesViewController.clickChatButton))
        
        self.navigationItem.setRightBarButtonItems([postButton, chatButton], animated: true)
        
    }
    
    func clickPostButton(){
        performSegueWithIdentifier("showPost", sender: nil)
    }
    
    func clickChatButton(){
        performSegueWithIdentifier("showChat", sender: nil)
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
        getEntries()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let entry = entries[indexPath.row]
                let controller = segue.destinationViewController as! DetailViewController
                controller.entry = entry
            }
        }
        if segue.identifier == "showPost" {
            if let diaryID = self.diaryID {
                let controller = segue.destinationViewController as! PostViewController
                controller.diaryID = diaryID
            }
            
        }
        if segue.identifier == "showChat" {
            if let diaryID = self.diaryID {
                let controller = segue.destinationViewController as! ChatViewController
                controller.diaryID = diaryID
            }
            
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let diary = entries[indexPath.row]
        cell.textLabel!.text = diary.title
        return cell
    }


}

