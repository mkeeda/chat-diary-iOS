//
//  EntryBodyCell.swift
//  InternDiary
//
//  Created by IppeiMUKAIDA on 8/26/16.
//  Copyright © 2016 IppeiMUKAIDA. All rights reserved.
//

import UIKit

class EntryBodyCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var body: UITextView!
    @IBOutlet weak var textHeightConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
