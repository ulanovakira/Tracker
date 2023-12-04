//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Кира on 04.12.2023.
//

import Foundation
import UIKit

final class FiltersViewController: UIViewController {
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
    }
}
