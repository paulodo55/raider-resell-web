import Foundation
import FirebaseFirestore

enum ItemCategory: String, CaseIterable, Codable {
    case textbooks = "Textbooks"
    case electronics = "Electronics"
    case clothing = "Clothing"
    case furniture = "Furniture"
    case sports = "Sports & Recreation"
    case tickets = "Tickets"
    case dorm = "Dorm Supplies"
    case techGear = "Tech Gear"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .textbooks: return "book.fill"
        case .electronics: return "iphone"
        case .clothing: return "tshirt.fill"
        case .furniture: return "bed.double.fill"
        case .sports: return "sportscourt.fill"
        case .tickets: return "ticket.fill"
        case .dorm: return "house.fill"
        case .techGear: return "laptopcomputer"
        case .other: return "square.grid.2x2.fill"
        }
    }
}

enum ItemCondition: String, CaseIterable, Codable {
    case new = "New"
    case likeNew = "Like New"
    case good = "Good"
    case fair = "Fair"
    case poor = "Poor"
    
    var color: String {
        switch self {
        case .new: return "green"
        case .likeNew: return "blue"
        case .good: return "orange"
        case .fair: return "yellow"
        case .poor: return "red"
        }
    }
}

enum ItemStatus: String, Codable {
    case active = "active"
    case sold = "sold"
    case pending = "pending"
    case draft = "draft"
}

struct Item: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var price: Double
    var originalPrice: Double?
    var category: ItemCategory
    var condition: ItemCondition
    var status: ItemStatus
    var sellerID: String
    var sellerName: String
    var imageURLs: [String]
    var location: String // Dorm, campus area, etc.
    var isNegotiable: Bool
    var views: Int
    var likes: Int
    var createdAt: Date
    var updatedAt: Date
    var soldAt: Date?
    var buyerID: String?
    var tags: [String]
    var aiSuggestedPrice: Double?
    var aiMarketAnalysis: String?
    
    var formattedPrice: String {
        return String(format: "$%.2f", price)
    }
    
    var formattedOriginalPrice: String? {
        guard let originalPrice = originalPrice else { return nil }
        return String(format: "$%.2f", originalPrice)
    }
    
    var isDiscounted: Bool {
        guard let originalPrice = originalPrice else { return false }
        return price < originalPrice
    }
    
    var discountPercentage: Int? {
        guard let originalPrice = originalPrice, originalPrice > 0, isDiscounted else { return nil }
        return Int(((originalPrice - price) / originalPrice) * 100)
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
    
    init(title: String, description: String, price: Double, category: ItemCategory, condition: ItemCondition, sellerID: String, sellerName: String, location: String, imageURLs: [String] = []) {
        self.title = title
        self.description = description
        self.price = price
        self.category = category
        self.condition = condition
        self.status = .active
        self.sellerID = sellerID
        self.sellerName = sellerName
        self.imageURLs = imageURLs
        self.location = location
        self.isNegotiable = true
        self.views = 0
        self.likes = 0
        self.createdAt = Date()
        self.updatedAt = Date()
        self.tags = []
    }
} 