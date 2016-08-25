//
//  KeyManager.swift
//  InternDiary
//
//  Created by IppeiMUKAIDA on 8/25/16.
//  Copyright © 2016 IppeiMUKAIDA. All rights reserved.
//

import Foundation

struct KeyManager {
    private let keyFilePath = NSBundle.mainBundle().pathForResource("Keys", ofType: "plist")
    
    func getKeys() -> NSDictionary? {
        guard let keyFilePath = keyFilePath else {
            return nil
        }
        return NSDictionary(contentsOfFile: keyFilePath)
    }
    
    func getValue(key: String) -> AnyObject? {
        guard let keys = getKeys() else {
            return nil
        }
        return keys[key]
    }
    
}