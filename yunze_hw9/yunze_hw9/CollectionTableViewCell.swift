//
//  CollectionTableViewCell.swift
//  yunze_hw9
//
//  Created by  jasonlee on 2018/11/29.
//  Copyright © 2018 yunze li. All rights reserved.
//

import UIKit

class CollectionTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionCellImage: UIImageView!
    
    @IBOutlet weak var collectionCellEventName: UILabel!
    @IBOutlet weak var collectionCellVenueName: UILabel!
    @IBOutlet weak var collectionCellTime: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
