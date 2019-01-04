//
//  DetailTableViewController.swift
//  yunze_hw9
//
//  Created by  jasonlee on 2018/11/21.
//  Copyright © 2018 yunze li. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SwiftSpinner
import EasyToast

class DetailTableViewController: UITableViewController {
    static var collectionRowIndex : [Int] = []
    static var emptyDictionary = [String: [Int]]()
    static var searchResultToCollectionView : JSON?
    static var allCollection : JSON?
    var formInfo : [String : String]?
    var searchResult : JSON?
    let searchUrl : String = "http://yunzehw8backend.us-east-2.elasticbeanstalk.com/search"
    var eventId : String?
//    let tapGesture = UITapGestureRecognizer.init(target: self, action:#selector(userClick(sender:)))
//    static func toastAdding(hint:String){
//        self.toastAdd(hint : hint)
//    }
//    static func toastRemoving(hint:String){
//        toastRemove(hint : hint)
//    }
    func toastAdd(hint:String)  {
        self.view.showToast("\(hint) has been added to favorites", tag:"test", position: .bottom, popTime: 1.5, dismissOnTap: false)
    }
    
    func toastRemove(hint:String) {
        self.view.showToast("\(hint) has been removed from favorites", tag:"test", position: .bottom, popTime: 1.5, dismissOnTap: false)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        DetailTableViewController.searchResultToCollectionView = searchResult
//        let label = UILabel()
//        label.frame = CGRect(x: 10, y:  40, width: 200, height: 25)
//        label.tag = 100
//        label.text = "test"
//        label.isUserInteractionEnabled = true
//        view.addSubview(label)
//        label.addGestureRecognizer(tapGesture)
//        print(2)
    }
//    @objc func userClick(sender: UITapGestureRecognizer) {
//        self.performSegue(withIdentifier: "goToEventDetailPage", sender: self)
//        print(1)
//    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "goToEventDetailPage"){
            let destinationVC = segue.destination as!EventDetailPageViewController
            destinationVC.eventId = self.eventId
            print("data from DetailTable: \(eventId ?? "not successful")")
//            let destinationVC = segue.destination as! DetailTableViewController
//            //            destinationVC.formInfo = self.formInfo
//            destinationVC.searchResult = self.searchResult
            
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
//        print(searchResult?["_embedded"]["events"][0] ?? 0)
//        print("success numberOfSections")
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        print("success print row")
        return searchResult?["_embedded"]["events"].count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        print("success begin cell")
        let cellIdentifier = "ResultTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ResultTableViewCell  else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        let cellData = searchResult?["_embedded"]["events"][indexPath.row]
        let favoriteEmpty = UIImage(named: "favorite-empty")
        let eventCategory = cellData?["classifications"][0]["segment"]["name"]
        let eventDateString = "\(cellData?["dates"]["start"]["localDate"].rawString() ?? "TBD") \(cellData?["dates"]["start"]["localTime"].rawString() ?? "TBD")"
        cell.categoryImage.image = UIImage(named: eventCategory?.rawString() ?? "Sports")
        cell.rowIndex = indexPath.row
        cell.collectionButton.setImage(favoriteEmpty, for:.normal)
        cell.eventName.text = cellData?["name"].rawString()
//        cell.eventName.addGestureRecognizer(tapGesture)
        cell.venueName.text = cellData?["_embedded"]["venues"][0]["name"].rawString()
//        cell.venueName.addGestureRecognizer(tapGesture)
        cell.eventDate.text = eventDateString
//        cell.eventDate.addGestureRecognizer(tapGesture)
//        print("success print cell")
        return cell
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellData = searchResult?["_embedded"]["events"][indexPath.row]
        eventId = cellData?["id"].rawString()
        print(indexPath.row)
        print(eventId ?? "No assigning eventId")
        self.performSegue(withIdentifier: "goToEventDetailPage", sender: self)
    }
    
    @IBAction func testButtonPressed(_ sender: Any) {
        print("passing successful in testButton?\(eventId ?? "No")")
//        self.performSegue(withIdentifier: "goToEventDetailPage", sender: self)
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

