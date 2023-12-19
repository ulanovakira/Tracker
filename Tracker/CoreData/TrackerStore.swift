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
            NSSortDescriptor(keyPath: \TrackerCoreData.pinned, ascending: false),
            NSSortDescriptor(keyPath: \TrackerCoreData.category?.head , ascending: false)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: #keyPath(TrackerCoreData.category.head),
            cacheName: nil
        )
        try? controller.performFetch()
        controller.delegate = self
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
        trackerCoreData.pinned = tracker.isPinned
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
        
        let isPinned = coreData.pinned
        print("tracker \(Tracker(id: id, name: name, color: uiColorMarshalling.color(from: stringColor), emoji: emoji, schedule: schedule, recordCount: Int(recordCount)!, isPinned: isPinned))")
        return Tracker(id: id, name: name, color: uiColorMarshalling.color(from: stringColor), emoji: emoji, schedule: schedule, recordCount: Int(recordCount)!, isPinned: isPinned)
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
        print("trackerCoreData \(trackersCoreData)")
        print("fetchResult \(fetchResultsController.fetchedObjects)")
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
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        request.predicate = NSPredicate(
                        format: "%K == %@",
                        #keyPath(TrackerCoreData.trackerId), id.uuidString
                    )
        guard let coreData = try context.fetch(request).first else { return nil }
        return coreData
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
            if isDone == true {
                predicates.append(NSPredicate(
                format: "%K.%K CONTAINS %@ AND %K > %@",
                #keyPath(TrackerCoreData.record),
                #keyPath(TrackerRecordCoreData.date),
                date.removeTimeStamp! as NSDate,
                #keyPath(TrackerCoreData.recordCount),
                "0")
                )
            } else {
                predicates.append(NSPredicate(
                format: "SUBQUERY(%K.%K, $a, $a CONTAINS %@).@count == 0 OR %K == %@",
                #keyPath(TrackerCoreData.record),
                #keyPath(TrackerRecordCoreData.date),
                date.removeTimeStamp! as NSDate,
                #keyPath(TrackerCoreData.recordCount),
                "0"
                ))
            }
        }
        fetchResultsController.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
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
        trackerCoreData?.pinned = true
        categoryCoreData?.addToTrackers(trackerCoreData!)
        try? context.save()
        print("pinned \(tracker)")
        delegate?.didUpdateTrackers()
    }
    func unPinTracker(tracker: Tracker) {
        let categoryStore = TrackerCategoryStore()
        let trackerCoreData = try? getTrackerCoreData(with: tracker.id)
        let categoryCoreDataOld = try? categoryStore.getCategoryCoreData(with: (trackerCoreData?.defaultCategory)!)
        trackerCoreData?.pinned = false
        categoryCoreDataOld?.addToTrackers(trackerCoreData!)
        try? context.save()
        print(tracker)
        delegate?.didUpdateTrackers()
    }
    
    func isTrackerPinned(tracker: Tracker) -> Bool {
        let trackerCoreData = try? getTrackerCoreData(with: tracker.id)
        let isPinned = trackerCoreData?.pinned ?? false
        return isPinned
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
        guard let trackerCoreData = fetchResultsController.sections?[section].objects?.last as? TrackerCoreData else { return nil }
        return trackerCoreData.category?.head
    }
    
    func deleteTracker(tracker: Tracker) throws {
        let tracker = try? getTrackerCoreData(with: tracker.id)
        context.delete(tracker!)
        try context.save()
        delegate?.didUpdateTrackers()
    }
    
    func addRecord(tracker: Tracker, date: Date) throws {
        let trackerCoreData = try? getTrackerCoreData(with: tracker.id)
        let recordCountInt = Int((trackerCoreData?.recordCount)!)! + 1
        trackerCoreData?.recordCount = String(recordCountInt)
        let trackerRecording = TrackerRecordCoreData(context: context)
        trackerRecording.recordId = tracker.id.uuidString
        trackerRecording.date = date
        trackerRecording.trackers = trackerCoreData
        trackerCoreData?.addToRecord(trackerRecording)
        try context.save()
    }
    
    func deleteRecord(tracker: Tracker) throws {
        let tracker = try? getTrackerCoreData(with: tracker.id)
        let recordCountInt = Int((tracker?.recordCount)!)! - 1
        tracker?.recordCount = String(recordCountInt)
        try context.save()
        delegate?.didUpdateTrackers()
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
