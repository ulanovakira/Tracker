//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Кира on 30.10.2023.
//

import Foundation
import UIKit

class StatisticsViewController: UIViewController {
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    
    private lazy var titleHeader: UILabel =  {
        let label = UILabel()
        label.text = "Статистика"
        label.textColor = .black
        label.font = UIFont(name: "SFProText-Bold", size: 34)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var placeholderView: UIImageView = {
        let placeholderView = UIImageView()
        placeholderView.image = UIImage(named: "statisticsPlaceholder")
        placeholderView.isHidden = false
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        return  placeholderView
    }()
    
    private lazy var placeholderTextView: UILabel = {
        let label = UILabel()
        label.text = "Анализировать пока нечего"
        label.font = UIFont(name: "SFProText-Medium", size: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var countLabel: UILabel =  {
        let label = UILabel()
        label.text = "6"
        label.textColor = .black
        label.font = UIFont(name: "SFProText-Bold", size: 34)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var trackersDoneLabel: UILabel =  {
        let label = UILabel()
        label.textColor = .black
        label.text = "Трекеров завершено"
        label.font = UIFont(name: "SFProText-Medium", size: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.layer.cornerRadius = 16
        stackView.layer.masksToBounds = true
        stackView.distribution = .equalSpacing
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = UIColor(named: "Selection7")?.cgColor
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        prepareView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkVisibleCategoriesEmpty()
    }
    
    private func prepareView() {
        view.addSubview(titleHeader)
        view.addSubview(placeholderView)
        view.addSubview(placeholderTextView)
        view.addSubview(stackView)
        view.addSubview(countLabel)
        view.addSubview(trackersDoneLabel)
        stackView.addArrangedSubview(countLabel)
        stackView.addArrangedSubview(trackersDoneLabel)
        
        NSLayoutConstraint.activate([
            titleHeader.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            titleHeader.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            placeholderTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderTextView.topAnchor.constraint(equalTo: placeholderView.bottomAnchor, constant: 8),
            
            stackView.topAnchor.constraint(equalTo: titleHeader.bottomAnchor, constant: 80),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            stackView.heightAnchor.constraint(equalToConstant: 90),
            
            countLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 12),
            countLabel.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 12),
            
            trackersDoneLabel.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 8),
            trackersDoneLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 12)
        ])
    }
    
    private func checkVisibleCategoriesEmpty() {
        let completedTrackersCount = try? trackerRecordStore.getCompletedTrackersCount()
        print("completedTrackersCount \(String(describing: completedTrackersCount))")
        if completedTrackersCount != 0 {
            placeholderView.isHidden = true
            placeholderTextView.isHidden = true
            stackView.isHidden = false
            countLabel.text = String(completedTrackersCount ?? 0)
        } else {
            placeholderView.isHidden = false
            placeholderTextView.isHidden = false
            stackView.isHidden = true
        }
    }
}

