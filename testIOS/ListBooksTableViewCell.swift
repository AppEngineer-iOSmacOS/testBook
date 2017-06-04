//
//  ListBooksTableViewCell.swift
//  testStorytelbridge
//
//  Created by Nikolay Sozinov on 30/05/2017.
//  Copyright © 2017 Nikolay Sozinov. All rights reserved.
//

import UIKit

class ListBooksTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageBookView: UIImageView!
    
    @IBOutlet weak var titleBookLabel: UILabel!
    @IBOutlet weak var textAutorBookLabel: UILabel!
    @IBOutlet weak var textNarratorBookLabel: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
