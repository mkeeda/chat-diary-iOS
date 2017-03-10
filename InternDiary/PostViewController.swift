//
//  PostViewController.swift
//  InternDiary
//
//  Created by IppeiMUKAIDA on 8/19/16.
//  Copyright © 2016 IppeiMUKAIDA. All rights reserved.
//

import UIKit

class PostViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    var diaryID: Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let saveButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: #selector(PostViewController.clickSaveButton))
        
        self.navigationItem.setRightBarButtonItems([saveButton], animated: true)
        
		//「閉じるボタン」を作成する。
		let closeButton = UIButton(frame:CGRectMake(CGFloat( UIScreen.mainScreen().bounds.size.width)-70, 0, 70, 50))
		closeButton.setTitle("閉じる", forState:UIControlState.Normal)
		closeButton.backgroundColor = UIColor.lightGrayColor()
		closeButton.addTarget(self,action:#selector(PostViewController.clickCloseButton(_:)), forControlEvents: .TouchUpInside)
		
		bodyTextView.inputAccessoryView = closeButton
		titleTextField.inputAccessoryView = closeButton

    }
    
    func clickSaveButton(){
        guard
            let diaryID = self.diaryID,
            let title = self.titleTextField.text,
            let body = self.bodyTextView.text
            else {
                return
        }
        AddEntry(diaryID: diaryID, title: title, body: body).request(NSURLSession.sharedSession()) { (result) in
            switch result {
            case .Success(_):
                dispatch_async(dispatch_get_main_queue()) {
                    self.navigationController?.popViewControllerAnimated(true)
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    
	func clickCloseButton(sender: UIButton){
		bodyTextView.resignFirstResponder()
		titleTextField.resignFirstResponder()
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
