//
//  ViewController.swift
//  Tracker
//
//  Created by Кира on 12.10.2023.
//

import UIKit
import Foundation

class TrackersViewController: UIViewController, UINavigationControllerDelegate{
    //mock trackers
    var categories: [TrackerCategory] = [TrackerCategory(head: "Категория 1", trackers: [Tracker(id: UUID(), name: "Первое дело", color: UIColor(named: "BlueSelection")!, emoji: "❤️", schedule: [Weekday.Wednesday])]),
                                         TrackerCategory(head: "Категория 2", trackers: [Tracker(id: UUID(), name: "Второе дело", color: UIColor(named: "RedSelection")!, emoji: "🙈", schedule: [Weekday.Thursday])]),
                                         TrackerCategory(head: "Категория 3", trackers: [Tracker(id: UUID(), name: "Третье дело", color: UIColor(named: "VioletSelection")!, emoji: "🤪", schedule: [Weekday.Wednesday])]),
                                         TrackerCategory(head: "Категория 4", trackers: [Tracker(id: UUID(), name: "Четвертое дело", color: UIColor(named: "PinkSelection")!, emoji: "🥶", schedule: [Weekday.Saturday])])]
    var completedTrackers: Set<TrackerRecord> = []
    var visibleCategories: [TrackerCategory] = []
                                                                
    var currentDate = Date()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "addTracker"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.tintColor = .black
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    private let titleHeader: UILabel =  {
        let label = UILabel()
        label.text = "Трекеры"
        label.textColor = .black
        label.font = UIFont(name: "SFProText-Bold", size: 34)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск"
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
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
        label.text = "Что будем отслеживать?"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let trackersCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.allowsMultipleSelection = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        showVisibleCategories()
        prepareView()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func checkVisibleCategoriesEmpty() {
        if !visibleCategories.isEmpty {
            placeholderView.isHidden = true
            placeholderTextView.isHidden = true
        } else {
            placeholderView.isHidden = false
            placeholderTextView.isHidden = false
        }
    }

    private func prepareView() {
        view.addSubview(addButton)
        view.addSubview(datePicker)
        view.addSubview(titleHeader)
        view.addSubview(searchBar)
        view.addSubview(trackersCollectionView)
        view.addSubview(placeholderView)
        view.addSubview(placeholderTextView)
        trackersCollectionView.dataSource = self
        trackersCollectionView.delegate = self
        trackersCollectionView.register(TrackerViewCell.self, forCellWithReuseIdentifier: "cell")
        trackersCollectionView.register(TrackerCategirySuplemetaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        checkVisibleCategoriesEmpty() 
        
        NSLayoutConstraint.activate([
            addButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            addButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 18),
            
            datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            datePicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),

            titleHeader.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 1),
            titleHeader.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),

            searchBar.topAnchor.constraint(equalTo: titleHeader.bottomAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            
            trackersCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 24),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            placeholderTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderTextView.topAnchor.constraint(equalTo: placeholderView.bottomAnchor, constant: 18)
            
        ])
    }
    
    private func showVisibleCategories() {
        let filterWeekday = Calendar.current.component(.weekday, from: currentDate)

        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                tracker.schedule?.contains { weekday in
                    weekday.numberValue == filterWeekday
                } == true
            }

            if trackers.isEmpty {
                return nil
            }

            return TrackerCategory(head: category.head,
                            trackers: trackers
            )
        }
        checkVisibleCategoriesEmpty()
        trackersCollectionView.reloadData()
    }
    @objc func addButtonTapped() {
        print("addButton tapped")
        let addTrackerViewController = AddTrackerViewController()
        addTrackerViewController.delegate = self
        present(addTrackerViewController, animated: true)
    }
    
    @objc func dateButtonTapped() {
        view.addSubview(datePicker)
    }
    
    @objc func datePickerValueChanged() {
        let selectedDate = datePicker.date
        self.datePicker.date = selectedDate
        currentDate = selectedDate
        print(currentDate)
        showVisibleCategories()
    }
}

extension TrackersViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        showVisibleCategories()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            showVisibleCategories()
        } else {
            visibleCategories = visibleCategories.filter { visibleCategory in
                let filteredCategories = visibleCategory.trackers.filter { tracker in
                    tracker.name.range(of: searchText, options: .caseInsensitive) != nil
                }
                return !filteredCategories.isEmpty
            }.map { category in
                TrackerCategory(head: category.head, trackers: category.trackers.filter {
                    $0.name.range(of: searchText, options: .caseInsensitive) != nil
                })
            }
        }
        trackersCollectionView.reloadData()
    }
}

extension TrackersViewController: AddTrackerViewControllerDelegate {
    func didSaveTracker(tracker: Tracker, category: String) {
        dismiss(animated: true)
        if categories.contains(where: {$0.head == category}) {
            guard let ind = categories.firstIndex(where: {$0.head == category}) else { return }
            let updatedTrackers = categories[ind].trackers + [tracker]
            categories[ind] = TrackerCategory(head: category, trackers: updatedTrackers)
        } else {
            categories.append(TrackerCategory(head: category, trackers: [tracker]))
        }
        print("categories count \(categories.count)")
        showVisibleCategories()
    }
}
extension TrackersViewController: TrackerViewCellDelegate {
    func plusButtonTapped(cell: TrackerViewCell) {
        guard let indexPath = trackersCollectionView.indexPath(for: cell) else { return }
        let id = visibleCategories[indexPath.section].trackers[indexPath.row].id
        var daysCount = completedTrackers.filter { $0.id == id }.count
        if !completedTrackers.contains(where: { $0.id == id && $0.date == currentDate}) {
            completedTrackers.insert(TrackerRecord(id: id, date: currentDate))
            daysCount += 1
            cell.configRecord(days: daysCount, isDone: true)
        } else {
            completedTrackers.remove(TrackerRecord(id: id, date: currentDate))
            daysCount -= 1
            cell.configRecord(days: daysCount, isDone: false)
        }
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("visible categories count \(visibleCategories[section].trackers.count)")
        return visibleCategories[section].trackers.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        print("count \(visibleCategories.count)")
        checkVisibleCategoriesEmpty()
        return visibleCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TrackerViewCell else { return UICollectionViewCell() }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        cell.configureCellData(tracker: tracker)
        cell.configRecord(days: completedTrackers.filter{ $0.id == tracker.id}.count, isDone: completedTrackers.contains{$0.id == tracker.id && $0.date == currentDate})
        cell.delegate = self
        cell.contentView.layer.cornerRadius = 16
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? TrackerCategirySuplemetaryView else { return UICollectionReusableView() }
        view.setCategory(visibleCategories[indexPath.section].head)
        return view
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("size \(CGSize(width: collectionView.bounds.width / 2 - 16 - 4.5, height: 148))")
        return CGSize(width: collectionView.bounds.width / 2 - 16 - 4.5, height: 148)
    }

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

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}

