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
        
        return trackerCoreData
    }
    
    func trackerFromCoreData(coreData: TrackerCoreData) throws -> Tracker {
        guard let stringId = coreData.trackerId,
            let id = UUID(uuidString: stringId),
              let name = coreData.name,
              let emoji = coreData.emoji,
              let stringColor = coreData.color,
              let scheduleString = coreData.schedule,
              let schedule = Weekday.stringToWeekdays(string: scheduleString) else {
            print("Could not get data from coreData")
            throw StoreError.decodingErrorInvalidTracker
        }
        print("tracker \(Tracker(id: id, name: name, color: uiColorMarshalling.color(from: stringColor), emoji: emoji, schedule: schedule, recordCount: 0))")
        return Tracker(id: id, name: name, color: uiColorMarshalling.color(from: stringColor), emoji: emoji, schedule: schedule, recordCount: 0)
    }
    
    func addTracker(tracker: Tracker, category: String) throws {
        let categoryStore = TrackerCategoryStore()
        let categoryCoreData = try categoryStore.getCategoryCoreData(with: category)
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.trackerId = tracker.id.uuidString
        trackerCoreData.category = categoryCoreData
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.name = tracker.name
        trackerCoreData.schedule = Weekday.weekdaysToString(weekdays: tracker.schedule)
        try context.save()
    }
    
    func getTracker(at indexPath: IndexPath) -> Tracker? {
        let trackerCoreData = fetchResultsController.object(at: indexPath)
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
    
    func filterTrackers(date: Date, searchString: String) throws {
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
        fetchResultsController.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        try fetchResultsController.performFetch()
        delegate?.didUpdateTrackers()
    }
    
    var numberOfTrackers: Int {
        fetchResultsController.fetchedObjects?.count ?? 0
    }
    
    var numberOfSections: Int {
        fetchResultsController.sections?.count ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        fetchResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func categoryNameInSection(_ section: Int) -> String? {
        guard let trackerCoreData = fetchResultsController.sections?[section].objects?.first as? TrackerCoreData else { return nil }
        return trackerCoreData.category?.head
    }
    
    func deleteTracker(tracker: Tracker) throws {
        let tracker = try? getTrackerCoreData(with: tracker.id)
        context.delete(tracker!)
        try context.save()
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
