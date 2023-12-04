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
    private let categoriesViewModel = CategoriesViewModel()
    private var didSelectSchedule = false
    private var didSelectCategory = false
    private var category: String = ""
    private var emojies = [ "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    private var colors = [UIColor(named: "Selection1"), UIColor(named: "Selection2"), UIColor(named: "Selection3"), UIColor(named: "Selection4"), UIColor(named: "Selection5"), UIColor(named: "Selection6"), UIColor(named: "Selection7"), UIColor(named: "Selection8"), UIColor(named: "Selection9"), UIColor(named: "Selection10"), UIColor(named: "Selection11"), UIColor(named: "Selection12"), UIColor(named: "Selection13"), UIColor(named: "Selection14"), UIColor(named: "Selection15"), UIColor(named: "Selection16"), UIColor(named: "Selection17"), UIColor(named: "Selection18")]
    private var schedule: [Weekday] = []
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    var actionType: String = ""
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
        label.adjustsFontSizeToFitWidth = true
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emojiLabel: UILabel =  {
        let label = UILabel()
        label.text = "Emoji"
        label.textColor = .black
        label.font = UIFont(name: "SFProText-Bold", size: 19)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let recordCountLabel: UILabel =  {
        let label = UILabel()
        label.text = "5 дней"
        label.textColor = .black
        label.font = UIFont(name: "SFProText-Bold", size: 32)
        label.isHidden = true
        label.textAlignment = .center
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
        label.adjustsFontSizeToFitWidth = true
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
        textView.isUserInteractionEnabled = true
        textView.returnKeyType = UIReturnKeyType.done
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var getCategoryButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "getButton"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(getCategoryButtonTapped), for: .allTouchEvents)
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
    
    private let emojiCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.allowsMultipleSelection = false
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let colorCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.allowsMultipleSelection = false
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    
    private func prepareView() {
        view.addSubview(scrollView)
        view.addSubview(titleLabel)
        
        view.addSubview(recordCountLabel)
        scrollView.addSubview(trackerNameTextField)
        scrollView.addSubview(placeholderLabel)
        scrollView.addSubview(categoryLabel)
        scrollView.addSubview(cancelButton)
        scrollView.addSubview(createButton)
        scrollView.addSubview(getCategoryButton)
        scrollView.addSubview(scheduleLabel)
        scrollView.addSubview(getScheduleButton)
        scrollView.addSubview(separatorView)
        scrollView.addSubview(emojiCollectionView)
        scrollView.addSubview(colorCollectionView)
        
        trackerNameTextField.delegate = self
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        emojiCollectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: "emojiCell")
        emojiCollectionView.register(TrackerCategirySuplemetaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
        colorCollectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: "colorCell")
        colorCollectionView.register(TrackerCategirySuplemetaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        
        scrollView.addSubview(stackView)
        view.addSubview(categoryStackView)
        view.addSubview(scheduleStackView)
        
        categoryStackView.addArrangedSubview(categoryLabel)
        categoryStackView.addArrangedSubview(getCategoryButton)
        
        stackView.addArrangedSubview(categoryStackView)
        
        
        
        categoryLabel.isUserInteractionEnabled = true
        categoryLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(getCategoryButtonTapped)))
        
        print(trackerType)
        
        if trackerType == "habbit" {
            scheduleStackView.addArrangedSubview(scheduleLabel)
            scheduleStackView.addArrangedSubview(getScheduleButton)
            scheduleLabel.isUserInteractionEnabled = true
            scheduleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(getScheduleButtonTapped)))
            stackView.addArrangedSubview(separatorView)
            stackView.addArrangedSubview(scheduleStackView)
            
            getScheduleButton.isHidden = false
            scheduleLabel.isHidden = false
            getScheduleButton.isEnabled = true
            separatorView.isHidden = false
            if actionType != "edit" {
                titleLabel.text = "Новая привычка"
            } else {
                titleLabel.text = "Редактирование привычки"
            }
            
        } else {
            if actionType != "edit" {
                titleLabel.text = "Новое нерегулярное событие"
            } else {
                titleLabel.text = "Редактирование нерегулярного события"
            }
        }
        
        if actionType == "edit" {
            recordCountLabel.isHidden = false
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            titleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            recordCountLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            recordCountLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            recordCountLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.topAnchor.constraint(equalTo: recordCountLabel.bottomAnchor, constant: 38),
            
            trackerNameTextField.topAnchor.constraint(equalTo: scrollView.topAnchor),
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
            categoryLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -45),
            scheduleLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 16),
            scheduleLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -45),
            
            getCategoryButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -24),
            getScheduleButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -24),

            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            separatorView.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -32),
            separatorView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 16),
            
            
            emojiCollectionView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 32),
            emojiCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            emojiCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            colorCollectionView.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor),
            colorCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            colorCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 204),
            colorCollectionView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -46),
            
            cancelButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),

            createButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 60),

            createButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),

            cancelButton.widthAnchor.constraint(equalTo: createButton.widthAnchor)
            
        ])
    }
    
    private func didDoneAllStaff() {
        if !trackerNameTextField.text!.isEmpty {
            if didSelectCategory == true {
                if (trackerType == "habbit" && didSelectSchedule == true) || trackerType != "habbit" {
                    if selectedColor != nil && !selectedEmoji!.isEmpty {
                        createButton.isEnabled = true
                        createButton.backgroundColor = UIColor(named: "YPBlack")
                    }
                }
            }
        }
    }
    
    func editTracker(tracker: Tracker, category: String) {
        placeholderLabel.isHidden = true
        trackerNameTextField.text = tracker.name
        emojiLabel.text = tracker.emoji
        
        didSelectSchedule(days: tracker.schedule!)
        didSelectCategory(category: category)
    }
    
    @objc func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc func createButtonTapped() {
        let id = UUID()
        guard let name = trackerNameTextField.text else { return }
        if trackerType != "habbit" {
            schedule = [Weekday.Monday, Weekday.Tuesday, Weekday.Wednesday, Weekday.Thursday, Weekday.Friday, Weekday.Saturday, Weekday.Sunday]
        }
        let tracker = Tracker(id: id, name: name, color: selectedColor!, emoji: selectedEmoji!, schedule: schedule, recordCount: 0)
        print(tracker)

        delegate?.didSaveTracker(tracker: tracker, category: category)
    }
    
    @objc func getCategoryButtonTapped() {
        print("category button tapped")
        let categoriesViewController = CategoriesViewController()
        categoriesViewController.delegate = self
        present(categoriesViewController, animated: true)
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
        didDoneAllStaff()
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        placeholderLabel.isHidden = true
        didDoneAllStaff()
       
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        placeholderLabel.isHidden = !textField.text!.isEmpty
        didDoneAllStaff()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        didDoneAllStaff()
        return false
    }
}

extension NewTrackerViewController: ScheduleViewControllerDelegate {
    func didSelectSchedule(days: [Weekday]) {
        if !days.isEmpty {
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
            didSelectSchedule = true
            print("didSelectSchedule \(didSelectSchedule)")
            didDoneAllStaff()
        }
    }
}

extension NewTrackerViewController: CategoriesViewControllerDelegate {
    func didSelectCategory(category: String) {
            self.category = category
            let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: "Категория \n\(category)")
            attributedString.setColor(color: UIColor(named: "YPGray")!, forText: category)
            categoryLabel.attributedText = attributedString
            didSelectCategory = true
            didDoneAllStaff()
    }
}
extension NSMutableAttributedString {

    func setColor(color: UIColor, forText stringValue: String) {
       let range: NSRange = self.mutableString.range(of: stringValue, options: .caseInsensitive)
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
    }

}

extension NewTrackerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollectionView {
            return emojies.count
        } else {
            return colors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiCell", for: indexPath) as? EmojiCollectionViewCell
            
            cell?.emojiLabel.text = emojies[indexPath.row]
            return cell!
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath) as? ColorCollectionViewCell
            cell?.configureColorCell(color: colors[indexPath.row]!)
            return cell!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? TrackerCategirySuplemetaryView else { return UICollectionReusableView() }
        if collectionView == emojiCollectionView {
            view.setCategory("Emoji")
        } else {
            view.setCategory("Цвет")
        }
        return view
    }
}
extension NewTrackerViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 8, left: 16, bottom: 16, right: 16)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)

        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,
                                                         height: UIView.layoutFittingExpandedSize.height),
                                                         withHorizontalFittingPriority: .required,
                                                         verticalFittingPriority: .fittingSizeLevel)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
           return 5
       }
}

extension NewTrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell
            cell?.didSelectEmoji()
            selectedEmoji = cell?.getEmoji()
            didDoneAllStaff()
        } else {
            let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell
            cell?.didSelectColor()
            selectedColor = cell?.getColor()
            didDoneAllStaff()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell
            cell?.didDeselectEmoji()
        } else {
            let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell
            cell?.didDeselectColor()
            
        }
    }
}
