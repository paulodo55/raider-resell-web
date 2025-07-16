import Foundation
import FirebaseFirestore
import FirebaseStorage
import UIKit
import Combine

class ItemStore: ObservableObject {
    @Published var items: [Item] = []
    @Published var featuredItems: [Item] = []
    @Published var userItems: [Item] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchResults: [Item] = []
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private var itemsListener: ListenerRegistration?
    
    init() {
        fetchItems()
        setupItemsListener()
    }
    
    deinit {
        itemsListener?.remove()
    }
    
    // MARK: - Fetch Items
    func fetchItems() {
        isLoading = true
        
        db.collection(AppConstants.FirebaseCollections.items)
            .whereField("status", isEqualTo: ItemStatus.active.rawValue)
            .order(by: "createdAt", descending: true)
            .getDocuments { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let error = error {
                        self?.errorMessage = AppConstants.ErrorMessages.networkError
                        return
                    }
                    
                    self?.items = snapshot?.documents.compactMap { document in
                        try? document.data(as: Item.self)
                    } ?? []
                    
                    self?.updateFeaturedItems()
                }
            }
    }
    
    func fetchUserItems(userID: String) {
        db.collection(AppConstants.FirebaseCollections.items)
            .whereField("sellerID", isEqualTo: userID)
            .order(by: "createdAt", descending: true)
            .getDocuments { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.errorMessage = AppConstants.ErrorMessages.networkError
                        return
                    }
                    
                    self?.userItems = snapshot?.documents.compactMap { document in
                        try? document.data(as: Item.self)
                    } ?? []
                }
            }
    }
    
    // MARK: - Real-time Listener
    private func setupItemsListener() {
        itemsListener = db.collection(AppConstants.FirebaseCollections.items)
            .whereField("status", isEqualTo: ItemStatus.active.rawValue)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.errorMessage = AppConstants.ErrorMessages.networkError
                        return
                    }
                    
                    self?.items = snapshot?.documents.compactMap { document in
                        try? document.data(as: Item.self)
                    } ?? []
                    
                    self?.updateFeaturedItems()
                }
            }
    }
    
    // MARK: - Create Item
    func createItem(_ item: Item, images: [UIImage]) async -> Bool {
        var newItem = item
        
        do {
            // Upload images first
            let imageURLs = try await uploadImages(images)
            newItem.imageURLs = imageURLs
            
            // Create item document
            let documentRef = try await db.collection(AppConstants.FirebaseCollections.items).addDocument(from: newItem)
            newItem.id = documentRef.documentID
            
            await MainActor.run {
                items.insert(newItem, at: 0)
                updateFeaturedItems()
            }
            
            return true
            
        } catch {
            await MainActor.run {
                errorMessage = AppConstants.ErrorMessages.itemCreationError
            }
            return false
        }
    }
    
    // MARK: - Update Item
    func updateItem(_ item: Item) async -> Bool {
        guard let itemID = item.id else { return false }
        
        do {
            var updatedItem = item
            updatedItem.updatedAt = Date()
            
            try await db.collection(AppConstants.FirebaseCollections.items).document(itemID).setData(from: updatedItem, merge: true)
            
            await MainActor.run {
                if let index = items.firstIndex(where: { $0.id == itemID }) {
                    items[index] = updatedItem
                }
                updateFeaturedItems()
            }
            
            return true
            
        } catch {
            await MainActor.run {
                errorMessage = AppConstants.ErrorMessages.itemCreationError
            }
            return false
        }
    }
    
    // MARK: - Delete Item
    func deleteItem(_ item: Item) async -> Bool {
        guard let itemID = item.id else { return false }
        
        do {
            // Delete from Firestore
            try await db.collection(AppConstants.FirebaseCollections.items).document(itemID).delete()
            
            // Delete images from Storage
            for imageURL in item.imageURLs {
                try await deleteImageFromStorage(imageURL)
            }
            
            await MainActor.run {
                items.removeAll { $0.id == itemID }
                userItems.removeAll { $0.id == itemID }
                updateFeaturedItems()
            }
            
            return true
            
        } catch {
            await MainActor.run {
                errorMessage = AppConstants.ErrorMessages.networkError
            }
            return false
        }
    }
    
    // MARK: - Mark as Sold
    func markItemAsSold(_ item: Item, buyerID: String) async -> Bool {
        guard let itemID = item.id else { return false }
        
        do {
            let updateData: [String: Any] = [
                "status": ItemStatus.sold.rawValue,
                "soldAt": FieldValue.serverTimestamp(),
                "buyerID": buyerID,
                "updatedAt": FieldValue.serverTimestamp()
            ]
            
            try await db.collection(AppConstants.FirebaseCollections.items).document(itemID).updateData(updateData)
            
            await MainActor.run {
                if let index = items.firstIndex(where: { $0.id == itemID }) {
                    items[index].status = .sold
                    items[index].soldAt = Date()
                    items[index].buyerID = buyerID
                    items[index].updatedAt = Date()
                }
                updateFeaturedItems()
            }
            
            return true
            
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
            return false
        }
    }
    
    // MARK: - Search and Filter
    func searchItems(query: String, category: ItemCategory? = nil, minPrice: Double? = nil, maxPrice: Double? = nil, condition: ItemCondition? = nil) {
        var filteredItems = items
        
        // Text search
        if !query.isEmpty {
            filteredItems = filteredItems.filter { item in
                item.title.localizedCaseInsensitiveContains(query) ||
                item.description.localizedCaseInsensitiveContains(query) ||
                item.tags.contains { $0.localizedCaseInsensitiveContains(query) }
            }
        }
        
        // Category filter
        if let category = category {
            filteredItems = filteredItems.filter { $0.category == category }
        }
        
        // Price range filter
        if let minPrice = minPrice {
            filteredItems = filteredItems.filter { $0.price >= minPrice }
        }
        
        if let maxPrice = maxPrice {
            filteredItems = filteredItems.filter { $0.price <= maxPrice }
        }
        
        // Condition filter
        if let condition = condition {
            filteredItems = filteredItems.filter { $0.condition == condition }
        }
        
        searchResults = filteredItems
    }
    
    func getItemsByCategory(_ category: ItemCategory) -> [Item] {
        return items.filter { $0.category == category }
    }
    
    // MARK: - Featured Items
    private func updateFeaturedItems() {
        // Featured items could be based on views, likes, recent, etc.
        featuredItems = Array(items.sorted { item1, item2 in
            let score1 = item1.views + (item1.likes * 2)
            let score2 = item2.views + (item2.likes * 2)
            return score1 > score2
        }.prefix(10))
    }
    
    // MARK: - Increment Views/Likes
    func incrementViews(for item: Item) async {
        guard let itemID = item.id else { return }
        
        do {
            try await db.collection(AppConstants.FirebaseCollections.items).document(itemID).updateData([
                "views": FieldValue.increment(Int64(1))
            ])
            
            await MainActor.run {
                if let index = items.firstIndex(where: { $0.id == itemID }) {
                    items[index].views += 1
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = AppConstants.ErrorMessages.networkError
            }
        }
    }
    
    func toggleLike(for item: Item, userID: String) async {
        guard let itemID = item.id else { return }
        
        // This would typically check if user already liked and toggle accordingly
        // For simplicity, we'll just increment
        do {
            try await db.collection(AppConstants.FirebaseCollections.items).document(itemID).updateData([
                "likes": FieldValue.increment(Int64(1))
            ])
            
            await MainActor.run {
                if let index = items.firstIndex(where: { $0.id == itemID }) {
                    items[index].likes += 1
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = AppConstants.ErrorMessages.networkError
            }
        }
    }
    
    // MARK: - Image Upload
    private func uploadImages(_ images: [UIImage]) async throws -> [String] {
        var imageURLs: [String] = []
        
        for (index, image) in images.enumerated() {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else { continue }
            
            let fileName = "\(UUID().uuidString)_\(index).jpg"
            let storageRef = storage.reference().child("\(AppConstants.FirebaseStoragePaths.itemImages)/\(fileName)")
            
            let _ = try await storageRef.putDataAsync(imageData)
            let downloadURL = try await storageRef.downloadURL()
            imageURLs.append(downloadURL.absoluteString)
        }
        
        return imageURLs
    }
    
    private func deleteImageFromStorage(_ imageURL: String) async throws {
        let storageRef = storage.reference(forURL: imageURL)
        try await storageRef.delete()
    }
    
    // MARK: - Sort Options
    enum SortOption: String, CaseIterable {
        case newest = "Newest First"
        case oldest = "Oldest First"
        case priceLowToHigh = "Price: Low to High"
        case priceHighToLow = "Price: High to Low"
        case mostViewed = "Most Viewed"
        case mostLiked = "Most Liked"
    }
    
    func sortItems(by option: SortOption) {
        switch option {
        case .newest:
            items.sort { $0.createdAt > $1.createdAt }
        case .oldest:
            items.sort { $0.createdAt < $1.createdAt }
        case .priceLowToHigh:
            items.sort { $0.price < $1.price }
        case .priceHighToLow:
            items.sort { $0.price > $1.price }
        case .mostViewed:
            items.sort { $0.views > $1.views }
        case .mostLiked:
            items.sort { $0.likes > $1.likes }
        }
    }
} 