//
//  InternDiary.swift
//  InternDiary
//
//  Created by IppeiMUKAIDA on 8/19/16.
//  Copyright © 2016 IppeiMUKAIDA. All rights reserved.
//

import Foundation

protocol InternDiaryEndpoint: APIEndpoint {
    var path: String { get }
}

private let InternDiaryURL = NSURL(string: "http://localhost:3000/")!

extension InternDiaryEndpoint {
    var URL: NSURL {
        return NSURL(string: path, relativeToURL: InternDiaryURL)!
    }
    var headers: Parameters? {
        return [
            "Accept": "application/json",
        ]
    }
}

struct GetDiaries: InternDiaryEndpoint {
    var path = "api/diaries"
    typealias ResponseType = GetDiariesResult
    
    var headers: Parameters? {
        return [
            "Accept": "application/json",
        ]
    }
}

struct GetEntries: InternDiaryEndpoint {
    var path: String {
        return "api/diaries/" + String(diaryID)
    }
    var headers: Parameters? {
        return [
            "Accept": "application/json",
        ]
    }
    var query: Parameters? {
        return [
            "page" : String(page),
        ]
    }
    typealias ResponseType = GetEntriesResult
    
    let diaryID: Int
    let page: Int
    init(diaryID: Int, page: Int) {
        self.diaryID = diaryID
        self.page = page
    }
}

struct AddEntry: InternDiaryEndpoint {
    var path: String = "api/entries"
    var method: HTTPMethod = .POST
    var headers: Parameters? {
        return [
            "Accept": "application/json",
        ]
    }
    var params: [String: AnyObject]? {
        return [
            "diary_id" : diaryID,
            "title" : title,
            "body" : body
        ]
    }
    typealias ResponseType = AddEntryResult
    
    let diaryID: Int
    let title: String
    let body: String
    init(diaryID: Int, title: String, body: String){
        self.diaryID = diaryID
        self.title = title
        self.body = body
    }
}
struct PostChat: InternDiaryEndpoint {
    var path: String = "api/chat"
    var method: HTTPMethod = .POST
    var headers: Parameters? {
        return [
            "Accept": "application/json",
        ]
    }
    var params: [String: AnyObject]? {
        return [
            "text" : text,
        ]
    }
    typealias ResponseType = PostChatResult
   
    let text: String
    init(text: String){
        self.text = text
    }
    
}

struct AddEntryImage: InternDiaryEndpoint {
    var path = "api/entries/images"
    var method: HTTPMethod = .POST
    
    var headers: Parameters? {
        return [
            "Accept": "application/json",
            "Content-type": "multipart/form-data; boundary=MRSUNEGE",
        ]
    }
    var multipartBody: NSData? {
        return setBody()
    }
    typealias ResponseType = AddEntryImageResult
    
    let image: NSData
    let entryID: Int
    let boundary = "MRSUNEGE"
    
    init(image: NSData, entryID: Int){
        self.image = image
        self.entryID = entryID
    }
    func setBody() -> NSData? {
        let post = NSMutableData()
        let entryIDString = String(entryID)
        post.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        post.appendData("Content-Disposition: form-data;".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        post.appendData("name=\"image\";".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        post.appendData("filename=\"tmp.png\"\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        post.appendData("Content-type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        post.appendData(image)
        post.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        post.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        post.appendData("Content-Disposition: form-data;".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        post.appendData("name=\"entry_id\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        post.appendData(entryIDString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        post.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        post.appendData("--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        print(NSString(data:post, encoding: NSUTF8StringEncoding))
        return post
    }
}

private let dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    return formatter
}()

struct FormattedDateConverter: JSONValueConverter {
    typealias FromType = String
    typealias ToType = NSDate

    private let dateFormatter: NSDateFormatter

    func convert(key key: String, value: FromType) throws -> DateConverter.ToType {
        guard let date = dateFormatter.dateFromString(value) else {
            throw JSONDecodeError.UnexpectedValue(key: key, value: value, message: "Invalid date format for '\(dateFormatter.dateFormat)'")
        }
        return date
    }
}

struct EpochDateConverter: JSONValueConverter {
    typealias FromType = Int
    typealias ToType = NSDate

    func convert(key key: String, value: FromType) throws -> DateConverter.ToType {
        let date = NSDate(timeIntervalSince1970: Double(value))
        return date
    }
}

struct GetDiariesResult: JSONDecodable {
    let diaries: [Diary]
    
    init(JSON: JSONObject) throws {
        self.diaries = try JSON.get("diaries")
    }
}

struct GetEntriesResult: JSONDecodable {
    let entries: [Entry]
    let perPage: Int
    let hasNext: Int
    
    init(JSON: JSONObject) throws {
        self.entries = try JSON.get("entries")
        self.perPage = try JSON.get("per_page")
        self.hasNext = try JSON.get("has_next")
    }
}

struct AddEntryResult: JSONDecodable {
    let status: String
    let entryID: Int
    init(JSON: JSONObject) throws {
        self.status = try JSON.get("status")
        self.entryID = try JSON.get("entry_id")
    }
}

struct PostChatResult: JSONDecodable {
    let question: String
    let noun: String
    init(JSON: JSONObject) throws {
        self.question = try JSON.get("question")
        self.noun = try JSON.get("noun")
    }
}
struct AddEntryImageResult: JSONDecodable {
    let status: String
    init(JSON: JSONObject) throws {
        self.status = try JSON.get("status")
    }
}

struct Diary: JSONDecodable {
    let diaryID: Int
    let userID: Int
    let title: String
    
    init(JSON: JSONObject) throws {
        self.diaryID = try JSON.get("diary_id")
        self.userID = try JSON.get("user_id")
        self.title = try JSON.get("title")
    }
}

struct Entry: JSONDecodable {
    let entryID: Int
    let diaryID: Int
    let title: String
    let body: String
    let createdDate: NSDate
    let imageURL: String
    
    init(JSON: JSONObject) throws {
        self.entryID = try JSON.get("entry_id")
        self.diaryID = try JSON.get("diary_id")
        self.title = try JSON.get("title")
        self.body = try JSON.get("body")
        self.createdDate = try JSON.get("created_date", converter: EpochDateConverter())
        self.imageURL = try JSON.get("image_url")
    }
}