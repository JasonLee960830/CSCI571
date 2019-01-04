//
//  InfoViewController.swift
//  yunze_hw9
//
//  Created by  jasonlee on 2018/11/24.
//  Copyright © 2018 yunze li. All rights reserved.
//
import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner
class InfoViewController: UIViewController {
    var eventId : String?
    var ticketLink : String?
    var seatLink : String?
    var dataToArtist : JSON?
    static var team1 : String?
    static var team2 : String?
    static var image1: JSON?
    static var info1 : JSON?
    static var info2 : JSON?
    static var image2 : JSON?
    static var venue : String?

    @IBAction func goBack(_ sender: Any) {
        self.performSegue(withIdentifier: "goBackToDetailTable", sender: self)
    }
    @IBOutlet weak var teamName: UILabel!
    @IBOutlet weak var venueName: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var priceRange: UILabel!
    @IBOutlet weak var ticketStatus: UILabel!
    @IBAction func linkToTicket(_ sender: Any) {
        self.openUrl(url: ticketLink)
    }
    @IBAction func linkToSeat(_ sender: Any) {
        self.openUrl(url : seatLink)
    }
    func openUrl(url:String!) {
        let targetURL=NSURL(string: url)
        
        let application=UIApplication.shared
        
        application.open(targetURL! as URL, options: [:], completionHandler: nil);
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let TabBar = tabBarController as! EventDetailPageViewController
          eventId = TabBar.eventId
        let detailUrl : String = "http://yunzehw8backend.us-east-2.elasticbeanstalk.com/showDetails?eventId=\(eventId ?? "")"
        Alamofire.request(detailUrl).responseJSON{
            response in
            if(response.result.isSuccess){
                let returnedValue = JSON(response.result.value!)
                var teamLabel : String?
                for (index, team) in returnedValue["_embedded"]["attractions"]{
                    if(index=="0"){
                        teamLabel = team["name"].rawString()
                        InfoViewController.team1 = teamLabel
                        InfoViewController.team2 = ""
                    }
                    else if(index == "1"){
                        print("team2's name is \(team["name"].rawString() ?? "")")
                        InfoViewController.team2 = team["name"].rawString()
                        teamLabel = "\(teamLabel ?? "N/A")|\(team["name"].rawString() ?? "N/A")"
                    }
                }
                self.dataToArtist = returnedValue["_embedded"]["attractions"]
                self.teamName.text = teamLabel
                self.venueName.text = returnedValue["_embedded"]["venues"][0]["name"].rawString()
                InfoViewController.venue = returnedValue["_embedded"]["venues"][0]["name"].rawString()
                self.time.text = "\(returnedValue["dates"]["start"]["localDate"]) \(returnedValue["dates"]["start"]["localTime"])"
                self.category.text = "\( returnedValue["classifications"][0]["segment"]["name"])-\(returnedValue["classifications"][0]["genre"]["name"])"
                let minPrice = returnedValue["priceRanges"][0]["min"].rawString()
                let maxPrice = returnedValue["priceRanges"][0]["max"].rawString()
                if(minPrice == "null" && minPrice != "null"){
                   self.priceRange.text = "\(maxPrice ?? "N/A")"
                }
                else if(minPrice != "null" && minPrice == "null"){
                    self.priceRange.text = "\(minPrice ?? "N/A")"
                }
                else if(minPrice == "null" && minPrice == "null"){
                    self.priceRange.text = "N/A"
                }
                else{
                    self.priceRange.text = "\(minPrice ?? "N/A")-\(maxPrice ?? "N/A")"
                }
                self.ticketStatus.text = returnedValue["dates"]["status"]["code"].rawString()
                self.ticketLink = returnedValue["url"].rawString()
                self.seatLink = returnedValue["seatmap"]["staticUrl"].rawString()
            }
            else{
                print("asking failed")
            }
            let processedTeam1 = InfoViewController.team1!.replacingOccurrences(of: " ", with: "+")
            let artistUrl1 : String = "http://yunzehw8backend.us-east-2.elasticbeanstalk.com/showArtistInfo2?artistNames=\(processedTeam1 )"
            Alamofire.request(artistUrl1).responseJSON{
                response in
                if(response.result.isSuccess){
                    let returned = JSON(response.result.value!)
                    print("processing")
                    InfoViewController.image1 = returned["items"]
                }
                else{
                    print("fail request")
                }
            }
            let artistInfoUrl1 : String = "http://yunzehw8backend.us-east-2.elasticbeanstalk.com/showArtistInfo1?artistName=\(processedTeam1 )"
            Alamofire.request(artistInfoUrl1).responseJSON{
                response in
                if(response.result.isSuccess){
                    let returnedData = JSON(response.result.value!)
                    InfoViewController.info1 = returnedData
                }
                else{
                    
                }
            }
            if(InfoViewController.team2 != ""){
                let processedTeam2 = InfoViewController.team2!.replacingOccurrences(of: " ", with: "+")
                let artistUrl2 : String = "http://yunzehw8backend.us-east-2.elasticbeanstalk.com/showArtistInfo2?artistNames=\(processedTeam2 )"
                print(artistUrl2)
            Alamofire.request(artistUrl2).responseJSON{
                    response in
                    if(response.result.isSuccess){
                        let returned = JSON(response.result.value!)
                        print("processing")
                        InfoViewController.image2 = returned["items"]
                    }
                    else{
                        print("fail request")
                    }
                }
                let artistInfoUrl2 : String = "http://yunzehw8backend.us-east-2.elasticbeanstalk.com/showArtistInfo1?artistName=\(processedTeam2)"
                Alamofire.request(artistInfoUrl2).responseJSON{
                    response in
                    if(response.result.isSuccess){
                        let returnedData = JSON(response.result.value!)
                        print(returnedData)
                        InfoViewController.info2 = returnedData
                    }
                    else{
                        
                    }
                }
            }
        }
        // Do any additional setup after loading the view.
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
