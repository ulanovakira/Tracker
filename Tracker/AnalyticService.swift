//
//  AnalyticService.swift
//  Tracker
//
//  Created by Кира on 04.12.2023.
//

import Foundation
import YandexMobileMetrica

struct AnalyticService {
    enum Event: String {
        case open = "open"
        case close = "close"
        case click = "click"
    }
    
    enum Screen: String {
        case main = "Main"
    }
    
    enum Item: String {
        case add_track = "add_track"
        case track = "track"
        case filter = "filter"
        case edit = "edit"
        case delete = "delete"
    }
    
    func reportEvent(event: Event, screen: Screen, item: Item? = nil) {
        var params: [AnyHashable: Any] = [:]
        switch event {
        case .click:
            params = [
                "screen": screen.rawValue,
                "item": item?.rawValue ?? "none"
            ]
        case .open, .close:
            params = [
                "screen": screen.rawValue
            ]
        }
        YMMYandexMetrica.reportEvent(event.rawValue, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
