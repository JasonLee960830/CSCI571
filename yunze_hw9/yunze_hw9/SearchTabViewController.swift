//
//  SearchTabViewController.swift
//  yunze_hw9
//
//  Created by  jasonlee on 2018/11/20.
//  Copyright © 2018 yunze li. All rights reserved.
//

import UIKit
import McPicker
import CoreLocation
import EasyToast
import SwiftyJSON
import Alamofire
import SwiftSpinner
import SearchTextField
class SearchTabViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate{
    static var keywordText : String?
    var locationManager = CLLocationManager()
    var currentLocation : [String : String]?
    var formLocation : String = "currentLocation"
    var unitText : String?
    var formInfo : [String : String]?
    let searchUrl : String = "http://yunzehw8backend.us-east-2.elasticbeanstalk.com/search"
    var searchResult : JSON?
    var autoCompleteData : Array<String> = []
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count-1]
        if(location.horizontalAccuracy>0){
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            print("longitude=\(location.coordinate.longitude),latitude=\(location.coordinate.latitude)")
            let currentLongitude = String(location.coordinate.longitude)
            let currentLatitude = String(location.coordinate.latitude)
            self.currentLocation = ["lng": currentLongitude, "lat" : currentLatitude]
            
        }
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return unitData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        unitText = unitData[row]
        return unitData[row]
    }

    
    let data: [[String]] = [
        ["All", "Music", "Sports", "Arts & Theatre", "Film", "Miscellaneous"]
    ]
    @IBAction func clearPressed(_ sender: Any) {
        keyword.text = ""
        category.text = "All"
        distance.text = ""
        unitText = "miles"
        if let button1 = self.view.viewWithTag(1) as? UIButton{
            button1.setImage(UIImage(named:"grey"), for:[])
            customLocation?.isUserInteractionEnabled = false
        }
        if let button2 = self.view.viewWithTag(2) as? UIButton
        {
            button2.setImage(UIImage(named:"white"), for:[])
        }
        formLocation = "currentLocation"
        customLocation.text = ""
        unit.reloadAllComponents()
        unit.selectRow(0, inComponent: 0, animated: true)
    }
    @IBOutlet weak var keyword: SearchTextField!
    @IBOutlet weak var testField: SearchTextField!
    @IBOutlet weak var category: McTextField!
    @IBOutlet weak var distance: UITextField!
    @IBOutlet weak var unit: UIPickerView!
    @IBOutlet weak var customLocation: UITextField!
    var unitData: [String] = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        keyword.filterStrings([])
        keyword.theme.font = UIFont.systemFont(ofSize: 14)
        keyword.theme.separatorColor = UIColor (red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        keyword.theme.bgColor = UIColor (red: 1, green: 1, blue: 1, alpha: 1)
        keyword.userStoppedTypingHandler = {
            if let criteria = self.keyword.text {
                if criteria != ""{
                    
                    // Show the loading indicator
                    let autoCompleteUrl = "http://yunzehw8backend.us-east-2.elasticbeanstalk.com/autocomplete?keyword=\(self.keyword.text!.replacingOccurrences(of: " ", with: "+"))"
                    self.keyword.showLoadingIndicator()
                    print(autoCompleteUrl)
                    Alamofire.request(autoCompleteUrl).responseJSON{
                        response in
                        if(response.result.isSuccess){
                            let data = JSON(response.result.value!)["_embedded"]["attractions"]
                            self.autoCompleteData = []
                            var count : Int! = 0
                            while(count<data.count){ self.autoCompleteData.append(data[count]["name"].rawString()!)
                                count = count+1
                            }
                        self.keyword.filterStrings(self.autoCompleteData)
                    print(self.keyword.text!)
                    self.keyword.stopLoadingIndicator()
                    }
                        else{
                            self.keyword.stopLoadingIndicator()
                        }
                }
            }
            }
        }
        //set up location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        self.unit.delegate = self
        self.unit.dataSource = self
        unitData = ["miles","kms"]
        let mcInputView = McPicker(data: data)
        mcInputView.backgroundColor = .gray
        mcInputView.backgroundColorAlpha = 0.25
        category.text = "All"
        category.doneHandler = { [weak category] (selections) in
            category?.text = selections[0]!
        }
        category.selectionChangedHandler = { [weak category] (selections, componentThatChanged) in
            category?.text = selections[componentThatChanged]!
        }
        category.cancelHandler = { [weak category] in
            category?.text = "Cancelled."
        }
        category.textFieldWillBeginEditingHandler = { [weak category] (selections) in
            if category?.text == "" {
                // Selections always default to the first value per component
                category?.text = selections[0]
            }
        }
        customLocation?.isUserInteractionEnabled = false
        // Do any additional setup after loading the view, typically from a nib.
    }
    

    @IBAction func categoryPressed(_ sender: Any) {
        McPicker.show(data: data, doneHandler: { [weak self] (selections: [Int:String]) in
            if let name = selections[0] {
                self?.category.text = name
            }
            }, cancelHandler: {
                print("Canceled Default Picker")
        }, selectionChangedHandler: { (selections: [Int:String], componentThatChanged: Int) in
            let newSelection = selections[componentThatChanged] ?? "Failed to get new selection!"
            print("Component \(componentThatChanged) changed value to \(newSelection)")
        })
    }
    
    @IBAction func toggleLocation(_ sender: Any) {
        if((sender as AnyObject).tag==1){
            (sender as AnyObject).setImage(UIImage(named: "grey"), for: [])
            if let button = self.view.viewWithTag(2) as? UIButton
            {
                button.setImage(UIImage(named:"white"), for:[])
            }
            customLocation?.isUserInteractionEnabled = false
            formLocation = "currentLocation"
        }
        if((sender as AnyObject).tag==2)
        {
            (sender as AnyObject).setImage(UIImage(named: "grey"), for: [])
            if let button = self.view.viewWithTag(1) as? UIButton
            {
                button.setImage(UIImage(named:"white"), for:[])
            }
            customLocation?.isUserInteractionEnabled = true
            formLocation = "otherLocation"
        }
    }
    @IBAction func searchPressed(_ sender: Any) {
        if(keyword.text==""||(formLocation=="otherLocation"&&customLocation.text=="")){
            self.view.showToast("Keyword and location are mandatory fields", position: .bottom, popTime: 2, dismissOnTap: false)
        }
        else{
            let formInfo : [String : String] = ["formCategory" : category.text ?? "All", "formDistance" : distance.text ?? "10", "formUnit" : unitText ?? "miles", "formLocation" : formLocation, "formKeyword" : keyword.text ?? "", "formSpecifiedLocation" : customLocation.text ?? "", "currentLon" : (currentLocation?["lng"])!, "currentLat" : (currentLocation?["lat"])!]
            self.formInfo = formInfo
            //        print(formInfo)
            SwiftSpinner.show("Searching for events...")
            Alamofire.request(searchUrl,method: .get, parameters: formInfo).responseJSON{
                response in
                if(response.result.isSuccess){
                    self.searchResult = JSON(response.result.value!)
                    print("Success!!")
                    SwiftSpinner.hide()
                    self.performSegue(withIdentifier: "goToDetailPage", sender: self)
                }
                else{
                    print("failed")
                }
            }

//            performSegue(withIdentifier: "goToDetailPage", sender: self)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "goToDetailPage"){
            SearchTabViewController.keywordText = self.keyword.text
            let destinationVC = segue.destination as! DetailTableViewController
//            destinationVC.formInfo = self.formInfo
            destinationVC.searchResult = self.searchResult
        }
    }
}
