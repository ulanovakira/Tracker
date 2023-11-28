//
//  EmojiCollectionViewCell.swift
//  Tracker
//
//  Created by Кира on 17.11.2023.
//

import Foundation
import UIKit

class EmojiCollectionViewCell: UICollectionViewCell {
    let emojiLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(emojiLabel)
        emojiLabel.font = emojiLabel.font.withSize(32)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
       
       NSLayoutConstraint.activate([                             
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func getEmoji() -> String {
        return emojiLabel.text!
    }
    
    func didSelectEmoji() {
        emojiLabel.layer.cornerRadius = 16
        emojiLabel.layer.masksToBounds = true
        emojiLabel.backgroundColor = UIColor(named: "LightGray")
    }
    
    func didDeselectEmoji() {
        emojiLabel.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
