//
//  DetailViewController.swift
//  InternDiary
//
//  Created by IppeiMUKAIDA on 8/19/16.
//  Copyright © 2016 IppeiMUKAIDA. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {

    var entry: Entry?
    
    private func configureView(){
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableView.estimatedRowHeight = 5000
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell1", forIndexPath: indexPath) as! EntryBodyCell
            if let entry = self.entry {
                if let label = cell.title {
                    label.text = entry.title
                }
                if let textView = cell.body {
                    textView.text = entry.body
                }
                if let label = cell.date {
                    let formatter: NSDateFormatter = NSDateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    label.text = formatter.stringFromDate(entry.createdDate)
                }
        }
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell2", forIndexPath: indexPath) as! EntryImageCell
            if let entry = self.entry {
                if let imageView = cell.imageView {
                    let URL = NSURL(string: "http://localhost:3000/\(entry.imageURL)")
                    imageView.sd_setImageWithURL(URL, placeholderImage: UIImage(named: "placeholder.png"))
                    imageView.contentMode = .ScaleAspectFit
                }
            }
            return cell
        }
    }
    func textViewDidChange(textView: UITextView) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var cellHeight: CGFloat = 100
        switch indexPath.section {
        case 0:
            cellHeight = 300
        default:
            cellHeight = 200
        }
        return cellHeight
    }
}
