//
//  File.swift
//  Tracker
//
//  Created by Кира on 29.10.2023.
//

import Foundation

struct TrackerCategory {
    let head: String
    let trackers: [Tracker]
    
    init(head: String, trackers: [Tracker]) {
        self.head = head
        self.trackers = trackers
    }
}
