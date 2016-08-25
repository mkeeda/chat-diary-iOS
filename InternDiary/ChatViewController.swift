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
    
    let defaultQuestions: [String] = [
        "今日行った場所",
        "楽しかったこと",
        "明日にすること",
    ]
    var questionNo: Int = 0
    var nouns: [String] = []

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
        self.receiveAutoMessage("")
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
        self.receiveAutoMessage(text)
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        selectImage();
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
    func receiveAutoMessage(text: String) {
        //1秒後に送信
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * Int64(NSEC_PER_SEC)), dispatch_get_main_queue(), {
            self.postTextToServer(text)
        })
    }
    
    func postTextToServer(text: String){
        PostChat(text: text).request(NSURLSession.sharedSession()) { (result) in
            switch result {
            case .Success(let result):
                dispatch_async(dispatch_get_main_queue()) {
                    self.ask(result)
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    func ask(result: PostChatResult) {
        var message: JSQMessage
        let question = result.question
        
        //質問おわり
        if(questionNo >= defaultQuestions.count){
            createEntry()
        }
        //自動生成できた
        else if(question != "none"){
            message = JSQMessage(senderId: "user2", displayName: "underscore", text: question)
            self.messages?.append(message)
            self.finishReceivingMessageAnimated(true)
            nouns.append(result.noun)
        }
        //自動生成できなかった
        else {
            let defaultQuestion = defaultQuestions[questionNo]
            self.questionNo += 1
            message = JSQMessage(senderId: "user2", displayName: "underscore", text: defaultQuestion + "を教えて!")
            self.messages?.append(message)
            self.finishReceivingMessageAnimated(true)
            nouns.append(defaultQuestion)
        }
    }
    
    
    
    //回答から記事を生成する
    func createEntry(){
        let tmp = messages?.filter{ $0.senderId == self.senderId }
        guard
            let userMessages = tmp,
            let diaryID = self.diaryID,
            let title = userMessages[0].text
        else{
            print("createEntry error")
            return
        }
        
        var body: String = ""
        nouns.removeFirst()
        for message in userMessages[1..<userMessages.count] {
            let noun = nouns.removeFirst()
            body += noun + "は" + message.text + "\n"
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
    func selectImage(){
        // フォトライブラリを使用できるか確認
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
            // フォトライブラリの画像・写真選択画面を表示
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .PhotoLibrary
            imagePickerController.allowsEditing = true
            imagePickerController.delegate = self
            presentViewController(imagePickerController, animated: true, completion: nil)
        }
    }
    func sendImageMessage(image: UIImage) {
        let photoItem = JSQPhotoMediaItem(image: image)
        let imageMessage = JSQMessage(senderId: senderId, displayName: senderDisplayName, media: photoItem)
        messages?.append(imageMessage)
        finishSendingMessageAnimated(true)
        postDocomoAPI(image)
    }
    
    func postDocomoAPI(image: UIImage){
        let modelName = "scene"
        
        if let imageData = UIImagePNGRepresentation(image) {
            ClassifyImage(image: imageData, modelName: modelName).request(NSURLSession.sharedSession()) { (result) in
                switch result {
                case .Success(let result):
                    dispatch_async(dispatch_get_main_queue()) {
                        self.recievedClassifyResult(result)
                    }
                case .Failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func recievedClassifyResult(result: ClassifyImageResult){
        let firstCandidateTag = result.candidates[0].tag
        let text = firstCandidateTag + "の画像ですね"
        let message = JSQMessage(senderId: "user2", displayName: "underscore", text: text)
        self.messages?.append(message)
        self.finishReceivingMessageAnimated(true)
        nouns.append(firstCandidateTag)
        
    }
    
    
}

extension ChatViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    // TODO:デリゲートメソッドの実装
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        // 選択した画像・写真を取得し、imageViewに表示
        if let info = editingInfo, let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage{
            sendImageMessage(editedImage)
        }else{
            sendImageMessage(image)
        }
        
        // フォトライブラリの画像・写真選択画面を閉じる
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}