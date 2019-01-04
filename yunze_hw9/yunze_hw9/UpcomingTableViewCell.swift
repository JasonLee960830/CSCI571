//
//  UpcomingTableViewCell.swift
//  yunze_hw9
//
//  Created by  jasonlee on 2018/11/26.
//  Copyright © 2018 yunze li. All rights reserved.
//

import UIKit

class UpcomingTableViewCell: UITableViewCell {
    var link : String?
    @IBOutlet weak var eventName: UIButton!
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBAction func eventNamePressed(_ sender: Any) {
        UIApplication.shared.open(URL(string: link!)!, options: [:], completionHandler: nil)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
