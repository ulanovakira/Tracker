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
    func didUpdateCategories()
}
final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    weak var delegate: TrackerCategoryStoreDelegate?
    
    var categoriesCoreData: [TrackerCategoryCoreData] {
        fetchResultsController.fetchedObjects ?? []
    }
    var notEmptyCategories: [TrackerCategoryCoreData] = []
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        try! self.init(context: context)
    }
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        try addCategory(category: NSLocalizedString("pinned", comment: ""))
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
    func getNumberOfCategoriesWithTrackers() -> Int {
        var count: Int = 0
        if fetchResultsController.fetchedObjects?.count != 0 {
            for i in 0..<(fetchResultsController.fetchedObjects?.count)! {
                if fetchResultsController.fetchedObjects![i].trackers?.count != 0 {
                    count += 1
                    if !notEmptyCategories.contains(fetchResultsController.fetchedObjects![i]) {
                        notEmptyCategories.append(fetchResultsController.fetchedObjects![i])
                    }
                }
            }
        }
        return count
    }
    func numberOfItemsInSection(_ section: Int) -> Int {
        notEmptyCategories[section].trackers?.count ?? 0
    }
    
    func isSectionEmpty(section: Int) -> Bool {
        if categoriesCoreData[section].trackers?.count == 0 {
            return true
        } else {
            return false
        }
    }
    
    func getCategoryCoreData(with head: String) throws -> TrackerCategoryCoreData {
        let request = fetchResultsController.fetchRequest
        request.predicate = NSPredicate(format: "%K == %@",
                                        #keyPath(TrackerCategoryCoreData.head),
                                        head)
        do {
            let category = try context.fetch(request)
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
    
    func getCategoryNameBySection(section: Int) -> String {
        return notEmptyCategories[section].head ?? ""
    }
    
    func editCategory(category: String, newCategory: String) throws {
        let old = try? getCategoryCoreData(with: category)
        context.delete(old!)
        try context.save()
        try? addCategory(category: newCategory)
    }
    func addCategory(category: String) throws {
        if category != "" {
            let request = fetchResultsController.fetchRequest
            request.predicate = NSPredicate(format: "%K == %@",
                                            #keyPath(TrackerCategoryCoreData.head),
                                            category)
            let categoryCoreData = try context.fetch(request)
            if categoryCoreData.isEmpty {
                let categoryCoreData = TrackerCategoryCoreData(context: context)
                categoryCoreData.head = category
                try? context.save()
            }
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
        delegate?.didUpdateCategories()
    }
}
