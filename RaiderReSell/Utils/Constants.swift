import Foundation

// MARK: - App Constants
struct AppConstants {
    
    // MARK: - Firebase Collections
    struct FirebaseCollections {
        static let users = "users"
        static let items = "items"
        static let chats = "chats"
        static let messages = "messages"
        static let offers = "offers"
    }
    
    // MARK: - Firebase Storage Paths
    struct FirebaseStoragePaths {
        static let itemImages = "item_images"
        static let messageImages = "message_images"
        static let profileImages = "profile_images"
    }
    
    // MARK: - User Defaults Keys
    struct UserDefaultsKeys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let notificationsEnabled = "notificationsEnabled"
        static let darkModeEnabled = "darkModeEnabled"
    }
    
    // MARK: - Validation Constants
    struct Validation {
        static let studentIDMinLength = 8
        static let studentIDMaxLength = 9
        static let passwordMinLength = 6
        static let texasTechEmailSuffix = "@ttu.edu"
        static let maxImageUploadCount = 10
        static let maxMessageLength = 500
        static let maxTitleLength = 100
        static let maxDescriptionLength = 1000
    }
    
    // MARK: - UI Constants
    struct UI {
        static let cornerRadius: CGFloat = 12
        static let shadowRadius: CGFloat = 8
        static let shadowOpacity: Float = 0.1
        static let buttonHeight: CGFloat = 50
        static let tabBarHeight: CGFloat = 80
        static let profileImageSize: CGFloat = 100
        static let itemImageHeight: CGFloat = 200
        static let cardSpacing: CGFloat = 16
        static let sectionSpacing: CGFloat = 24
    }
    
    // MARK: - Animation Constants
    struct Animation {
        static let defaultDuration: TimeInterval = 0.3
        static let buttonPressDuration: TimeInterval = 0.1
        static let fadeInDuration: TimeInterval = 0.5
        static let slideInDuration: TimeInterval = 0.4
    }
    
    // MARK: - Offer Constants
    struct Offer {
        static let expirationHours: TimeInterval = 24
        static let minOfferPercentage: Double = 0.1 // 10% of original price
        static let maxOfferPercentage: Double = 0.9 // 90% of original price
    }
    
    // MARK: - Pagination Constants
    struct Pagination {
        static let itemsPerPage = 20
        static let messagesPerPage = 50
        static let chatsPerPage = 30
    }
    
    // MARK: - Search Constants
    struct Search {
        static let minQueryLength = 2
        static let maxRecentSearches = 10
        static let searchDebounceDelay: TimeInterval = 0.5
    }
    
    // MARK: - Campus Locations
    struct CampusLocations {
        static let dormitories = [
            "Chitwood/Weymouth",
            "Coleman Hall",
            "Hulen/Clement",
            "Knapp Hall",
            "Murdough Hall",
            "Stangel/Murdough",
            "Wall/Gates",
            "Other Residence Hall"
        ]
        
        static let campusBuildings = [
            "Student Union Building",
            "Library",
            "Recreation Center",
            "Engineering Building",
            "Business Building",
            "Rawls College of Business",
            "Other Campus Building"
        ]
    }
    
    // MARK: - Error Messages
    struct ErrorMessages {
        static let networkError = "Network connection error. Please try again."
        static let authenticationError = "Authentication failed. Please check your credentials."
        static let invalidEmail = "Please enter a valid Texas Tech email address."
        static let invalidStudentID = "Please enter a valid 8-9 digit student ID."
        static let passwordTooShort = "Password must be at least 6 characters long."
        static let passwordMismatch = "Passwords do not match."
        static let imageUploadError = "Failed to upload image. Please try again."
        static let itemCreationError = "Failed to create item listing. Please try again."
        static let messageSendError = "Failed to send message. Please try again."
        static let offerCreationError = "Failed to create offer. Please try again."
        static let locationPermissionError = "Location permission is required to show nearby items."
        static let cameraPermissionError = "Camera permission is required to take photos."
        static let photoLibraryPermissionError = "Photo library permission is required to select photos."
    }
    
    // MARK: - Success Messages
    struct SuccessMessages {
        static let itemCreated = "Item listed successfully!"
        static let messageSent = "Message sent successfully!"
        static let offerSent = "Offer sent successfully!"
        static let profileUpdated = "Profile updated successfully!"
        static let itemSold = "Item marked as sold!"
        static let accountCreated = "Account created successfully!"
        static let passwordReset = "Password reset email sent!"
    }
    
    // MARK: - AI Assistant Constants
    struct AIAssistant {
        static let maxTokensPerRequest = 1000
        static let maxConversationHistory = 10
        static let priceAnalysisTimeout: TimeInterval = 30
        static let marketResearchTimeout: TimeInterval = 45
        static let chatResponseTimeout: TimeInterval = 20
    }
    
    // MARK: - Notification Types
    struct NotificationTypes {
        static let newMessage = "new_message"
        static let newOffer = "new_offer"
        static let offerAccepted = "offer_accepted"
        static let offerDeclined = "offer_declined"
        static let itemSold = "item_sold"
        static let itemLiked = "item_liked"
        static let priceDropped = "price_dropped"
    }
    
    // MARK: - Deep Link Constants
    struct DeepLinks {
        static let scheme = "raiderresell"
        static let host = "app"
        static let itemPath = "/item"
        static let chatPath = "/chat"
        static let profilePath = "/profile"
        static let marketplacePath = "/marketplace"
    }
} 