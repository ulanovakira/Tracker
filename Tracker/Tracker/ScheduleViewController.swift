//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Кира on 12.11.2023.
//

import Foundation
import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelectSchedule(days: [Weekday])
}

class ScheduleViewController: UIViewController {
    weak var delegate: ScheduleViewControllerDelegate?
    
    private var weekday = Weekday.allCases
    private var selectedSchedule: [Weekday] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        prepareView()
    }
    
    private let titleLabel: UILabel =  {
        let label = UILabel()
        label.text = "Расписание"
        label.textColor = .black
        label.font = UIFont(name: "SFProText-Medium", size: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.layer.cornerRadius = 16
        tableView.backgroundColor = UIColor(named: "YPLightGray")
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = UIFont(name: "SFProText-Medium", size: 16)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "YPBlack")
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private func prepareView() {
        view.addSubview(titleLabel)
        view.addSubview(doneButton)
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor(named: "YPLightGray")
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            titleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 525),
            
            doneButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -34),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc func doneButtonTapped() {
        print("done button tapped")
        print(selectedSchedule)
        if delegate != nil {
            print("yes")
        }
        delegate?.didSelectSchedule(days: selectedSchedule)
        dismiss(animated: true)
    }
}

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = weekday[indexPath.row].rawValue
        cell.textLabel?.font = UIFont(name: "SFProText-Regular", size: 17)
        let switchBar = UISwitch()
        switchBar.tag = indexPath.row
        switchBar.onTintColor = UIColor(named: "YPBlue")
        switchBar.addTarget(self, action: #selector(switchBarDidTapped), for: .valueChanged)
        cell.accessoryView = switchBar
        cell.backgroundColor = .clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekday.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    @objc func switchBarDidTapped(_ sender: UISwitch) {
        if sender.isOn {
            selectedSchedule.append(Weekday.allCases[sender.tag])
        } else {
            selectedSchedule.removeAll {$0 == Weekday.allCases[sender.tag]}
        }
    }
}
extension ScheduleViewController: UITableViewDelegate {
    
}
