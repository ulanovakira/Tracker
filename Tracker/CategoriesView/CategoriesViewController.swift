//
//  CategoriesViewController.swift
//  Tracker
//
//  Created by Кира on 01.12.2023.
//

import Foundation
import UIKit

protocol CategoriesViewControllerDelegate: AnyObject {
    func didSelectCategory(category: String)
}

final class CategoriesViewController: UIViewController {
    weak var delegate: CategoriesViewControllerDelegate?
    private let categoriesViewModel = CategoriesViewModel()
    
    private lazy var titleLabel: UILabel =  {
        let label = UILabel()
        label.text = "Категория"
        label.textColor = .black
        label.font = UIFont(name: "SFProText-Medium", size: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.layer.cornerRadius = 16
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let placeholderView: UIImageView = {
        let placeholderView = UIImageView()
        placeholderView.image = UIImage(named: "placeholder")
        placeholderView.isHidden = false
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        return  placeholderView
    }()
    
    private let placeholderTextView: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно объединить по смыслу"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var newCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = UIFont(name: "SFProText-Medium", size: 16)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "YPBlack")
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(newCategoryButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        categoriesViewModel.delegate = self
        categoriesViewModel.didUpdateCategories()
        prepareView()
    }
    
    private func prepareView() {
        view.addSubview(newCategoryButton)
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(placeholderView)
        view.addSubview(placeholderTextView)
        tableView.dataSource = self
        tableView.delegate = self
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: newCategoryButton.topAnchor, constant: -25),
            
            newCategoryButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            newCategoryButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            newCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            newCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            
            
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            placeholderTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            placeholderTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            placeholderTextView.topAnchor.constraint(equalTo: placeholderView.bottomAnchor, constant: 18)
        ])
        
    }
    private func checkVisibleCategoriesEmpty() {
        if categoriesViewModel.trackerCategoryStore.numberOfCategories - 1 != 0 {
            placeholderView.isHidden = true
            placeholderTextView.isHidden = true
        } else {
            placeholderView.isHidden = false
            placeholderTextView.isHidden = false
        }
    }
    
    @objc func newCategoryButtonTapped() {
        print("newCategoryButton tapped")
        let newCategoryViewController = NewCategoryViewController()
        newCategoryViewController.delegate = categoriesViewModel
        newCategoryViewController.actionType = "add"
        present(newCategoryViewController, animated: true)
    }
}

extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = categoriesViewModel.categories[indexPath.row]
        cell.textLabel?.font = UIFont(name: "SFProText-Regular", size: 17)
        cell.backgroundColor = UIColor(named: "YPLightGray")
        cell.selectionStyle = .none
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("categories.count \(categoriesViewModel.categories.count - 1)")
        return categoriesViewModel.categories.count - 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

}
extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell!.accessoryType = .checkmark
        categoriesViewModel.selectCategory(index: indexPath)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell!.accessoryType = .none
    }
    private func deleteCategory(name: String) {
        print("delete category")
        let alert = UIAlertController(
            title: nil,
            message: "Эта категория точно не нужна?",
            preferredStyle: .actionSheet
        )
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.categoriesViewModel.deleteCategory(head: name)
            checkVisibleCategoriesEmpty()
            tableView.reloadData()
        }
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        present(alert, animated: true)
    }
        
    private func editCategory(name: String) {
        print("newCategoryButton tapped")
        let newCategoryViewController = NewCategoryViewController()
        newCategoryViewController.delegate = categoriesViewModel
        newCategoryViewController.actionType = "edit"
        newCategoryViewController.oldName = name
        let newName = newCategoryViewController.newName
        present(newCategoryViewController, animated: true)
        print("oldname \(name)")
        print("newname \(newName)")
        self.categoriesViewModel.editCategory(head: name, newHead: newName)
        tableView.reloadData()
        print("edit category")
    }
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let category = categoriesViewModel.categories[indexPath.row]
        return UIContextMenuConfiguration(actionProvider: { actions in
            return UIMenu(children: [
                UIAction(title: "Редактировать") { [weak self ] _ in
                    self?.editCategory(name: category)
                },
                UIAction(title: "Удалить") { [weak self] _ in
                    self?.deleteCategory(name: category)
                }
            ])
        })
    }
}

extension CategoriesViewController: CategoriesViewModelDelegate {
    func didUpdateCategories() {
        tableView.reloadData()
        checkVisibleCategoriesEmpty()
    }
    func didSelectCategory(category: String) {
        delegate?.didSelectCategory(category: category)
        print("selectedCategory \(category)")
    }
}
