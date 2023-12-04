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
    func didUpdateRecord(_ records: Set<TrackerRecord>)
}

final class TrackerRecordStore: NSObject, NSFetchedResultsControllerDelegate {
    
    private let context: NSManagedObjectContext
    private let trackerStore = TrackerStore()
    var completedTrackers: Set<TrackerRecord> = []
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
        trackerRecordCoreData.date = record.date
        trackerRecordCoreData.trackers = trackerCoreData
        completedTrackers.insert(record)
        try context.save()
        print("completedTrackers \(completedTrackers)")
        print("delegate \(String(describing: delegate))")
        delegate?.didUpdateRecord(completedTrackers)
        
    }
    
    func deleteRecord(record: TrackerRecord) throws {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerRecordCoreData.recordId), record.id.uuidString)
        let records = try context.fetch(request)
        guard let recordToRemove = records.first else { return }
        context.delete(recordToRemove)
        completedTrackers.remove(record)
        try context.save()
        print("completedTrackers \(completedTrackers)")
        delegate?.didUpdateRecord(completedTrackers)
        
    }
    
    func getRecordDone(tracker: Tracker, date: Date) throws -> Bool {
        let request = fetchResultsController.fetchRequest
        request.predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                        #keyPath(TrackerRecordCoreData.recordId),
                                        tracker.id.uuidString,
                                        #keyPath(TrackerRecordCoreData.date),
                                        date as NSDate)
        do {
            let tracker = try context.fetch(request)
            print("tracker \(tracker)")
            if !tracker.isEmpty {
                return true
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
    
    private func makeRecord(from coreData: TrackerRecordCoreData) throws -> TrackerRecord {
            guard
                let stringId = coreData.recordId,
                let id = UUID(uuidString: stringId),
                let date = coreData.date
            else { throw StoreError.decodingErrorInvalidTracker }
            return TrackerRecord(
                id: id,
                date: date)
        }
    
    func loadCompletedTrackers(date: Date) throws {
        let request = fetchResultsController.fetchRequest
        request.predicate = NSPredicate(format: "%K == %@",
                                        #keyPath(TrackerRecordCoreData.date),
                                        date.removeTimeStamp! as NSDate)
        do {
            let recordsCoreData = try context.fetch(request)
            var records: Set<TrackerRecord> = []
            for r in recordsCoreData {
                let recordFromCoreData = try makeRecord(from: r)
                records.insert(recordFromCoreData)
            }
            completedTrackers = records
            print("loadcompletedTrackers \(completedTrackers)")
            delegate?.didUpdateRecord(completedTrackers)
        } catch {
           throw StoreError.decodingErrorInvalidTracker
       }
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
        print("recordsCoreData \(recordsCoreData)")
        var completedTrackersID: Set<String> = []
        for r in recordsCoreData {
            print("recordID \(String(describing: r.recordId))")
            completedTrackersID.insert(r.recordId!)
        }
        print("completedTrackersID \(completedTrackersID)")
        return completedTrackersID.count
    }
}
