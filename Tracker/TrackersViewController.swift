//
//  ViewController.swift
//  Tracker
//
//  Created by Кира on 12.10.2023.
//

import UIKit
import Foundation

class TrackersViewController: UIViewController, UINavigationControllerDelegate, NewTrackerViewControllerDelegate {
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    var visibleCategories: [TrackerCategory] = []
    var currentFilter: String = ""
                                                                
    var currentDate = Date()
    private var trackerStore = TrackerStore()
    private var trackerCategoryStore = TrackerCategoryStore()
    private var trackerRecordStore = TrackerRecordStore()
    let analyticService = AnalyticService()
    let trackerViewCell = TrackerViewCell()
    private let colors = Colors()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "addTracker"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var filtersButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("filters", comment: ""), for: .normal)
        button.backgroundColor = UIColor(named: "YPBlue")
        button.tintColor = .black
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(filtersButtonTapped), for: .touchUpInside)
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
        label.text = NSLocalizedString("trackers", comment: "")
        label.textColor = .black
        label.font = UIFont(name: "SFProText-Bold", size: 34)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = NSLocalizedString("search", comment: "")
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
        label.text = NSLocalizedString("emptyState.title", comment: "")
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
        view.backgroundColor = colors.backgroundColor
        trackerStore.delegate = self
        trackerRecordStore.delegate = self
        trackerViewCell.delegate = self
        showVisibleCategories()
        prepareView()
        completedTrackers = try! trackerRecordStore.loadCompletedTrackers(date: currentDate)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        analyticService.reportEvent(event: .open, screen: .main)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        analyticService.reportEvent(event: .close, screen: .main)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func checkVisibleCategoriesEmpty() {
        if trackerStore.numberOfTrackers != 0 {
            placeholderView.isHidden = true
            placeholderTextView.isHidden = true
            filtersButton.isHidden = false
        } else {
            placeholderView.isHidden = false
            placeholderTextView.isHidden = false
            filtersButton.isHidden = true
        }
    }

    private func prepareView() {
        view.addSubview(addButton)
        addButton.tintColor = colors.trackersLabelColor
        view.addSubview(datePicker)
        datePicker.backgroundColor = colors.datePickerColor
        view.addSubview(titleHeader)
        view.addSubview(searchBar)
        view.addSubview(trackersCollectionView)
        view.addSubview(placeholderView)
        view.addSubview(placeholderTextView)
        view.addSubview(filtersButton)
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
            placeholderTextView.topAnchor.constraint(equalTo: placeholderView.bottomAnchor, constant: 18),
            
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filtersButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            filtersButton.heightAnchor.constraint(equalToConstant: 50),
            filtersButton.widthAnchor.constraint(equalToConstant: 114)
            
        ])
    }
    
    private func showVisibleCategories() {
        checkVisibleCategoriesEmpty()
        completedTrackers = try! trackerRecordStore.loadCompletedTrackers(date: currentDate)
        try? trackerStore.filterTrackers(date: currentDate, searchString: "", isDone: nil)
        trackersCollectionView.reloadData()
    }
    @objc func addButtonTapped() {
        print("addButton tapped")
        let addTrackerViewController = AddTrackerViewController()
        addTrackerViewController.delegate = self
        present(addTrackerViewController, animated: true)
        analyticService.reportEvent(event: .click, screen: .main, item: .add_track)
    }
    
    @objc func filtersButtonTapped() {
        let filtersViewController = FiltersViewController()
        filtersViewController.delegate = self
        present(filtersViewController, animated: true)
        filtersViewController.selectedFilter = currentFilter
        analyticService.reportEvent(event: .click, screen: .main, item: .filter)
    }
    
    @objc func dateButtonTapped() {
        view.addSubview(datePicker)
    }
    
    @objc func datePickerValueChanged() {
        let selectedDate = datePicker.date.removeTimeStamp!
        self.datePicker.date = selectedDate
        currentDate = selectedDate
        print(currentDate)
        try? trackerStore.filterTrackers(date: selectedDate, searchString: "", isDone: nil)
        showVisibleCategories()
    }
    
    func removeTracker(tracker: Tracker) {
        try? trackerStore.deleteTracker(tracker: tracker)
        
        if tracker.recordCount != 0 {
            let trackerRecord = try? trackerRecordStore.trackerRecord(tracker: tracker)
            try? trackerRecordStore.deleteRecord(record: trackerRecord!)
        }
        showVisibleCategories()
        trackersCollectionView.reloadData()
        completedTrackers = try! trackerRecordStore.loadCompletedTrackers(date: currentDate)
    }
}

extension TrackersViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        showVisibleCategories()
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.setShowsCancelButton(false, animated: true)
        showVisibleCategories()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.setShowsCancelButton(false, animated: true)
        showVisibleCategories()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.setShowsCancelButton(true, animated: true)
        if searchText.isEmpty {
            showVisibleCategories()
        } else {
            try? trackerStore.filterTrackers(date: currentDate, searchString: searchText, isDone: nil)
        }
        trackersCollectionView.reloadData()
    }
}

extension TrackersViewController: AddTrackerViewControllerDelegate {
    func didSaveTracker(tracker: Tracker, category: String, actionType: String) {
        dismiss(animated: true)
        if actionType == "edit" {
            try? trackerStore.editTracker(tracker: tracker, category: category)
        } else {
            try? trackerStore.addTracker(tracker: tracker, category: category)
        }
        showVisibleCategories()
        trackersCollectionView.reloadData()
    }
}
extension TrackersViewController: TrackerViewCellDelegate {
    func plusButtonTapped(cell: TrackerViewCell, tracker: Tracker) {
        let trackerRecord = TrackerRecord(id: tracker.id, date: currentDate.removeTimeStamp!)
        if datePicker.date.timeIntervalSinceNow.sign == .minus {
            showVisibleCategories()
            print("completedTrackers \(completedTrackers)")
            if !completedTrackers.contains(where: { $0.id == tracker.id && $0.date.removeTimeStamp == currentDate.removeTimeStamp!}) {
                try? trackerStore.addRecord(tracker: tracker, date: currentDate.removeTimeStamp!)
                cell.addDays()
                cell.configRecord(isDone: true)
                
            } else {
                try? trackerRecordStore.deleteRecord(record: trackerRecord)
                try? trackerStore.deleteRecord(tracker: tracker)
                cell.removeDays()
                cell.configRecord(isDone: false)
                
            }
            print("completed trackers \(completedTrackers)")
        }
        showVisibleCategories()
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("trackerStore.numberOfSectionsItems \(trackerStore.numberOfItemsInSection(section))")
        print("section \(section)")
        return trackerStore.numberOfItemsInSection(section)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        checkVisibleCategoriesEmpty()
        print("trackerStore.numberOfSections \(trackerStore.numberOfSections)")
        return trackerStore.numberOfSections
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TrackerViewCell  else { return UICollectionViewCell() }
        if  let tracker = trackerStore.getTracker(at: indexPath)  {
            print("indexPath section \(indexPath)")
            let done = try? trackerRecordStore.getRecordDone(tracker: tracker, date: currentDate.removeTimeStamp!)
            let doneCount = try? trackerRecordStore.getDaysCountDone(tracker: tracker, date: currentDate.removeTimeStamp!)
            let isPinned = trackerStore.isTrackerPinned(tracker: tracker)
            print("done \(String(describing: done))")
            cell.configureCellData(tracker: tracker, days: doneCount!, isPinned: isPinned )
            cell.configRecord(isDone: done!)
            cell.delegate = self
            cell.contentView.layer.cornerRadius = 16
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? TrackerCategirySuplemetaryView,
              let category = trackerStore.categoryNameInSection(indexPath.section) else { return UICollectionReusableView() }
        print("indexPathsection \(indexPath.section)")
        print("sectioncategory \(category)")
        view.setCategory(category)
        return view
    }
}

extension TrackersViewController: UICollectionViewDelegate {
    private func pinTracker(tracker: Tracker, isPinned: Bool, indexPath: IndexPath) {
        guard let trackerCoreData = try? trackerStore.getTrackerCoreData(with: tracker.id) else { return }
        print("category \(String(describing: trackerCoreData.category?.head))")
        if isPinned == false {
            trackerStore.pinTracker(tracker: tracker)
            print("tracker pinned")
        } else {
            trackerStore.unPinTracker(tracker: tracker)
        }
        showVisibleCategories()
        trackersCollectionView.reloadData()
    }
    
    private func editTracker(tracker: Tracker) {
        analyticService.reportEvent(event: .click, screen: .main, item: .edit)
        let editTrackerViewController = NewTrackerViewController()
        editTrackerViewController.delegate = self
        editTrackerViewController.actionType = "edit"
        
        let doneCount = try? trackerRecordStore.getDaysCountDone(tracker: tracker, date: currentDate.removeTimeStamp!)
        guard let trackerCoreData = try? trackerStore.getTrackerCoreData(with: tracker.id) else { return }
        guard let category = try? trackerCategoryStore.getTrackerCategory(tracker: trackerCoreData) else { return }
        if tracker.schedule == Weekday.allCases {
            editTrackerViewController.trackerType = "event"
        } else {
            editTrackerViewController.trackerType = "habbit"
        }
        editTrackerViewController.editTracker(tracker: tracker, category: category, recordCount: doneCount!)
        present(editTrackerViewController, animated: true)
    }
    
    private func deleteTracker(tracker: Tracker) {
        let alert = UIAlertController(
            title: nil,
            message: "Уверены, что хотите удалить трекер?",
            preferredStyle: .actionSheet
        )
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            removeTracker(tracker: tracker)
        }
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        present(alert, animated: true)
        analyticService.reportEvent(event: .click, screen: .main, item: .delete)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        print("point \(point)")
        guard indexPaths.count > 0 else {
            return nil
        }
        print("indexPaths \(indexPaths)")
        let indexPath = indexPaths[0]
        
        guard let tracker = trackerStore.getTracker(at: indexPath) else { return nil }
        print("lalalal \(tracker)")
        var title: String = ""
        let isPinned = try? trackerStore.isTrackerPinned(tracker: tracker)
        if isPinned == true {
            title = NSLocalizedString("unpin", comment: "")
        } else {
            title = NSLocalizedString("pin", comment: "")
        }
        
        return UIContextMenuConfiguration(actionProvider: { actions in
            return UIMenu(children: [
                UIAction(title: title) { [weak self ] _ in
                    guard let self else { return }
                    self.pinTracker(tracker: tracker, isPinned: isPinned!, indexPath: indexPath)
                },
                UIAction(title: NSLocalizedString("edit", comment: "")) { [weak self] _ in
                    guard let self else { return }
                    self.editTracker(tracker: tracker)
                },
                UIAction(title: NSLocalizedString("delete", comment: ""), attributes: .destructive) { [weak self] _ in
                    guard let self else { return }
                    self.deleteTracker(tracker: tracker)
                }
            ])
        })
    }
    func collectionView(_ collectionView: UICollectionView, contextMenuConfiguration configuration: UIContextMenuConfiguration, highlightPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return nil }
        let targetedPreview = UITargetedPreview(view: cell)
        targetedPreview.parameters.visiblePath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: cell.frame.width, height: 90))
        targetedPreview.parameters.backgroundColor = .clear
        return targetedPreview
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

extension Date {
    public var removeTimeStamp : Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let stringDate = formatter.string(from: self)
        let date = formatter.date(from: stringDate)!
        return date
   }
}
extension TrackersViewController: TrackerStoreDelegate {
    func didUpdateTrackers() {
        checkVisibleCategoriesEmpty()
        completedTrackers  = try! trackerRecordStore.loadCompletedTrackers(date: currentDate)
        trackersCollectionView.reloadData()
    }
}

extension TrackersViewController: TrackerRecordStoreDelegate {
    func didUpdateRecord(_ records: [TrackerRecord]) {
        completedTrackers = records
        print("completedTrackers2 \(completedTrackers)")
    }
}

extension TrackersViewController: FiltersViewControllerDelegate {
    func didSelectFilter(filter: String, filterFull: String) {
        currentFilter = filterFull
        if filter == "all" {
            datePickerValueChanged()
            trackersCollectionView.reloadData()
            showVisibleCategories()
        } else if filter == "today" {
            currentDate = Date()
            datePicker.date = currentDate
            datePickerValueChanged()
            trackersCollectionView.reloadData()
            showVisibleCategories()
        } else {
            if filter == "done" {
                try? trackerStore.filterTrackers(date: currentDate, searchString: "", isDone: true)
                trackersCollectionView.reloadData()
                checkVisibleCategoriesEmpty()
            } else if filter == "notdone" {
                try? trackerStore.filterTrackers(date: currentDate, searchString: "", isDone: false)
                trackersCollectionView.reloadData()
                checkVisibleCategoriesEmpty()
            }
        }
    }
}

