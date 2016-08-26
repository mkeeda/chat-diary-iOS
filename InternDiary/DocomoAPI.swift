//
//  docomoAPI.swift
//  InternDiary
//
//  Created by IppeiMUKAIDA on 8/25/16.
//  Copyright © 2016 IppeiMUKAIDA. All rights reserved.
//

import Foundation

protocol DocomoAPIEndpoint: APIEndpoint {
    var path: String { get }
}

private let docomoAPIURL = NSURL(string: "https://api.apigw.smt.docomo.ne.jp/")!

extension DocomoAPIEndpoint {
    var URL: NSURL {
        return NSURL(string: path, relativeToURL: docomoAPIURL)!
    }
    var headers: Parameters? {
        return [
            "Accept": "application/json",
        ]
    }
}

struct ClassifyImage: DocomoAPIEndpoint {
    var path = "imageRecognition/v1/concept/classify/"
    var method: HTTPMethod = .POST
    
    var headers: Parameters? {
        return [
            "Accept": "application/json",
            "Content-type": "multipart/form-data; boundary=\(boundary)",
        ]
    }
    var query: Parameters? {
        return [
            "APIKEY" : key,
        ]
    }
    var multipartBody: NSData? {
        return setBody()
    }
    typealias ResponseType = ClassifyImageResult
    
    let image: NSData
    let modelName: String
    var key: String = ""
    let boundary = "MRSUNEGE"
    
    init(image: NSData, modelName: String){
        self.image = image
        self.modelName = modelName
        
        //APIkeyを読込
        if let myAPIKey = KeyManager().getValue("docomoAPIKey") as? String { // "myAPIKey"は自分で設定したKeys.plistのキー
            self.key = myAPIKey
        }
    }
    func setBody() -> NSData? {
        let post = NSMutableData()
        post.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        post.appendData("Content-Disposition: form-data; ".dataUsingEncoding(NSUTF8StringEncoding)!)
        post.appendData("name=\"image\"; ".dataUsingEncoding(NSUTF8StringEncoding)!)
        post.appendData("filename=\"tmp.png\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        post.appendData("Content-type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        post.appendData(image)
        post.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        post.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        post.appendData("Content-Disposition: form-data; ".dataUsingEncoding(NSUTF8StringEncoding)!)
        post.appendData("name=\"modelName\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        post.appendData(modelName.dataUsingEncoding(NSUTF8StringEncoding)!)
        post.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        post.appendData("--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        return post
    }
}


struct ClassifyImageResult: JSONDecodable {
    let jobID: String
    let candidates: [Candidate]
    
    init(JSON: JSONObject) throws {
        self.jobID = try JSON.get("jobId")
        self.candidates = try JSON.get("candidates")
    }
}

struct Candidate: JSONDecodable {
    let tag: String
    let score: Double
    
    init(JSON: JSONObject) throws {
        self.tag = try JSON.get("tag")
        self.score = try JSON.get("score")
    }
}