//
//  ChatViewController.swift
//  InternDiary
//
//  Created by IppeiMUKAIDA on 8/22/16.
//  Copyright © 2016 IppeiMUKAIDA. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {
    var diaryID: Int?
    
    var messages: [JSQMessage]?
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    var incomingAvatar: JSQMessagesAvatarImage!
    var outgoingAvatar: JSQMessagesAvatarImage!
    
    let questions: [String] = [
        "今日はどこに行った？",
        "楽しかったこと教えて!",
        "明日は何する？",
    ]
    var questionNo: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //自分のsenderId, senderDisokayNameを設定
        self.senderId = "user1"
        self.senderDisplayName = "hoge"
        
        //吹き出しの設定
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        self.incomingBubble = bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.grayColor())
        self.outgoingBubble = bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
        
        //メッセージデータの配列を初期化
        self.messages = []
        
        //最初に質問をする
        receiveAutoMessage()
 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //Sendボタンが押された時に呼ばれる
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        //新しいメッセージデータを追加する
        let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
        self.messages?.append(message)
        
        //メッセジの送信処理を完了する(画面上にメッセージが表示される)
        self.finishReceivingMessageAnimated(true)
        
        self.keyboardController.textView.text = ""
        
        //擬似的に自動でメッセージを受信
        self.receiveAutoMessage()
    }
    //アイテムごとに参照するメッセージデータを返す
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return self.messages?[indexPath.item]
    }
    
    //アイテムごとのMessageBubble(背景)を返す
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = self.messages?[indexPath.item]
        if message?.senderId == self.senderId {
            return self.outgoingBubble
        }
        return self.incomingBubble
    }
    
    //アイテムごとにアバター画像を返す
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = self.messages?[indexPath.item]
        if message?.senderId == self.senderId {
            return self.outgoingAvatar
        }
        return self.incomingAvatar
    }
    
    //アイテムの総数を返す
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.messages?.count)!
    }
    
    //返信メッセージを受信する
    func receiveAutoMessage() {
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ChatViewController.didFinishMessageTimer(_:)), userInfo: nil, repeats: false)
    }
    
    func didFinishMessageTimer(sender: NSTimer) {
        if(questionNo >= questions.count){
            createEntry()
        }
        else {
            let question = questions[questionNo]
            let message = JSQMessage(senderId: "user2", displayName: "underscore", text: question)
            
            self.messages?.append(message)
            self.finishReceivingMessageAnimated(true)
        }
        self.questionNo += 1
    }
    
    //回答から記事を生成する
    func createEntry(){
        let tmp = messages?.filter{ $0.senderId == self.senderId }
        guard
            let userMessages = tmp,
            let diaryID = self.diaryID
        else{
            print("createEntry error")
            return
        }
        
        let title = userMessages[0].text
        var body: String = ""
        for message in userMessages[1..<userMessages.count] {
            body += message.text + "\n"
        }
        AddEntry(diaryID: diaryID, title: title, body: body).request(NSURLSession.sharedSession()) { (result) in
            switch result {
            case .Success(_):
                dispatch_async(dispatch_get_main_queue()) {
                    self.navigationController?.popToRootViewControllerAnimated(true)
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
}
