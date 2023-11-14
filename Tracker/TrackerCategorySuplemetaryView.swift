//
//  TrackerCategorySuplemetaryView.swift
//  Tracker
//
//  Created by Кира on 14.11.2023.
//

import Foundation
import UIKit

class TrackerCategirySuplemetaryView: UICollectionReusableView {
    
    private var categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SFProText-Bold", size: 19)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(categoryLabel)
        
        NSLayoutConstraint.activate([
            categoryLabel.topAnchor.constraint(equalTo: topAnchor),
            categoryLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            categoryLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCategory(_ category: String) {
        categoryLabel.text = category
    }
}
