//
//  VenueViewController.swift
//  yunze_hw9
//
//  Created by  jasonlee on 2018/11/26.
//  Copyright © 2018 yunze li. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import GoogleMaps
class VenueViewController: UIViewController {

    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var venueName: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var openHours: UILabel!
    @IBOutlet weak var generalRules: UILabel!
    @IBOutlet weak var childRules: UILabel!
    @IBOutlet weak var googleMap: GMSMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let venue = InfoViewController.venue!
        venueName.text = venue
        let processedVenue = venue.replacingOccurrences(of: " ", with: "+")
        print(processedVenue)
        let venueUrl = "http://yunzehw8backend.us-east-2.elasticbeanstalk.com/showVenueInfo?venueName=\(processedVenue)"
        print(venueUrl)

        Alamofire.request(venueUrl).responseJSON{
            response in
            if(response.result.isSuccess){
                print ("processing")
                let returnedValue = JSON(response.result.value ?? "failing getting data")
                print("here")
                self.cityName.text = "\(returnedValue["_embedded"]["venues"][0]["city"]["name"]), \( returnedValue["_embedded"]["venues"][0]["state"]["name"])"
                self.phoneNumber.text = returnedValue["_embedded"]["venues"][0]["boxOfficeInfo"]["phoneNumberDetail"].rawString()
                self.openHours.text = returnedValue["_embedded"]["venues"][0]["boxOfficeInfo"]["openHoursDetail"].rawString()
                self.generalRules.text = returnedValue["_embedded"]["venues"][0]["generalInfo"]["generalRule"].rawString()
                self.childRules.text = returnedValue["_embedded"]["venues"][0]["generalInfo"]["childRule"].rawString()
                Alamofire.request("http://yunzehw8backend.us-east-2.elasticbeanstalk.com/geocode?venueName=\(processedVenue)").responseJSON{
                    mapdata in
                    if(mapdata.result.isSuccess){
                        let mapData = JSON(mapdata.result.value ?? "failing getting map data")
                        print(mapData)
                        let camera = GMSCameraPosition.camera(withLatitude: NSString(string:mapData["lat"].rawString()!).doubleValue, longitude: NSString(string:mapData["lng"].rawString()!).doubleValue, zoom: 14.0)
                        //                let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
                        self.googleMap.camera = camera
                        let initialLocation = CLLocationCoordinate2DMake(NSString(string:mapData["lat"].rawString()!).doubleValue, NSString(string:mapData["lng"].rawString()!).doubleValue)
                        let marker = GMSMarker(position: initialLocation)
                        //  marker.title = "Berlin"
                        marker.map = self.googleMap
                    }
                }
                
            }
            else{
                print(response)
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
