//
//  CollectionViewController.swift
//  yunze_hw9
//
//  Created by  jasonlee on 2018/11/29.
//  Copyright © 2018 yunze li. All rights reserved.
//

import UIKit
import SwiftyJSON
class CollectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    @IBOutlet weak var collectionTableView: UITableView!
    var collectionDictionary = [String: [Int]]()
    var collectionData : JSON?
    var realData : [JSON] = []
    override func viewWillAppear(_ animated: Bool) {
        collectionTableView.dataSource = self
        collectionTableView.delegate = self
        collectionDictionary = DetailTableViewController.emptyDictionary
        collectionData = DetailTableViewController.searchResultToCollectionView
        for items in collectionDictionary.keys {
            for eventIndex in collectionDictionary[items]!{
                realData.append((collectionData?["_embedded"]["events"][eventIndex])!)
            }
        }
        print("appearing!!")
        collectionTableView.reloadData()
//        print("this is real collection Data from appearing view")
//        print(realData)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionTableView.dataSource = self
        collectionTableView.delegate = self
        collectionDictionary = DetailTableViewController.emptyDictionary
        collectionData = DetailTableViewController.searchResultToCollectionView
        for items in collectionDictionary.keys {
            for eventIndex in collectionDictionary[items]!{
                realData.append((collectionData?["_embedded"]["events"][eventIndex])!)
            }
        }
        collectionTableView.reloadData()
        print("this is real collection Data")
//        print(realData)
        // Do any additional setup after loading the view.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        for item in collectionDictionary.keys {
            print(item,collectionDictionary[item]!)
            count = count+collectionDictionary[item]!.count
        }
        print("count is printing!!#####################################################")
        print(count)
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "collectionTableViewCell", for: indexPath) as? CollectionTableViewCell  else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        cell.collectionCellImage.image =
        UIImage(named: realData[indexPath.row]["classifications"][0]["segment"]["name"].rawString() ?? "Sports")
        cell.collectionCellEventName.text = realData[indexPath.row]["name"].rawString()
        cell.collectionCellVenueName.text = realData[indexPath.row]["_embedded"]["venues"][0]["name"].rawString()
        cell.collectionCellTime.text = "\(realData[indexPath.row]["dates"]["start"]["localDate"].rawString() ?? "TBD") \(realData[indexPath.row]["dates"]["start"]["localTime"].rawString() ?? "TBD")"
        return cell //4.
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
