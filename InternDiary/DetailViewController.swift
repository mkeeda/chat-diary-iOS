//
//  DetailViewController.swift
//  InternDiary
//
//  Created by IppeiMUKAIDA on 8/19/16.
//  Copyright © 2016 IppeiMUKAIDA. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    var entry: Entry?
    
    private func configureView(){
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
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
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell:EntryBodyCell = (collectionView.dequeueReusableCellWithReuseIdentifier("cell1", forIndexPath: indexPath) as? EntryBodyCell)!
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
            let cell:EntryImageCell = (collectionView.dequeueReusableCellWithReuseIdentifier("cell2", forIndexPath: indexPath) as? EntryImageCell)!
            if let entry = self.entry {
                if let imageView = cell.imageView {
                    let URL = NSURL(string: "http://localhost:3000/\(entry.imageURL)")
                    imageView.sd_setImageWithURL(URL)
                }
            }
            return cell
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1;
    }
    
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		
		let margin = 10
		let cellSizeWidth:CGFloat = UIScreen.mainScreen().bounds.size.width - CGFloat(margin) * 2
		let cellSizeHeight:CGFloat = cellSizeWidth
		return CGSizeMake(cellSizeWidth, cellSizeHeight)
	}
}
