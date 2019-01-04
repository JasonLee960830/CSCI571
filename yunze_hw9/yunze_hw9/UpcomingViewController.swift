//
//  UpcomingViewController.swift
//  yunze_hw9
//
//  Created by  jasonlee on 2018/11/26.
//  Copyright © 2018 yunze li. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner
class UpcomingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var upcomingData : JSON?
    var copyData : JSON?
    var sortingMethod : String = "default"
    var order : String = "acsending"
    private var eventName: [String] = ["1"]
    private var artist : [String] = ["1"]
    private var time : [String] = ["1"]
    private var type : [String] = ["1"]
    private var link : [String] = ["1"]
    private var eventNameCopy: [String] = ["1"]
    private var artistCopy : [String] = ["1"]
    private var timeCopy : [String] = ["1"]
    private var typeCopy : [String] = ["1"]
    private var linkCopy : [String] = ["1"]
    var sortingData : [upcomingObject] = []
    @IBOutlet weak var sortingBar: UISegmentedControl!
    @IBAction func sortingChanged(_ sender: Any) {
        var count = 0
        let sum = eventName.count
        while(count<sum){
            let newObject = upcomingObject(eventName: self.eventName[count], type: self.type[count], artist: self.artist[count], link: self.link[count], time: self.time[count])
            sortingData.append(newObject)
            count = count+1
        }
        
        
        switch sortingBar.selectedSegmentIndex
        {
        case 0:
            sortingMethod = "default"
            eventName = eventNameCopy
            artist = artistCopy
            type = typeCopy
            link = linkCopy
            time = timeCopy
            orderBar.isEnabled = false
        case 1:
            sortingMethod = "name"
            if(order == "acsending"){
                sortingData.sort(by: {$0.eventName<$1.eventName})
            }
            else{
                sortingData.sort(by: {$0.eventName>$1.eventName})
            }
            orderBar.isEnabled = true
        case 2:
            sortingMethod = "time"
            if(order == "acsending"){
                sortingData.sort(by: {$0.time<$1.time})
            }
            else{
                sortingData.sort(by: {$0.time>$1.time})
            }
            orderBar.isEnabled = true
        case 3:
            sortingMethod = "artist"
            if(order == "acsending"){
                sortingData.sort(by: {$0.artist<$1.artist})
            }
            else{
                sortingData.sort(by: {$0.artist>$1.artist})
            }
            orderBar.isEnabled = true
        case 4:
            sortingMethod = "type"
            if(order == "acsending"){
                sortingData.sort(by: {$0.type<$1.type})
            }
            else{
                sortingData.sort(by: {$0.type>$1.type})
            }
            orderBar.isEnabled = true
        default:
            break
        }
        eventName = []
        artist = []
        type = []
        link = []
        time = []
        for item in sortingData{
            eventName.append(item.eventName)
            artist.append(item.artist)
            type.append(item.type)
            link.append(item.link)
            time.append(item.time)
        }
        self.eventTable.reloadData()
        
    }
    @IBOutlet weak var orderBar: UISegmentedControl!
    @IBAction func orderChanged(_ sender: Any) {
        var count = 0
        let sum = eventName.count
        while(count<sum){
            let newObject = upcomingObject(eventName: self.eventName[count], type: self.type[count], artist: self.artist[count], link: self.link[count], time: self.time[count])
            sortingData.append(newObject)
            count = count+1
        }
        switch orderBar.selectedSegmentIndex{
        case 0:
            order = "acsending"
            if(sortingMethod=="name"){
                 sortingData.sort(by: {$0.eventName<$1.eventName})
            }
            if(sortingMethod=="type"){
                sortingData.sort(by: {$0.type<$1.type})
            }
            if(sortingMethod=="artist"){
                sortingData.sort(by: {$0.eventName<$1.eventName})
            }
            if(sortingMethod=="time"){
                sortingData.sort(by: {$0.eventName<$1.eventName})
            }
        case 1:
            order = "decsending"
            if(sortingMethod=="name"){
                sortingData.sort(by: {$0.eventName>$1.eventName})
            }
            if(sortingMethod=="type"){
                sortingData.sort(by: {$0.type>$1.type})
            }
            if(sortingMethod=="artist"){
                sortingData.sort(by: {$0.eventName>$1.eventName})
            }
            if(sortingMethod=="time"){
                sortingData.sort(by: {$0.eventName>$1.eventName})
            }
        default:
            break
        }
        eventName = []
        artist = []
        type = []
        link = []
        time = []
        for item in sortingData{
            eventName.append(item.eventName)
            artist.append(item.artist)
            type.append(item.type)
            link.append(item.link)
            time.append(item.time)
        }
        self.eventTable.reloadData()
    }
    @IBOutlet weak var eventTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        orderBar.isEnabled = false
        //copyData = upcomingData
        SwiftSpinner.show("showing...")
        eventTable.dataSource = self
        let venue = InfoViewController.venue!
        let processedVenue = venue.replacingOccurrences(of: " ", with: "+")
        let upcomingUrl = "http://yunzehw8backend.us-east-2.elasticbeanstalk.com/showUpcomingEvents?venueName=\(processedVenue)"
        Alamofire.request(upcomingUrl).responseJSON{
            response in
            if(response.result.isSuccess){
                self.upcomingData = JSON(response.result.value!)
                print(self.upcomingData!)
                print("success from upcoming!!")
                self.eventName = []
                self.artist = []
                self.time = []
                self.type = []
                self.link = []
                var cellNumber = self.upcomingData!["resultsPage"]["results"]["event"].count
                while(cellNumber>0){
                    self.type.append(self.upcomingData!["resultsPage"]["results"]["event"][cellNumber-1]["type"].rawString()!)
                    self.eventName.append(self.upcomingData!["resultsPage"]["results"]["event"][cellNumber-1]["displayName"].rawString()!)
                    self.artist.append(self.upcomingData!["resultsPage"]["results"]["event"][cellNumber-1]["performance"][0]["artist"]["displayName"].rawString()!)
                    self.time.append("\(self.upcomingData!["resultsPage"]["results"]["event"][cellNumber-1]["start"]["date"].rawString() ?? "N/A") \(self.upcomingData!["resultsPage"]["results"]["event"][cellNumber-1]["start"]["time"].rawString() ?? "N/A")")
                self.link.append(self.upcomingData!["resultsPage"]["results"]["event"][cellNumber-1]["uri"].rawString()!)
                    
                    cellNumber = cellNumber-1
                }
//                print("time")
//                print(self.time)
//                print("type")
//                print(self.type)
//                print("eventName")
//                print(self.eventName)
//                self.data = self.upcomingData!["resultsPage"]["results"]["event"]
                self.eventNameCopy = self.eventName
                self.typeCopy = self.type
                self.timeCopy = self.time
                self.artistCopy = self.artist
                self.eventTable.reloadData()
                SwiftSpinner.hide()
            }
        }
        // Do any additional setup after loading the view.
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print(upcomingData?["resultsPage"]["results"].count ?? "first function then load!!!!!!!!!!!!")
        return eventName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "upcomingTableViewCell", for: indexPath) as? UpcomingTableViewCell  else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        cell.eventName.setTitle(eventName[indexPath.row], for: cell.eventName.state)  //3.
        cell.artist.text = artist[indexPath.row]
        cell.type.text = type[indexPath.row]
        cell.time.text = time[indexPath.row]
        cell.link = link[indexPath.row]
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
