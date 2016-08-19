//
//  DetailViewController.swift
//  InternDiary
//
//  Created by IppeiMUKAIDA on 8/19/16.
//  Copyright © 2016 IppeiMUKAIDA. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var createDateLabel: UILabel!
    
    var entry: Entry? {
        didSet {
            configureView()
        }
    }
    
    private func configureView(){
        if let entry = self.entry {
            if let label = titleLabel {
                label.text = entry.title
            }
            if let textView = bodyTextView {
                textView.text = entry.body
            }
            if let label = createDateLabel {
                let formatter: NSDateFormatter = NSDateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                label.text = formatter.stringFromDate(entry.createdDate)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configureView()
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

}
