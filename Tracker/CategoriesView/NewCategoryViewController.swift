//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Кира on 02.12.2023.
//

import Foundation
import UIKit

protocol NewCategoryViewControllerDelegate: AnyObject {
    func didAddCategory(name: String)
}

final class NewCategoryViewController: UIViewController {
    weak var delegate: NewCategoryViewControllerDelegate?
    private var category: String?
    var actionType: String = ""
    var oldName: String = ""
    var newName: String = ""
    
    private let categoriesViewModel = CategoriesViewModel()
    private lazy var titleLabel: UILabel =  {
        let label = UILabel()
        label.text = "Новая категория"
        label.textColor = .black
        label.font = UIFont(name: "SFProText-Medium", size: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let placeholderLabel: UILabel =  {
        let label = UILabel()
        label.text = "Введите название категории"
        label.textColor = UIColor(named: "YPGray")
        label.font = UIFont(name: "SFProText-Regular", size: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let categoryNameTextField: UITextField = {
        let textView = UITextField(frame: .zero)
        textView.text = ""
        textView.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textView.leftViewMode = .always
        textView.textColor = UIColor(named: "YPBlack")
        textView.backgroundColor = UIColor(named: "YPLightGray")
        textView.font = UIFont(name: "SFProText-Regular", size: 17)
        textView.layer.cornerRadius = 16
        textView.isUserInteractionEnabled = true
        textView.returnKeyType = UIReturnKeyType.done
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = UIFont(name: "SFProText-Medium", size: 16)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "YPGray")
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.isEnabled = false
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
        view.addSubview(categoryNameTextField)
        view.addSubview(placeholderLabel)
        view.addSubview(createButton)
        
        categoryNameTextField.delegate = self
        if actionType == "edit" {
            titleLabel.text = "Редактирование категории"
            categoryNameTextField.text = oldName
            placeholderLabel.isHidden = true
        }
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            titleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            categoryNameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            categoryNameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            categoryNameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            categoryNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            placeholderLabel.topAnchor.constraint(equalTo: categoryNameTextField.topAnchor, constant: 20),
            placeholderLabel.leadingAnchor.constraint(equalTo: categoryNameTextField.leadingAnchor, constant: 16),
            
            createButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            createButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc func createButtonTapped() {
        print(categoryNameTextField.text as Any)
        print("delegate \(String(describing: delegate))")
        delegate?.didAddCategory(name: categoryNameTextField.text ?? "")
        dismiss(animated: true)
    }
}
extension NewCategoryViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        placeholderLabel.isHidden = !textField.text!.isEmpty
        if !categoryNameTextField.text!.isEmpty {
            createButton.isEnabled = true
            createButton.backgroundColor = UIColor(named: "YPBlack")
            newName = categoryNameTextField.text!
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        placeholderLabel.isHidden = true
        
        if !categoryNameTextField.text!.isEmpty {
            createButton.isEnabled = true
            createButton.backgroundColor = UIColor(named: "YPBlack")
            newName = categoryNameTextField.text!
        }
       
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        placeholderLabel.isHidden = !textField.text!.isEmpty
        
        if !categoryNameTextField.text!.isEmpty {
            createButton.isEnabled = true
            createButton.backgroundColor = UIColor(named: "YPBlack")
            newName = categoryNameTextField.text!
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        
        if !categoryNameTextField.text!.isEmpty {
            createButton.isEnabled = true
            createButton.backgroundColor = UIColor(named: "YPBlack")
            newName = categoryNameTextField.text!
        }
        return false
    }
}
extension NewCategoryViewController: NewCategoryViewControllerDelegate {
    func didAddCategory(name: String) {
        print("add")
        category = name
    }
}
