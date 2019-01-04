//
//  EventDetailPageViewController.swift
//  
//
//  Created by  jasonlee on 2018/11/24.
//

import UIKit

class EventDetailPageViewController: UITabBarController {
    var eventId : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        print("success from eventDetailView")
        print(eventId ?? "not successful passing data")
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
