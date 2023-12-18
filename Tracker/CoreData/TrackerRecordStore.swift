//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Кира on 26.11.2023.
//

import Foundation
import UIKit
import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func didUpdateRecord(_ records: [TrackerRecord])
}

final class TrackerRecordStore: NSObject, NSFetchedResultsControllerDelegate {
    
    private let context: NSManagedObjectContext
    private let trackerStore = TrackerStore()
    var completedTrackers: [TrackerRecord] {
        try? fetchResultsController.performFetch()
        guard let fetchObjects = fetchResultsController.fetchedObjects,
              let trackersRecords = try? fetchObjects.map ({try makeRecord(from: $0)}) else { return [] }
        return trackersRecords
        
    }
    weak var delegate: TrackerRecordStoreDelegate?
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        try! self.init(context: context)
    }
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
    }
    private lazy var fetchResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerRecordCoreData.recordId , ascending: true)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        try? controller.performFetch()
        return controller
    }()
    
    func addRecord(record: TrackerRecord) throws {
        let trackerCoreData = try trackerStore.getTrackerCoreData(with: record.id)
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        trackerRecordCoreData.recordId = record.id.uuidString
        trackerRecordCoreData.date = record.date.removeTimeStamp!
        trackerRecordCoreData.trackers = trackerCoreData
        trackerCoreData?.addToRecord(trackerRecordCoreData)
        try context.save()
    }
    
    func deleteRecord(record: TrackerRecord) throws {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerRecordCoreData.recordId), record.id.uuidString)
        let records = try context.fetch(request)
        guard let recordToRemove = records.first else { return }
        context.delete(recordToRemove)
//        completedTrackers.remove(record)
        try context.save()
        
    }
    
    func getRecordDone(tracker: Tracker, date: Date) throws -> Bool {
        let request = fetchResultsController.fetchRequest
        request.predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                        #keyPath(TrackerRecordCoreData.recordId),
                                        tracker.id.uuidString,
                                        #keyPath(TrackerRecordCoreData.date),
                                        date as NSDate)
        do {
            let trackerCoreData = try context.fetch(request)
            print("trackerCoreData \(trackerCoreData)")
            if !trackerCoreData.isEmpty {
                if !trackerCoreData[0].recordId!.isEmpty {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        } catch {
           throw StoreError.decodingErrorInvalidTracker
       }
    }
    
    func trackerRecord(tracker: Tracker) throws -> TrackerRecord {
        let request = fetchResultsController.fetchRequest
        request.predicate = NSPredicate(format: "%K == %@",
                                        #keyPath(TrackerRecordCoreData.recordId),
                                        tracker.id.uuidString)
        do {
            let trackerCoreData = try context.fetch(request)
            print("tracker \(tracker)")
            let tracker = try makeRecord(from: trackerCoreData[0])
            return tracker
        } catch {
           throw StoreError.decodingErrorInvalidTracker
       }
    }
    
    
    func makeRecord(from coreData: TrackerRecordCoreData) throws -> TrackerRecord {
            guard
                let stringId = coreData.recordId,
                let id = UUID(uuidString: stringId),
                let date = coreData.date
            else { throw StoreError.decodingErrorInvalidTracker }
            return TrackerRecord(
                id: id,
                date: date)
        }
    
    func loadCompletedTrackers(date: Date) throws -> [TrackerRecord] {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        let trackersCoreData = try context.fetch(request)
        guard let trackersRecords = try? trackersCoreData.map ({try makeRecord(from: $0)}) else { return [] }
        return trackersRecords
    }
    
    func getDaysCountDone(tracker: Tracker, date: Date) throws -> Int {
        let request = fetchResultsController.fetchRequest
        request.predicate = NSPredicate(format: "%K == %@",
                                        #keyPath(TrackerRecordCoreData.recordId),
                                        tracker.id.uuidString)
        do {
            let tracker = try context.fetch(request)
            print("tracker \(tracker)")
            return tracker.count
        } catch {
           throw StoreError.decodingErrorInvalidTracker
       }
    }
    
    func getCompletedTrackersCount() throws -> Int {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        let recordsCoreData = try context.fetch(request)
        var completedTrackersID: [String] = []
        for r in recordsCoreData {
            completedTrackersID.append(r.recordId!)
        }
        return completedTrackersID.count
    }
}
