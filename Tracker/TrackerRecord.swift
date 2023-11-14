//
//  TrackerRecord.swift
//  Tracker
//
//  Created by Кира on 29.10.2023.
//

import Foundation

struct TrackerRecord: Hashable {
    let id: UUID
    let date: Date
    
    init(id: UUID, date: Date) {
        self.id = id
        self.date = date
    }
}
