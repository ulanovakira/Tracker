//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Кира on 04.12.2023.
//

import Foundation
import UIKit

protocol FiltersViewControllerDelegate: AnyObject {
    func didSelectFilter(filter: String, filterFull: String)
}

final class FiltersViewController: UIViewController {
    private let filters: [String] = ["Все трекеры", "Трекеры на сегодня", "Завершенные", "Не завершенные"]
    var selectedFilter: String = ""
    weak var delegate: FiltersViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        prepareView()
    }
    private let titleLabel: UILabel =  {
        let label = UILabel()
        label.text = "Фильтры"
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
    
    private func prepareView() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            titleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    func selectFilter(index: IndexPath) {
        var filterShort = ""
        if filters[index.row] == "Все трекеры" {
            filterShort = "all"
        } else if filters[index.row] == "Трекеры на сегодня" {
            filterShort = "today"
        } else if filters[index.row] == "Завершенные" {
            filterShort = "done"
        } else if filters[index.row] == "Не завершенные" {
            filterShort = "notdone"
        }
            
        delegate?.didSelectFilter(filter: filterShort, filterFull: filters[index.row])
    }
}

extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = filters[indexPath.row]
        cell.textLabel?.font = UIFont(name: "SFProText-Regular", size: 17)
        cell.backgroundColor = .clear
        if selectedFilter == filters[indexPath.row] {
            cell.accessoryType = .checkmark
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell!.accessoryType = .checkmark
        selectFilter(index: indexPath)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell!.accessoryType = .none
    }
}
