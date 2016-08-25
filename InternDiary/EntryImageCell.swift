//
//  EntryImageCell.swift
//  InternDiary
//
//  Created by IppeiMUKAIDA on 8/26/16.
//  Copyright © 2016 IppeiMUKAIDA. All rights reserved.
//

import UIKit
import SDWebImage

class EntryImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
}
