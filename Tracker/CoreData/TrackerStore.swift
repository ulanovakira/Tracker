//
//  TrackerStore.swift
//  Tracker
//
//  Created by Кира on 26.11.2023.
//

import Foundation
import UIKit
import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func didUpdateTrackers()
}

final class TrackerStore: NSObject {
    private let uiColorMarshalling = UIColorMarshalling()
    private let context: NSManagedObjectContext
    weak var delegate: TrackerStoreDelegate?
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        try! self.init(context: context)
    }
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
    }
    
    var trackersCoreData: [TrackerCoreData] {
        fetchResultsController.fetchedObjects ?? []
    }
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    private lazy var fetchResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.category?.head , ascending: true)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category",
            cacheName: nil
        )
        controller.delegate = self
        try? controller.performFetch()
        return controller
    }()
    
    func trackerToCoreData(tracker: Tracker) -> TrackerCoreData {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.trackerId = tracker.id.uuidString
        trackerCoreData.name = tracker.name
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = Weekday.weekdaysToString(weekdays: tracker.schedule)
        trackerCoreData.recordCount = String(tracker.recordCount)
        
        return trackerCoreData
    }
    
    func trackerFromCoreData(coreData: TrackerCoreData) throws -> Tracker {
        guard let stringId = coreData.trackerId,
            let id = UUID(uuidString: stringId),
              let name = coreData.name,
              let emoji = coreData.emoji,
              let stringColor = coreData.color,
              let scheduleString = coreData.schedule,
              let recordCount = coreData.recordCount,
              let schedule = Weekday.stringToWeekdays(string: scheduleString) else {
            print("Could not get data from coreData")
            throw StoreError.decodingErrorInvalidTracker
        }
        print("tracker \(Tracker(id: id, name: name, color: uiColorMarshalling.color(from: stringColor), emoji: emoji, schedule: schedule, recordCount: Int(recordCount)!))")
        return Tracker(id: id, name: name, color: uiColorMarshalling.color(from: stringColor), emoji: emoji, schedule: schedule, recordCount: Int(recordCount)!)
    }
    
    func addTracker(tracker: Tracker, category: String) throws {
        let categoryStore = TrackerCategoryStore()
        let categoryCoreData = try categoryStore.getCategoryCoreData(with: category)
        let trackerCoreData = TrackerCoreData(context: context)
        categoryCoreData.trackers?.adding(tracker)
        trackerCoreData.trackerId = tracker.id.uuidString
        trackerCoreData.category = categoryCoreData
        trackerCoreData.defaultCategory = category
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.name = tracker.name
        trackerCoreData.recordCount = "0"
        trackerCoreData.schedule = Weekday.weekdaysToString(weekdays: tracker.schedule)
        trackerCoreData.pinned = false
        try context.save()
        delegate?.didUpdateTrackers()
    }
    
    func editTracker(tracker: Tracker, category: String) throws {
        let categoryStore = TrackerCategoryStore()
        let trackerCoreData = try? getTrackerCoreData(with: tracker.id)
        let categoryCoreData = try categoryStore.getCategoryCoreData(with: category)
        trackerCoreData?.category = categoryCoreData
        trackerCoreData?.defaultCategory = category
        trackerCoreData?.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData?.emoji = tracker.emoji
        trackerCoreData?.name = tracker.name
        trackerCoreData?.schedule = Weekday.weekdaysToString(weekdays: tracker.schedule)
        try context.save()
        delegate?.didUpdateTrackers()
    }
    
    func getTracker(at indexPath: IndexPath) -> Tracker? {
        print("indexPath \(indexPath)")
        
        let trackerCoreData = fetchResultsController.object(at: indexPath)
        print("indexPathend")
        do {
            let tracker = try trackerFromCoreData(coreData: trackerCoreData)
            return tracker
        } catch  {
            return nil
        }
    }
    
    func getTrackerCoreData(with id: UUID) throws -> TrackerCoreData? {
        fetchResultsController.fetchRequest.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerCoreData.trackerId), id.uuidString
        )
        try fetchResultsController.performFetch()
        return fetchResultsController.fetchedObjects?.first
    }
    
    func filterTrackers(date: Date, searchString: String, isDone: Bool?) throws {
        var predicates: [NSPredicate] = []
        if !searchString.isEmpty {
            predicates.append(NSPredicate(
                format: "%K CONTAINS[cd] %@",
                #keyPath(TrackerCoreData.name), searchString
            ))
        }
        let weekdayIndex = Calendar.current.component(.weekday, from: date)
        print("weekday index \(weekdayIndex)")
        predicates.append(NSPredicate(
            format: "%K CONTAINS[n] %@",
            #keyPath(TrackerCoreData.schedule), String(weekdayIndex)
        ))
        
        if let isDone {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-dd-MM"
            dateFormatter.timeZone = TimeZone(identifier: "Europe/Moscow")
            let dateString = dateFormatter.string(from: date)
            print("dateString \(dateString)")
            if isDone == true {
                predicates.append(NSPredicate(
                format: "%K == %@ AND %K != %@",
                #keyPath(TrackerCoreData.record.date),
                date.removeTimeStamp! as NSDate,
                #keyPath(TrackerCoreData.recordCount),
                "0")
                )
            } else {
                predicates.append(NSPredicate(
                format: "%K != %@",
                #keyPath(TrackerCoreData.record.date),
                date.removeTimeStamp! as NSDate
                ))
                print("lallal")
            }
        }
        print("aaaaaa \(predicates)")
        fetchResultsController.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        print("aaaaaa \(fetchResultsController.fetchedObjects)")
        try fetchResultsController.performFetch()
        delegate?.didUpdateTrackers()
    }
    
    func showTrackers(trackers: [Tracker]) throws {
        for tracker in trackers {
            let tr = trackerToCoreData(tracker: tracker)
            context.delete(tr)
        }
        try fetchResultsController.performFetch()
        delegate?.didUpdateTrackers()
    }
    
    func showEmptyTrackers() throws {
//        let request = fetchResultsController.fetchRequest
            
        
        try fetchResultsController.performFetch()
        delegate?.didUpdateTrackers()
    }
    
    func pinTracker(tracker: Tracker) {
        let categoryStore = TrackerCategoryStore()
        let trackerCoreData = try? getTrackerCoreData(with: tracker.id)
        trackerCoreData?.defaultCategory = trackerCoreData?.category?.head
        let categoryCoreData = try? categoryStore.getCategoryCoreData(with: NSLocalizedString("pinned", comment: ""))
        let categoryCoreDataOld = try? categoryStore.getCategoryCoreData(with: (trackerCoreData?.category?.head)!)
        trackerCoreData?.pinned = true
        trackerCoreData?.category? = categoryCoreData!
//        categoryCoreDataOld?.removeFromTrackers(trackerCoreData!)
        categoryCoreData?.trackers?.adding(tracker)
        try? context.save()
        print("pinned \(tracker)")
        delegate?.didUpdateTrackers()
    }
    func unPinTracker(tracker: Tracker) {
        let categoryStore = TrackerCategoryStore()
        let trackerCoreData = try? getTrackerCoreData(with: tracker.id)
        let categoryCoreDataOld = try? categoryStore.getCategoryCoreData(with: (trackerCoreData?.defaultCategory)!)
        trackerCoreData?.pinned = false
        trackerCoreData?.category = categoryCoreDataOld
        categoryCoreDataOld?.trackers?.adding(tracker)
        try? context.save()
        print(tracker)
        delegate?.didUpdateTrackers()
    }
    
    func isTrackerPinned(tracker: Tracker) throws -> Bool {
        let trackerCoreData = try? getTrackerCoreData(with: tracker.id)
        return trackerCoreData!.pinned
    }
    
    var numberOfTrackers: Int {
        fetchResultsController.fetchedObjects?.count ?? 0
    }
    
    var numberOfSections: Int {
        fetchResultsController.sections?.count ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        print("name \(fetchResultsController.sections?[section].name)")
        return fetchResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func categoryNameInSection(_ section: Int) -> String? {
        print("section \(section)")
        guard let trackerCoreData = fetchResultsController.sections?[section].objects?.first as? TrackerCoreData else { return nil }
        print("trackerStore.numberOfSectionsName \(trackerCoreData.category?.head)")
        print("trackerStore.numberOfSectionsName \(trackerCoreData.category?.trackers?.count)")
        return trackerCoreData.category?.head
    }
    
    func deleteTracker(tracker: Tracker) throws {
        let tracker = try? getTrackerCoreData(with: tracker.id)
        context.delete(tracker!)
        try context.save()
        delegate?.didUpdateTrackers()
    }
    
    func addRecord(tracker: Tracker) throws {
        let tracker = try? getTrackerCoreData(with: tracker.id)
        let recordCountInt = Int((tracker?.recordCount)!)! + 1
        tracker?.recordCount = String(recordCountInt)
        try context.save()
//        delegate?.didUpdateTrackers()
    }
    
    func deleteRecord(tracker: Tracker) throws {
        let tracker = try? getTrackerCoreData(with: tracker.id)
        let recordCountInt = Int((tracker?.recordCount)!)! - 1
        tracker?.recordCount = String(recordCountInt)
        try context.save()
//        delegate?.didUpdateTrackers()
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateTrackers()
    }
}

enum StoreError: Error {
    case decodingErrorInvalidTracker
}
