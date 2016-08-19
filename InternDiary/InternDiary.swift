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
            "Content-Type": "test/json",
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
    
    init(JSON: JSONObject) throws {
        self.entries = try JSON.get("entries")
        self.perPage = try JSON.get("per_page")
    }
}

struct AddEntryResult: JSONDecodable {
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
    
    init(JSON: JSONObject) throws {
        self.entryID = try JSON.get("entry_id")
        self.diaryID = try JSON.get("diary_id")
        self.title = try JSON.get("title")
        self.body = try JSON.get("body")
        self.createdDate = try JSON.get("created_date", converter: EpochDateConverter())
    }
}