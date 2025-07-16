import XCTest
@testable import RaiderReSell

final class RaiderReSellTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // MARK: - Model Tests
    
    func testUserInitialization() throws {
        let user = User(
            email: "test@ttu.edu",
            firstName: "John",
            lastName: "Doe",
            studentID: "12345678",
            graduationYear: 2024
        )
        
        XCTAssertEqual(user.email, "test@ttu.edu")
        XCTAssertEqual(user.firstName, "John")
        XCTAssertEqual(user.lastName, "Doe")
        XCTAssertEqual(user.fullName, "John Doe")
        XCTAssertEqual(user.studentID, "12345678")
        XCTAssertEqual(user.graduationYear, 2024)
        XCTAssertEqual(user.rating, 0.0)
        XCTAssertEqual(user.totalRatings, 0)
        XCTAssertEqual(user.itemsSold, 0)
        XCTAssertEqual(user.itemsBought, 0)
        XCTAssertFalse(user.isVerified)
    }
    
    func testItemInitialization() throws {
        let item = Item(
            title: "Test Item",
            description: "Test Description",
            price: 99.99,
            category: .electronics,
            condition: .good,
            sellerID: "seller123",
            sellerName: "John Doe",
            location: "Test Location"
        )
        
        XCTAssertEqual(item.title, "Test Item")
        XCTAssertEqual(item.description, "Test Description")
        XCTAssertEqual(item.price, 99.99)
        XCTAssertEqual(item.category, .electronics)
        XCTAssertEqual(item.condition, .good)
        XCTAssertEqual(item.sellerID, "seller123")
        XCTAssertEqual(item.sellerName, "John Doe")
        XCTAssertEqual(item.location, "Test Location")
        XCTAssertEqual(item.status, .active)
        XCTAssertEqual(item.formattedPrice, "$99.99")
        XCTAssertTrue(item.isNegotiable)
        XCTAssertEqual(item.views, 0)
        XCTAssertEqual(item.likes, 0)
    }
    
    func testItemDiscountCalculation() throws {
        let item = Item(
            title: "Test Item",
            description: "Test Description",
            price: 80.0,
            category: .electronics,
            condition: .good,
            sellerID: "seller123",
            sellerName: "John Doe",
            location: "Test Location"
        )
        
        var discountedItem = item
        discountedItem.originalPrice = 100.0
        
        XCTAssertTrue(discountedItem.isDiscounted)
        XCTAssertEqual(discountedItem.discountPercentage, 20)
        XCTAssertEqual(discountedItem.formattedOriginalPrice, "$100.00")
    }
    
    func testChatInitialization() throws {
        let chat = Chat(
            itemID: "item123",
            itemTitle: "Test Item",
            itemPrice: 50.0,
            buyerID: "buyer123",
            buyerName: "Jane Doe",
            sellerID: "seller123",
            sellerName: "John Doe"
        )
        
        XCTAssertEqual(chat.itemID, "item123")
        XCTAssertEqual(chat.itemTitle, "Test Item")
        XCTAssertEqual(chat.itemPrice, 50.0)
        XCTAssertEqual(chat.buyerID, "buyer123")
        XCTAssertEqual(chat.buyerName, "Jane Doe")
        XCTAssertEqual(chat.sellerID, "seller123")
        XCTAssertEqual(chat.sellerName, "John Doe")
        XCTAssertEqual(chat.lastMessage, "Chat started")
        XCTAssertEqual(chat.unreadCount, 0)
        XCTAssertTrue(chat.isActive)
    }
    
    func testMessageInitialization() throws {
        let message = Message(
            chatID: "chat123",
            senderID: "sender123",
            senderName: "John Doe",
            content: "Hello!",
            type: .text
        )
        
        XCTAssertEqual(message.chatID, "chat123")
        XCTAssertEqual(message.senderID, "sender123")
        XCTAssertEqual(message.senderName, "John Doe")
        XCTAssertEqual(message.content, "Hello!")
        XCTAssertEqual(message.type, .text)
        XCTAssertEqual(message.status, .sent)
        XCTAssertFalse(message.isEdited)
        XCTAssertFalse(message.isOffer)
    }
    
    func testOfferInitialization() throws {
        let offer = Offer(
            chatID: "chat123",
            itemID: "item123",
            buyerID: "buyer123",
            sellerID: "seller123",
            amount: 80.0,
            originalPrice: 100.0,
            message: "My offer"
        )
        
        XCTAssertEqual(offer.chatID, "chat123")
        XCTAssertEqual(offer.itemID, "item123")
        XCTAssertEqual(offer.buyerID, "buyer123")
        XCTAssertEqual(offer.sellerID, "seller123")
        XCTAssertEqual(offer.amount, 80.0)
        XCTAssertEqual(offer.originalPrice, 100.0)
        XCTAssertEqual(offer.message, "My offer")
        XCTAssertEqual(offer.status, .pending)
        XCTAssertEqual(offer.formattedAmount, "$80.00")
        XCTAssertEqual(offer.formattedOriginalPrice, "$100.00")
        XCTAssertEqual(offer.discountPercentage, 20)
        XCTAssertFalse(offer.isExpired)
    }
    
    // MARK: - Authentication Manager Tests
    
    func testAuthenticationManagerValidation() throws {
        let authManager = AuthenticationManager()
        
        // Test Texas Tech email validation
        XCTAssertTrue(authManager.validateStudentID("12345678"))
        XCTAssertTrue(authManager.validateStudentID("123456789"))
        XCTAssertFalse(authManager.validateStudentID("123"))
        XCTAssertFalse(authManager.validateStudentID("1234567890"))
        XCTAssertFalse(authManager.validateStudentID("abcdefgh"))
        
        // Test graduation year validation
        let currentYear = Calendar.current.component(.year, from: Date())
        XCTAssertTrue(authManager.validateGraduationYear(currentYear))
        XCTAssertTrue(authManager.validateGraduationYear(currentYear + 4))
        XCTAssertFalse(authManager.validateGraduationYear(currentYear - 1))
        XCTAssertFalse(authManager.validateGraduationYear(currentYear + 7))
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
            let items = (0..<1000).map { index in
                Item(
                    title: "Item \(index)",
                    description: "Description \(index)",
                    price: Double(index),
                    category: .electronics,
                    condition: .good,
                    sellerID: "seller\(index)",
                    sellerName: "Seller \(index)",
                    location: "Location \(index)"
                )
            }
            
            // Simulate some processing
            _ = items.filter { $0.price > 500 }
        }
    }
}
