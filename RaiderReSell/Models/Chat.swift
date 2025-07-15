import Foundation
import FirebaseFirestore

enum MessageType: String, Codable {
    case text = "text"
    case image = "image"
    case offer = "offer"
    case system = "system"
}

enum MessageStatus: String, Codable {
    case sent = "sent"
    case delivered = "delivered"
    case read = "read"
}

struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    var chatID: String
    var senderID: String
    var senderName: String
    var content: String
    var type: MessageType
    var status: MessageStatus
    var timestamp: Date
    var imageURL: String?
    var offerAmount: Double?
    var isEdited: Bool
    var editedAt: Date?
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    var isOffer: Bool {
        return type == .offer && offerAmount != nil
    }
    
    init(chatID: String, senderID: String, senderName: String, content: String, type: MessageType = .text) {
        self.chatID = chatID
        self.senderID = senderID
        self.senderName = senderName
        self.content = content
        self.type = type
        self.status = .sent
        self.timestamp = Date()
        self.isEdited = false
    }
}

struct Chat: Identifiable, Codable {
    @DocumentID var id: String?
    var itemID: String
    var itemTitle: String
    var itemPrice: Double
    var itemImageURL: String?
    var buyerID: String
    var buyerName: String
    var sellerID: String
    var sellerName: String
    var lastMessage: String
    var lastMessageTimestamp: Date
    var lastMessageSenderID: String
    var unreadCount: Int
    var isActive: Bool
    var createdAt: Date
    var currentOffer: Double?
    var offerStatus: OfferStatus?
    
    var otherUserID: String {
        // This should be set based on current user context
        return ""
    }
    
    var otherUserName: String {
        // This should be set based on current user context
        return ""
    }
    
    var formattedLastMessageTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: lastMessageTimestamp, relativeTo: Date())
    }
    
    init(itemID: String, itemTitle: String, itemPrice: Double, buyerID: String, buyerName: String, sellerID: String, sellerName: String, itemImageURL: String? = nil) {
        self.itemID = itemID
        self.itemTitle = itemTitle
        self.itemPrice = itemPrice
        self.itemImageURL = itemImageURL
        self.buyerID = buyerID
        self.buyerName = buyerName
        self.sellerID = sellerID
        self.sellerName = sellerName
        self.lastMessage = "Chat started"
        self.lastMessageTimestamp = Date()
        self.lastMessageSenderID = buyerID
        self.unreadCount = 0
        self.isActive = true
        self.createdAt = Date()
    }
}

enum OfferStatus: String, Codable {
    case pending = "pending"
    case accepted = "accepted"
    case declined = "declined"
    case countered = "countered"
    case expired = "expired"
}

struct Offer: Identifiable, Codable {
    @DocumentID var id: String?
    var chatID: String
    var itemID: String
    var buyerID: String
    var sellerID: String
    var amount: Double
    var originalPrice: Double
    var message: String?
    var status: OfferStatus
    var createdAt: Date
    var respondedAt: Date?
    var expiresAt: Date
    
    var formattedAmount: String {
        return String(format: "$%.2f", amount)
    }
    
    var formattedOriginalPrice: String {
        return String(format: "$%.2f", originalPrice)
    }
    
    var discountPercentage: Int {
        return Int(((originalPrice - amount) / originalPrice) * 100)
    }
    
    var isExpired: Bool {
        return Date() > expiresAt
    }
    
    var timeRemaining: String {
        let formatter = RelativeDateTimeFormatter()
        return formatter.localizedString(for: expiresAt, relativeTo: Date())
    }
    
    init(chatID: String, itemID: String, buyerID: String, sellerID: String, amount: Double, originalPrice: Double, message: String? = nil) {
        self.chatID = chatID
        self.itemID = itemID
        self.buyerID = buyerID
        self.sellerID = sellerID
        self.amount = amount
        self.originalPrice = originalPrice
        self.message = message
        self.status = .pending
        self.createdAt = Date()
        self.expiresAt = Date().addingTimeInterval(24 * 60 * 60) // 24 hours
    }
} 