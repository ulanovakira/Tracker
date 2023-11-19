//
//  AddTrackerViewController.swift
//  Tracker
//
//  Created by Кира on 01.11.2023.
//

import Foundation
import UIKit

protocol AddTrackerViewControllerDelegate: AnyObject {
    func didSaveTracker(tracker: Tracker, category: String)
}

class AddTrackerViewController: UIViewController{
    weak var delegate: AddTrackerViewControllerDelegate?
    
    private let titleLabel: UILabel =  {
        let label = UILabel()
        label.text = "Создание трекера"
        label.textColor = .black
        label.font = UIFont(name: "SFProText-Medium", size: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var habitButton: UIButton = {
        let button = UIButton()
        button.setTitle("Привычка", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "SFProText-Medium", size: 16)
        button.backgroundColor = UIColor(named: "YPBlack")
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var eventButton: UIButton = {
        let button = UIButton()
        button.setTitle("Нерегулярное событие", for: .normal)
        button.titleLabel?.font = UIFont(name: "SFProText-Medium", size: 16)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "YPBlack")
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(eventButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        prepareView()
    }
    
    private func prepareView() {
        view.addSubview(titleLabel)
        view.addSubview(habitButton)
        view.addSubview(eventButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 25),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            habitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            habitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            habitButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            
            eventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16),
            eventButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            eventButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            eventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc func habitButtonTapped() {
        print("addHabbitButton tapped")
        let newHabbitViewController = NewTrackerViewController()
        newHabbitViewController.delegate = self
        newHabbitViewController.trackerType = "habbit"
        present(newHabbitViewController, animated: true)
    }
    @objc func eventButtonTapped() {
        print("addEventButton tapped")
        let newEventViewController = NewTrackerViewController()
        newEventViewController.delegate = self
        newEventViewController.trackerType = "event"
        present(newEventViewController, animated: true)
    }
}

extension AddTrackerViewController: NewTrackerViewControllerDelegate {
    func didSaveTracker(tracker: Tracker, category: String) {
        dismiss(animated: true)
        let tracker = tracker
        let category = category
        delegate?.didSaveTracker(tracker: tracker, category: category)
    }
}
