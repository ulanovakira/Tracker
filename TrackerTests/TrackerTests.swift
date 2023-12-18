//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Кира on 03.12.2023.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {

    func testViewControllerLightTheme() {
        let vc = TrackersViewController()
        
        assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    }
    
    func testViewControllerDarkTheme() {
        let vc = TrackersViewController()
        
        assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

}