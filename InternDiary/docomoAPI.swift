//
//  docomoAPI.swift
//  InternDiary
//
//  Created by IppeiMUKAIDA on 8/25/16.
//  Copyright © 2016 IppeiMUKAIDA. All rights reserved.
//

import Foundation

protocol docomoAPIEndpoint: APIEndpoint {
    var path: String { get }
}

private let docomoAPIURL = NSURL(string: "https://api.apigw.smt.docomo.ne.jp/")!

extension docomoAPIEndpoint {
    var URL: NSURL {
        return NSURL(string: path, relativeToURL: docomoAPIURL)!
    }
    var headers: Parameters? {
        return [
            "Accept": "application/json",
        ]
    }
}

struct ClassifyImage: docomoAPIEndpoint {
    var path = "imageRecognition/v1/concept/classify/"
    typealias ResponseType = ClassifyImageResult
    
    var headers: Parameters? {
        return [
            "Accept": "application/json",
            "Content-type": "multipart/form-data",
        ]
    }
}


struct ClassifyImageResult: JSONDecodable {
    let jobID: Int
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