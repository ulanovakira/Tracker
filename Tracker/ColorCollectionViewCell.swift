//
//  ColorCollectionViewCell.swift
//  Tracker
//
//  Created by Кира on 19.11.2023.
//

import Foundation
import UIKit

class ColorCollectionViewCell: UICollectionViewCell {
    let colorLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(colorLabel)
        colorLabel.layer.cornerRadius = 8
        colorLabel.layer.masksToBounds = true
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        
       
       NSLayoutConstraint.activate([
            colorLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorLabel.heightAnchor.constraint(equalToConstant: 40),
            colorLabel.widthAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func configureColorCell(color: UIColor) {
        colorLabel.backgroundColor = color
    }
    
    func getColor() -> UIColor {
        return colorLabel.backgroundColor!
    }
    
    func didSelectColor() {
        contentView.layer.borderWidth = 3
        contentView.layer.borderColor = colorLabel.backgroundColor?.withAlphaComponent(0.3).cgColor
        contentView.layer.cornerRadius = 8
    }
    
    func didDeselectColor() {
        contentView.layer.borderWidth = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
