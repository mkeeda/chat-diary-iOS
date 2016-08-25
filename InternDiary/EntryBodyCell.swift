//
//  EntryBodyCell.swift
//  InternDiary
//
//  Created by IppeiMUKAIDA on 8/26/16.
//  Copyright © 2016 IppeiMUKAIDA. All rights reserved.
//

import UIKit

class EntryBodyCell: UICollectionViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var body: UITextView!
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
}
