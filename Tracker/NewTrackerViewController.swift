//
//  NewHabitViewController.swift
//  Tracker
//
//  Created by Кира on 06.11.2023.
//

import Foundation
import UIKit

protocol NewTrackerViewControllerDelegate: AnyObject {
    func didSaveTracker(tracker: Tracker, category: String)
}


final class NewTrackerViewController: UIViewController{
    var trackerType: String = ""
    
    weak var delegate: NewTrackerViewControllerDelegate?
    weak var scheduleDelegate: ScheduleViewControllerDelegate?
    
    private var category: String = ["Категория 1", "Категория 2", "Категория 3", "Категория 4"].randomElement()!
    private var emoji: String = [ "🍇", "🍈", "🍉", "🍊", "🍋", "🍌", "🍍", "🥭"].randomElement()!
    private var color: UIColor = [UIColor(named: "RedSelection"), UIColor(named: "OrangeSelection"), UIColor(named: "BlueSelection"), UIColor(named: "VioletSelection"), UIColor(named: "GreenSelection"), UIColor(named: "PinkSelection")].randomElement()!!
    private var schedule: [Weekday] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        prepareView()
    }
    
    private let titleLabel: UILabel =  {
        let label = UILabel()
        label.text = "Новое нерегулярное событие"
        label.textColor = .black
        label.font = UIFont(name: "SFProText-Medium", size: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let categoryLabel: UILabel =  {
        let label = UILabel()
        label.text = "Категория"
        label.numberOfLines = 2
        label.textColor = .black
        label.font = UIFont(name: "SFProText-Regular", size: 17)
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let scheduleLabel: UILabel =  {
        let label = UILabel()
        label.text = "Расписание"
        label.numberOfLines = 2
        label.textColor = .black
        label.font = UIFont(name: "SFProText-Regular", size: 17)
        label.layer.masksToBounds = true
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let placeholderLabel: UILabel =  {
        let label = UILabel()
        label.text = "Введите название трекера"
        label.textColor = UIColor(named: "YPGray")
        label.font = UIFont(name: "SFProText-Regular", size: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let trackerNameTextField: UITextField = {
        let textView = UITextField(frame: .zero)
        textView.text = ""
        textView.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textView.leftViewMode = .always
        textView.textColor = UIColor(named: "YPBlack")
        textView.backgroundColor = UIColor(named: "YPLightGray")
        textView.font = UIFont(name: "SFProText-Regular", size: 17)
        textView.layer.cornerRadius = 16
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var getCategoryButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "getButton"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(getCategoryButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var getScheduleButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "getButton"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(getScheduleButtonTapped), for: .allTouchEvents)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать", for: .normal)
        button.titleLabel?.font = UIFont(name: "SFProText-Medium", size: 16)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "YPGray")
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.titleLabel?.font = UIFont(name: "SFProText-Medium", size: 16)
        button.setTitleColor(UIColor(named: "YPRed"), for: .normal)
        button.backgroundColor = .white
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(named: "YPRed")?.cgColor
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let categoryStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let scheduleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.layer.cornerRadius = 16
        stackView.layer.masksToBounds = true
        stackView.distribution = .equalSpacing
        stackView.backgroundColor = UIColor(named: "YPLightGray")
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let separatorView: UIView = {
        let separator = UIView()
        separator.backgroundColor = UIColor(named: "YPGray")
        separator.isHidden = true
        separator.translatesAutoresizingMaskIntoConstraints = false
        return separator
    }()
    
    private func prepareView() {
        view.addSubview(titleLabel)
        view.addSubview(trackerNameTextField)
        trackerNameTextField.delegate = self
        view.addSubview(placeholderLabel)
        view.addSubview(categoryLabel)
        view.addSubview(cancelButton)
        view.addSubview(createButton)
        view.addSubview(getCategoryButton)
        view.addSubview(scheduleLabel)
        view.addSubview(getScheduleButton)
        view.addSubview(separatorView)
        
        view.addSubview(stackView)
        view.addSubview(categoryStackView)
        view.addSubview(scheduleStackView)
        
        categoryStackView.addArrangedSubview(categoryLabel)
        categoryStackView.addArrangedSubview(getCategoryButton)
        
        stackView.addArrangedSubview(categoryStackView)
        
        
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: "Категория \n\(category)")
        attributedString.setColor(color: UIColor(named: "YPGray")!, forText: category)
        categoryLabel.attributedText = attributedString
        
        print(trackerType)
        
        if trackerType == "habbit" {
            scheduleStackView.addArrangedSubview(scheduleLabel)
            scheduleStackView.addArrangedSubview(getScheduleButton)
            
            stackView.addArrangedSubview(separatorView)
            stackView.addArrangedSubview(scheduleStackView)
            
            getScheduleButton.isHidden = false
            scheduleLabel.isHidden = false
            getScheduleButton.isEnabled = true
            separatorView.isHidden = false
            titleLabel.text = "Новая привычка"
            
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            titleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            trackerNameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            trackerNameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            trackerNameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            placeholderLabel.topAnchor.constraint(equalTo: trackerNameTextField.topAnchor, constant: 20),
            placeholderLabel.leadingAnchor.constraint(equalTo: trackerNameTextField.leadingAnchor, constant: 16),
            
            stackView.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            
            scheduleStackView.heightAnchor.constraint(equalToConstant: 75),
            categoryStackView.heightAnchor.constraint(equalToConstant: 75),
            
            categoryLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 16),
            scheduleLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 16),
            getCategoryButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -24),

            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            separatorView.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -32),
            separatorView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 16),
            
            getScheduleButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -24),
            
            cancelButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -34),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -34),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
            
            cancelButton.widthAnchor.constraint(equalTo: createButton.widthAnchor)
            
        ])
    }
    
    @objc func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc func createButtonTapped() {
        let id = UUID()
        guard let name = trackerNameTextField.text else { return }
        let tracker = Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule)
        print(tracker)
        
        delegate?.didSaveTracker(tracker: tracker, category: category)
    }
    
    @objc func getCategoryButtonTapped() {
    }
    
    @objc func getScheduleButtonTapped() {
        print("schedule button tapped")
        let scheduleViewController = ScheduleViewController()
        scheduleViewController.delegate = self
        present(scheduleViewController, animated: true)
    }
}

extension NewTrackerViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        placeholderLabel.isHidden = !textField.text!.isEmpty
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        placeholderLabel.isHidden = true
        createButton.isEnabled = true
        createButton.backgroundColor = UIColor(named: "YPBlack")
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        placeholderLabel.isHidden = !textField.text!.isEmpty
    }
}

extension NewTrackerViewController: ScheduleViewControllerDelegate {
    func didSelectSchedule(days: [Weekday]) {
        self.schedule = days
        var daysShort: [String] = []
        var daysString = ""
        for day in days {
            daysShort.append(day.shortName)
        }
        daysString = daysShort.joined(separator: ", ")
        print("days \(days)")
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: "Расписание \n\(daysString)")
        attributedString.setColor(color: UIColor(named: "YPGray")!, forText: daysString)
        
        scheduleLabel.attributedText = attributedString
    }
}
extension NSMutableAttributedString {

    func setColor(color: UIColor, forText stringValue: String) {
       let range: NSRange = self.mutableString.range(of: stringValue, options: .caseInsensitive)
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
    }

}
