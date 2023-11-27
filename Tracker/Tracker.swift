//
//  Tracker.swift
//  Tracker
//
//  Created by Кира on 29.10.2023.
//

import Foundation
import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [Weekday]?
    let recordCount: Int
    
    init(id: UUID, name: String, color: UIColor, emoji: String, schedule: [Weekday], recordCount: Int) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.recordCount = recordCount
    }
}
enum Weekday: String, CaseIterable {
    case Monday = "Понедельник"
    case Tuesday = "Вторник"
    case Wednesday = "Среда"
    case Thursday = "Четверг"
    case Friday = "Пятница"
    case Saturday = "Суббота"
    case Sunday = "Воскресенье"
    
    var numberValue: Int {
        switch self {
        case .Monday: return 2
        case .Tuesday: return 3
        case .Wednesday: return 4
        case .Thursday: return 5
        case .Friday: return 6
        case .Saturday: return 7
        case .Sunday: return 1
        }
    }
    var shortName: String {
        switch self {
        case .Monday: return "Пн"
        case .Tuesday: return "Вт"
        case .Wednesday: return "Ср"
        case .Thursday: return "Чт"
        case .Friday: return "Пт"
        case .Saturday: return "Сб"
        case .Sunday: return "Вс"
        }
    }
    
    static func weekdaysToString(weekdays: [Weekday]?) -> String? {
        guard let weekdays else { return nil }
        var string = ""
        for day in weekdays {
            string += String(day.numberValue)
        }
        return string
    }
    
    static func stringToWeekdays(string: String?) -> [Weekday]? {
        guard let string else { return nil }
        var weekdays = [Weekday]()
        for (index, _) in string.enumerated() {
//            guard value == "1" else { continue }
            let weekday = Self.allCases[index]
            weekdays.append(weekday)
        }
        return weekdays
    }
    
}

