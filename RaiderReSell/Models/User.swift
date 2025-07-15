import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var email: String
    var firstName: String
    var lastName: String
    var studentID: String
    var profileImageURL: String?
    var phoneNumber: String?
    var dormitory: String?
    var graduationYear: Int
    var major: String?
    var rating: Double
    var totalRatings: Int
    var itemsSold: Int
    var itemsBought: Int
    var isVerified: Bool
    var createdAt: Date
    var lastActive: Date
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    var displayRating: String {
        if totalRatings == 0 {
            return "No ratings yet"
        }
        return String(format: "%.1f (%d reviews)", rating, totalRatings)
    }
    
    init(email: String, firstName: String, lastName: String, studentID: String, graduationYear: Int) {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.studentID = studentID
        self.graduationYear = graduationYear
        self.rating = 0.0
        self.totalRatings = 0
        self.itemsSold = 0
        self.itemsBought = 0
        self.isVerified = false
        self.createdAt = Date()
        self.lastActive = Date()
    }
} 