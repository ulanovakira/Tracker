//
//  TrackerViewCell.swift
//  Tracker
//
//  Created by Кира on 11.11.2023.
//

import Foundation
import UIKit

protocol TrackerViewCellDelegate: AnyObject {
    func plusButtonTapped(cell: TrackerViewCell, tracker: Tracker)
}

class TrackerViewCell: UICollectionViewCell {
    
    weak var delegate: TrackerViewCellDelegate?
    private var tracker: Tracker?
    private var days: Int = 0
    let analyticService = AnalyticService()
    private let colors = Colors()
    
    private let cellView: UIView = {
        let cell = UIView()
        cell.layer.cornerRadius = 16
        cell.translatesAutoresizingMaskIntoConstraints = false
        return cell
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.text = "❤️"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let pinImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "pinTracker")
//        image.isHidden = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let daysCountLabel: UILabel = {
        let label = UILabel()
        label.text = "1 день"
        label.font = UIFont(name: "SFProText-Medium", size: 12)
        label.textColor = UIColor(named: "YPBlack")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var plusButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 17
        button.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let trackerDescription: UILabel = {
        let label = UILabel()
        label.text = "Доделать домашку"
        label.textColor = .white
        label.font = UIFont(name: "SFProText-Medium", size: 12)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareView()
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func prepareView() {
        contentView.addSubview(cellView)
        cellView.addSubview(emojiLabel)
        cellView.addSubview(trackerDescription)
        contentView.addSubview(daysCountLabel)
        contentView.addSubview(plusButton)
        cellView.addSubview(pinImage)
        daysCountLabel.textColor = colors.trackersLabelColor
        NSLayoutConstraint.activate([
            cellView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cellView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.topAnchor.constraint(equalTo: cellView.topAnchor, constant: 13),
            emojiLabel.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 16),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            
            trackerDescription.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8),
            trackerDescription.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 12),
            trackerDescription.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -12),
            
            plusButton.topAnchor.constraint(equalTo: cellView.bottomAnchor, constant: 8),
            plusButton.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -12),
            plusButton.heightAnchor.constraint(equalToConstant: 34),
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            
            daysCountLabel.topAnchor.constraint(equalTo: cellView.bottomAnchor, constant: 16),
            daysCountLabel.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 12),
            
            pinImage.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -12),
            pinImage.topAnchor.constraint(equalTo: cellView.topAnchor, constant: 18)
        ])
    }
    
    func pinTracker(isPinned: Bool) {
        if isPinned {
            pinImage.isHidden = false
        } else {
            pinImage.isHidden = true
        }
    }
    
    func addDays() {
        days += 1
    }
    func removeDays() {
        days -= 1
    }
    func configRecord(isDone: Bool) {
            configPlusButtonImage(isDone: isDone)
            configureTextLabel(days: days)
   }
   
   private func configPlusButtonImage(isDone: Bool) {
       if isDone {
           plusButton.setImage(UIImage(named: "doneTracker"), for: .normal)
           plusButton.alpha = 0.3
           plusButton.tintColor = .white
       } else {
           plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
           plusButton.layer.opacity = 1
       }
   }
    
    func configureCellData(tracker: Tracker, days: Int) {
        self.tracker = tracker
        self.days = days
        cellView.backgroundColor = tracker.color
        emojiLabel.text = tracker.emoji
        trackerDescription.text = tracker.name
        plusButton.backgroundColor = tracker.color
    }
    
    private func configureTextLabel(days: Int) {
        switch days % 10 {
        case 1:
            daysCountLabel.text = "\(days) \(NSLocalizedString("day.one", comment: ""))"
        case 2...4:
            daysCountLabel.text = "\(days) \(NSLocalizedString("day.singular", comment: ""))"
        default:
            daysCountLabel.text = "\(days) \(NSLocalizedString("day.plural", comment: ""))"
        }
    }
    
    @objc func plusButtonTapped() {
        guard let tracker else { return }
        delegate?.plusButtonTapped(cell: self, tracker: tracker)
        analyticService.reportEvent(event: .click, screen: .main, item: .track)
    }
}
