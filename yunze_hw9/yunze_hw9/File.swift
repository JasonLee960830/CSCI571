//
//  File.swift
//  yunze_hw9
//
//  Created by  jasonlee on 2018/11/29.
//  Copyright © 2018 yunze li. All rights reserved.
//

import Foundation
class upcomingObject {
    var eventName : String
    var type : String
    var artist : String
    var link : String
    var time : String
    init(eventName:String, type:String, artist:String, link:String, time:String) {
        self.eventName = eventName
        self.type = type
        self.artist = artist
        self.link = link
        self.time = time
    }
}
