//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Кира on 26.11.2023.
//

import Foundation
import UIKit
import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdateTrackers()
}
final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    weak var delegate: TrackerCategoryStoreDelegate?
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        try! self.init(context: context)
    }
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        try configCategories(with: context)
    }
    private lazy var fetchResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCategoryCoreData.head , ascending: true)
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
    
    func getCategoryCoreData(with head: String) throws -> TrackerCategoryCoreData {
        let request = fetchResultsController.fetchRequest
        request.predicate = NSPredicate(format: "%K == %@",
                                        #keyPath(TrackerCategoryCoreData.head),
                                        head)
        do {
            let category = try context.fetch(request)
            print("category \(category)")
            return category[0]
        } catch {
           throw StoreError.decodingErrorInvalidTracker
       }
    }
    
    func configCategories(with context: NSManagedObjectContext) throws{
//        let request = fetchResultsController.fetchRequest
//        let fetch = try! context.fetch(request)
        let _ = [TrackerCategory(head: "Категория 1", trackers: [Tracker(id: UUID(), name: "Первое дело", color: UIColor(named: "Selection1")!, emoji: "❤️", schedule: [Weekday.Wednesday], recordCount: 0)]),
                 TrackerCategory(head: "Категория 2", trackers: [Tracker(id: UUID(), name: "Второе дело", color: UIColor(named: "Selection2")!, emoji: "🙈", schedule: [Weekday.Thursday], recordCount: 0)]),
                 TrackerCategory(head: "Категория 3", trackers: [Tracker(id: UUID(), name: "Третье дело", color: UIColor(named: "Selection17")!, emoji: "🤪", schedule: [Weekday.Wednesday], recordCount: 0)]),
                 TrackerCategory(head: "Категория 4", trackers: [Tracker(id: UUID(), name: "Четвертое дело", color: UIColor(named: "Selection6")!, emoji: "🥶", schedule: [Weekday.Saturday], recordCount: 0)])
        ].map { category in
            let categoryCoreData = TrackerCategoryCoreData(context: context)
            categoryCoreData.head = category.head
            return categoryCoreData
        }
        try context.save()
    }
}
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateTrackers()
    }
}
