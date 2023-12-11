//
//  CategoriesViewModel.swift
//  Tracker
//
//  Created by Кира on 02.12.2023.
//

import Foundation

protocol CategoriesViewModelDelegate: AnyObject {
    func didSelectCategory(category: String)
    func didUpdateCategories()
}

final class CategoriesViewModel {
    weak var delegate: CategoriesViewModelDelegate?
    var trackerCategoryStore = TrackerCategoryStore()
    
    private(set) var categories: [String] = [] {
        didSet {
            delegate?.didUpdateCategories()
        }
    }
    
    private(set) var selectedCategory: String? {
        didSet {
            guard let selectedCategory else { return }
            delegate?.didSelectCategory(category: selectedCategory)
        }
    }
    
    private func getCategoriesFromCoreData() -> [String] {
        let categories = try? trackerCategoryStore.categoriesCoreData.map {
            try trackerCategoryStore.getCategoryNameFromCoreData(coreData: $0)
        }
        print("categpries \(String(describing: categories))")
        return categories ?? []
    }
    
    private func updateCategories() {
        categories = getCategoriesFromCoreData()
    }
    func editCategory(head: String, newHead: String) {
        try? trackerCategoryStore.editCategory(category: head, newCategory: newHead)
        updateCategories()
    }
    func addCategory(head: String) {
        try? trackerCategoryStore.addCategory(category: head)
        updateCategories()
    }
    
    func selectCategory(index: IndexPath) {
        selectedCategory = categories[index.row]
        print("selectedCategory \(String(describing: selectedCategory))")
    }
    
    func deleteCategory(head: String) {
        try? trackerCategoryStore.deleteCategory(category: head)
        updateCategories()
    }
}

extension CategoriesViewModel: NewCategoryViewControllerDelegate {
    func didAddCategory(name: String) {
        addCategory(head: name)
    }
}

extension CategoriesViewModel: TrackerCategoryStoreDelegate {
    func didUpdateCategories() {
        categories = getCategoriesFromCoreData()
    }
}
