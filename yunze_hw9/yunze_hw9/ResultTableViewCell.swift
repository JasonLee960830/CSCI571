//
//  ResultTableViewCell.swift
//  yunze_hw9
//
//  Created by  jasonlee on 2018/11/22.
//  Copyright © 2018 yunze li. All rights reserved.
//

import UIKit
import EasyToast
class ResultTableViewCell: UITableViewCell {
    var rowIndex : Int = 0
    var clicked : Int = 0
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var favoritesImage: UIImageView!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var venueName: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var collectionButton: UIButton!
    let favoriteEmpty = UIImage(named: "favorite-empty")
    let favorite = UIImage(named: "favorite-filled")
    @IBAction func collectionButtonPressed(_ sender: Any) {
        if(clicked == 0){
            clicked = 1
            (sender as AnyObject).setImage(favorite, for:.normal)
            DetailTableViewController.collectionRowIndex.append(self.rowIndex)
            DetailTableViewController.emptyDictionary[SearchTabViewController.keywordText!]=DetailTableViewController.collectionRowIndex

//            print(DetailTableViewController.collectionRowIndex)
//            print(DetailTableViewController.emptyDictionary)
            

//    DetailTableViewController.toastAdding(hint:eventName.text!)
        }
        else{
//            DetailTableViewController.toastRemoving(hint:eventName.text!)
            clicked = 0
            (sender as AnyObject).setImage(favoriteEmpty, for:.normal)
            var count = 0
           let num = DetailTableViewController.collectionRowIndex.count
            while(count<num){
                if(DetailTableViewController.collectionRowIndex[count]==self.rowIndex){
                    DetailTableViewController.collectionRowIndex.remove(at: count)
                    break
                }
                count = count+1
            }
            DetailTableViewController.emptyDictionary[SearchTabViewController.keywordText!]=DetailTableViewController.collectionRowIndex
            print(DetailTableViewController.collectionRowIndex)
            print(DetailTableViewController.emptyDictionary)
        }
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
