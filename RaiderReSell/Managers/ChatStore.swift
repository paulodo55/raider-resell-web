import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import Combine

class ChatStore: ObservableObject {
    @Published var chats: [Chat] = []
    @Published var currentMessages: [Message] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var chatsListener: ListenerRegistration?
    private var messagesListener: ListenerRegistration?
    private var currentChatID: String?
    
    init() {
        setupChatsListener()
    }
    
    deinit {
        chatsListener?.remove()
        messagesListener?.remove()
    }
    
    // MARK: - Setup Listeners
    private func setupChatsListener() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        chatsListener = db.collection("chats")
            .whereField("participantIDs", arrayContains: currentUserID)
            .order(by: "lastMessageTimestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        return
                    }
                    
                    self?.chats = snapshot?.documents.compactMap { document in
                        try? document.data(as: Chat.self)
                    } ?? []
                }
            }
    }
    
    private func setupMessagesListener(for chatID: String) {
        messagesListener?.remove()
        currentChatID = chatID
        
        messagesListener = db.collection("chats").document(chatID)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        return
                    }
                    
                    self?.currentMessages = snapshot?.documents.compactMap { document in
                        try? document.data(as: Message.self)
                    } ?? []
                }
            }
    }
    
    // MARK: - Create Chat
    func createChat(itemID: String, itemTitle: String, itemPrice: Double, sellerID: String, sellerName: String, itemImageURL: String? = nil) async -> String? {
        guard let currentUserID = Auth.auth().currentUser?.uid,
              let currentUser = Auth.auth().currentUser else { return nil }
        
        // Check if chat already exists
        let existingChatID = await findExistingChat(itemID: itemID, buyerID: currentUserID, sellerID: sellerID)
        if let chatID = existingChatID {
            return chatID
        }
        
        // Create new chat
        let chat = Chat(
            itemID: itemID,
            itemTitle: itemTitle,
            itemPrice: itemPrice,
            buyerID: currentUserID,
            buyerName: currentUser.displayName ?? "User",
            sellerID: sellerID,
            sellerName: sellerName,
            itemImageURL: itemImageURL
        )
        
        do {
            let chatRef = try await db.collection("chats").addDocument(from: chat)
            
            // Send initial message
            let initialMessage = Message(
                chatID: chatRef.documentID,
                senderID: currentUserID,
                senderName: currentUser.displayName ?? "User",
                content: "Hi! I'm interested in your \(itemTitle).",
                type: .text
            )
            
            try await sendMessage(initialMessage)
            
            return chatRef.documentID
            
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
            return nil
        }
    }
    
    private func findExistingChat(itemID: String, buyerID: String, sellerID: String) async -> String? {
        do {
            let snapshot = try await db.collection("chats")
                .whereField("itemID", isEqualTo: itemID)
                .whereField("buyerID", isEqualTo: buyerID)
                .whereField("sellerID", isEqualTo: sellerID)
                .getDocuments()
            
            return snapshot.documents.first?.documentID
        } catch {
            return nil
        }
    }
    
    // MARK: - Send Message
    func sendMessage(_ message: Message) async {
        do {
            let messageRef = try await db.collection("chats")
                .document(message.chatID)
                .collection("messages")
                .addDocument(from: message)
            
            // Update chat with last message info
            try await db.collection("chats").document(message.chatID).updateData([
                "lastMessage": message.content,
                "lastMessageTimestamp": FieldValue.serverTimestamp(),
                "lastMessageSenderID": message.senderID
            ])
            
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func sendTextMessage(chatID: String, content: String) async {
        guard let currentUserID = Auth.auth().currentUser?.uid,
              let currentUser = Auth.auth().currentUser else { return }
        
        let message = Message(
            chatID: chatID,
            senderID: currentUserID,
            senderName: currentUser.displayName ?? "User",
            content: content,
            type: .text
        )
        
        await sendMessage(message)
    }
    
    func sendOfferMessage(chatID: String, offerAmount: Double, message: String = "") async {
        guard let currentUserID = Auth.auth().currentUser?.uid,
              let currentUser = Auth.auth().currentUser else { return }
        
        let content = message.isEmpty ? "Made an offer of $\(String(format: "%.2f", offerAmount))" : message
        
        var offerMessage = Message(
            chatID: chatID,
            senderID: currentUserID,
            senderName: currentUser.displayName ?? "User",
            content: content,
            type: .offer
        )
        offerMessage.offerAmount = offerAmount
        
        await sendMessage(offerMessage)
    }
    
    // MARK: - Load Messages
    func loadMessages(for chatID: String) {
        setupMessagesListener(for: chatID)
        markMessagesAsRead(chatID: chatID)
    }
    
    // MARK: - Mark Messages as Read
    private func markMessagesAsRead(chatID: String) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        Task {
            do {
                let snapshot = try await db.collection("chats")
                    .document(chatID)
                    .collection("messages")
                    .whereField("senderID", isNotEqualTo: currentUserID)
                    .whereField("status", isNotEqualTo: MessageStatus.read.rawValue)
                    .getDocuments()
                
                let batch = db.batch()
                
                for document in snapshot.documents {
                    batch.updateData(["status": MessageStatus.read.rawValue], forDocument: document.reference)
                }
                
                try await batch.commit()
                
                // Update unread count in chat
                try await db.collection("chats").document(chatID).updateData([
                    "unreadCount": 0
                ])
                
                    } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to mark messages as read"
            }
        }
        }
    }
    
    // MARK: - Offers
    func createOffer(chatID: String, itemID: String, sellerID: String, amount: Double, originalPrice: Double, message: String? = nil) async -> Bool {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return false }
        
        let offer = Offer(
            chatID: chatID,
            itemID: itemID,
            buyerID: currentUserID,
            sellerID: sellerID,
            amount: amount,
            originalPrice: originalPrice,
            message: message
        )
        
        do {
            try await db.collection("offers").addDocument(from: offer)
            
            // Update chat with current offer
            try await db.collection("chats").document(chatID).updateData([
                "currentOffer": amount,
                "offerStatus": OfferStatus.pending.rawValue
            ])
            
            // Send offer message
            await sendOfferMessage(chatID: chatID, offerAmount: amount, message: message ?? "")
            
            return true
            
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
            return false
        }
    }
    
    func respondToOffer(offerID: String, response: OfferStatus, counterAmount: Double? = nil) async -> Bool {
        do {
            var updateData: [String: Any] = [
                "status": response.rawValue,
                "respondedAt": FieldValue.serverTimestamp()
            ]
            
            if let counterAmount = counterAmount {
                updateData["amount"] = counterAmount
            }
            
            try await db.collection("offers").document(offerID).updateData(updateData)
            
            return true
            
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
            return false
        }
    }
    
    // MARK: - Image Messages
    func sendImageMessage(chatID: String, image: UIImage) async {
        guard let currentUserID = Auth.auth().currentUser?.uid,
              let currentUser = Auth.auth().currentUser else { return }
        
        do {
            // Upload image to Firebase Storage
            let imageURL = try await uploadMessageImage(image)
            
            var message = Message(
                chatID: chatID,
                senderID: currentUserID,
                senderName: currentUser.displayName ?? "User",
                content: "Sent an image",
                type: .image
            )
            message.imageURL = imageURL
            
            await sendMessage(message)
            
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func uploadMessageImage(_ image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw NSError(domain: "ImageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not compress image"])
        }
        
        let fileName = "\(UUID().uuidString).jpg"
        let storageRef = Storage.storage().reference().child("message_images/\(fileName)")
        
        let _ = try await storageRef.putDataAsync(imageData)
        let downloadURL = try await storageRef.downloadURL()
        
        return downloadURL.absoluteString
    }
    
    // MARK: - Chat Management
    func deleteChat(_ chat: Chat) async -> Bool {
        guard let chatID = chat.id else { return false }
        
        do {
            // Delete all messages in the chat
            let messagesSnapshot = try await db.collection("chats")
                .document(chatID)
                .collection("messages")
                .getDocuments()
            
            let batch = db.batch()
            
            for messageDoc in messagesSnapshot.documents {
                batch.deleteDocument(messageDoc.reference)
            }
            
            // Delete the chat document
            batch.deleteDocument(db.collection("chats").document(chatID))
            
            try await batch.commit()
            
            await MainActor.run {
                chats.removeAll { $0.id == chatID }
            }
            
            return true
            
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
            return false
        }
    }
    
    func archiveChat(_ chat: Chat) async -> Bool {
        guard let chatID = chat.id else { return false }
        
        do {
            try await db.collection("chats").document(chatID).updateData([
                "isActive": false
            ])
            
            return true
            
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
            return false
        }
    }
    
    // MARK: - Helper Methods
    func getUnreadMessagesCount() -> Int {
        return chats.reduce(0) { $0 + $1.unreadCount }
    }
    
    func getChatForItem(itemID: String) -> Chat? {
        return chats.first { $0.itemID == itemID }
    }
} 