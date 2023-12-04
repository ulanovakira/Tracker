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
    
    var categoriesCoreData: [TrackerCategoryCoreData] {
        fetchResultsController.fetchedObjects ?? []
    }
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        try! self.init(context: context)
    }
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
//        try configCategories(with: context)
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
    
    var numberOfCategories: Int {
        fetchResultsController.fetchedObjects?.count ?? 0
    }
    
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
    
    func getTrackerCategory(tracker: TrackerCoreData) throws -> String {
        guard let category = tracker.category?.head else { return "" }
        return category
    }
    
    func getCategoryNameFromCoreData(coreData: TrackerCategoryCoreData) throws -> String {
        guard let head = coreData.head  else {
            throw StoreError.decodingErrorInvalidTracker
        }
        
        return head
    }
    func editCategory(category: String, newCategory: String) throws {
        let old = try? getCategoryCoreData(with: category)
        context.delete(old!)
        try context.save()
        try? addCategory(category: newCategory)
    }
    func addCategory(category: String) throws {
        if category != "" {
            let categoryCoreData = TrackerCategoryCoreData(context: context)
            print("here ")
            categoryCoreData.head = category
            try? context.save()
            print(categoryCoreData)
        }
    }
    
    func deleteCategory(category: String) throws {
        let category = try? getCategoryCoreData(with: category)
        context.delete(category!)
        try context.save()
    }
}
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateTrackers()
    }
}
