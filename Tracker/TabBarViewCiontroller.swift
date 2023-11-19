//
//  TabBarViewCiontroller.swift
//  Tracker
//
//  Created by Кира on 30.10.2023.
//

import Foundation
import UIKit

final class TabBarViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trackerViewController = TrackersViewController()
        trackerViewController.tabBarItem = UITabBarItem(
            title: "Трекеры", image: UIImage(named: "trackersTabBar"), selectedImage: nil)
        
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "Статистика", image: UIImage(named: "statisticsTabBar"), selectedImage: nil)
        
        self.viewControllers = [trackerViewController, statisticsViewController]
        
        
    }
}
