//
//  ViewController.swift
//  yunze_hw9
//
//  Created by  jasonlee on 2018/11/19.
//  Copyright © 2018 yunze li. All rights reserved.
//

import UIKit
//import McPicker
//import CoreLocation
//import EasyToast
class ViewController: UIViewController{
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func tabChanged(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            SearchTabView.isHidden = false
            FavoritesTabView.isHidden = true
        case 1:
            SearchTabView.isHidden = true
            FavoritesTabView.isHidden = false
        default:
            break;
        }
    }
    @IBOutlet weak var SearchTabView: UIView!
    @IBOutlet weak var FavoritesTabView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SearchTabView.isHidden = false
        FavoritesTabView.isHidden = true
    }
}


