//
//  Colors.swift
//  Tracker
//
//  Created by Кира on 04.12.2023.
//

import Foundation
import UIKit

final class Colors {
    var backgroundColor: UIColor = .systemBackground
    
    var trackersLabelColor: UIColor = UIColor { (traits) -> UIColor in
        let isDarkMode = traits.userInterfaceStyle == .dark
        return isDarkMode ? UIColor.white : UIColor.black
    }
    
    var datePickerColor: UIColor = UIColor { (traits) -> UIColor in
        let isDarkMode = traits.userInterfaceStyle == .dark
        return isDarkMode ? UIColor.black : UIColor.white
    }
}
