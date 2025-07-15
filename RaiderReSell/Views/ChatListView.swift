import SwiftUI
import SDWebImageSwiftUI

struct ChatListView: View {
    @EnvironmentObject var chatStore: ChatStore
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var aiAssistant: AIAssistant
    
    @State private var searchText = ""
    @State private var showingAIChat = false
    
    var filteredChats: [Chat] {
        if searchText.isEmpty {
            return chatStore.chats
        } else {
            return chatStore.chats.filter { chat in
                chat.itemTitle.localizedCaseInsensitiveContains(searchText) ||
                chat.otherUserName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // AI Assistant Card
                aiAssistantCard
                
                // Chats List
                if filteredChats.isEmpty {
                    emptyStateView
                } else {
                    chatsList
                }
            }
            .background(TexasTechTheme.lightGray.opacity(0.3))
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAIChat) {
                AIAssistantChatView()
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Messages")
                        .font(TexasTechTypography.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(TexasTechTheme.black)
                    
                    Text("Chat with buyers and sellers")
                        .font(TexasTechTypography.caption1)
                        .foregroundColor(TexasTechTheme.mediumGray)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "square.and.pencil")
                        .font(.title2)
                        .foregroundColor(TexasTechTheme.primaryRed)
                }
            }
            
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(TexasTechTheme.mediumGray)
                
                TextField("Search conversations...", text: $searchText)
                    .font(TexasTechTypography.body)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(TexasTechTheme.mediumGray)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(TexasTechTheme.white)
            .cornerRadius(12)
            .shadow(color: TexasTechTheme.cardShadow, radius: 2, x: 0, y: 1)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 16)
        .background(TexasTechTheme.white)
    }
    
    // MARK: - AI Assistant Card
    private var aiAssistantCard: some View {
        Button(action: { showingAIChat = true }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(TexasTechTheme.primaryGradient)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "brain.head.profile")
                        .font(.title2)
                        .foregroundColor(TexasTechTheme.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI Assistant")
                        .font(TexasTechTypography.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(TexasTechTheme.black)
                    
                    Text("Get marketplace help and price insights")
                        .font(TexasTechTypography.caption1)
                        .foregroundColor(TexasTechTheme.mediumGray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(TexasTechTheme.mediumGray)
            }
            .padding()
            .texasTechCard()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
    // MARK: - Chats List
    private var chatsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredChats) { chat in
                    NavigationLink(destination: ChatDetailView(chat: chat)) {
                        ChatRowView(chat: chat)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "message.circle")
                .font(.system(size: 64))
                .foregroundColor(TexasTechTheme.mediumGray)
            
            VStack(spacing: 8) {
                Text("No conversations yet")
                    .font(TexasTechTypography.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(TexasTechTheme.black)
                
                Text("Start browsing items to begin chatting with sellers")
                    .font(TexasTechTypography.body)
                    .foregroundColor(TexasTechTheme.mediumGray)
                    .multilineTextAlignment(.center)
            }
            
            Button("Browse Marketplace") {
                // Navigate to marketplace
            }
            .primaryButton()
            .padding(.horizontal, 60)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Chat Row View

struct ChatRowView: View {
    let chat: Chat
    
    var body: some View {
        HStack(spacing: 16) {
            // Item image or avatar
            AsyncImage(url: URL(string: chat.itemImageURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(TexasTechTheme.lightGray)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(TexasTechTheme.mediumGray)
                    )
            }
            .frame(width: 60, height: 60)
            .cornerRadius(12)
            
            // Chat content
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(chat.itemTitle)
                        .font(TexasTechTypography.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(TexasTechTheme.black)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(chat.formattedLastMessageTime)
                        .font(TexasTechTypography.caption2)
                        .foregroundColor(TexasTechTheme.mediumGray)
                }
                
                HStack {
                    Text(chat.otherUserName)
                        .font(TexasTechTypography.caption1)
                        .foregroundColor(TexasTechTheme.primaryRed)
                    
                    Spacer()
                    
                    Text("$\(String(format: "%.2f", chat.itemPrice))")
                        .font(TexasTechTypography.caption1)
                        .fontWeight(.medium)
                        .foregroundColor(TexasTechTheme.black)
                }
                
                HStack {
                    Text(chat.lastMessage)
                        .font(TexasTechTypography.caption1)
                        .foregroundColor(TexasTechTheme.mediumGray)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if chat.unreadCount > 0 {
                        Text("\(chat.unreadCount)")
                            .font(TexasTechTypography.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(TexasTechTheme.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(TexasTechTheme.primaryRed)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding()
        .texasTechCard()
    }
}

// MARK: - AI Assistant Chat View

struct AIAssistantChatView: View {
    @EnvironmentObject var aiAssistant: AIAssistant
    @Environment(\.presentationMode) var presentationMode
    
    @State private var messageText = ""
    @State private var messages: [AIMessage] = []
    
    struct AIMessage: Identifiable {
        let id = UUID()
        let content: String
        let isUser: Bool
        let timestamp: Date
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Messages list
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(messages) { message in
                            AIMessageBubble(message: message)
                        }
                    }
                    .padding()
                }
                
                // Input area
                HStack(spacing: 12) {
                    TextField("Ask about marketplace, prices, or selling tips...", text: $messageText, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(1...4)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(TexasTechTheme.white)
                            .padding(12)
                            .background(
                                messageText.isEmpty ? TexasTechTheme.mediumGray : TexasTechTheme.primaryRed
                            )
                            .cornerRadius(20)
                    }
                    .disabled(messageText.isEmpty || aiAssistant.isLoading)
                }
                .padding()
                .background(TexasTechTheme.white)
            }
            .navigationTitle("AI Assistant")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .onAppear {
            addWelcomeMessage()
        }
    }
    
    private func addWelcomeMessage() {
        messages.append(AIMessage(
            content: "Hi! I'm your Raider ReSell AI assistant. I can help you with pricing, market insights, selling tips, and answer questions about the marketplace. What would you like to know?",
            isUser: false,
            timestamp: Date()
        ))
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        let userMessage = AIMessage(
            content: messageText,
            isUser: true,
            timestamp: Date()
        )
        messages.append(userMessage)
        
        let query = messageText
        messageText = ""
        
        Task {
            await aiAssistant.processUserQuery(query, context: .generalMarketplace)
            
            await MainActor.run {
                if !aiAssistant.chatResponse.isEmpty {
                    messages.append(AIMessage(
                        content: aiAssistant.chatResponse,
                        isUser: false,
                        timestamp: Date()
                    ))
                }
            }
        }
    }
}

// MARK: - AI Message Bubble

struct AIMessageBubble: View {
    let message: AIAssistantChatView.AIMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(TexasTechTypography.body)
                    .foregroundColor(message.isUser ? TexasTechTheme.white : TexasTechTheme.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        message.isUser ? TexasTechTheme.primaryRed : TexasTechTheme.lightGray
                    )
                    .cornerRadius(16)
                
                Text(DateFormatter.timeFormatter.string(from: message.timestamp))
                    .font(TexasTechTypography.caption2)
                    .foregroundColor(TexasTechTheme.mediumGray)
                    .padding(.horizontal, 4)
            }
            
            if !message.isUser {
                Spacer()
            }
        }
    }
}

// MARK: - Chat Detail View (Placeholder)

struct ChatDetailView: View {
    let chat: Chat
    
    var body: some View {
        VStack {
            Text("Chat with \(chat.otherUserName)")
                .font(TexasTechTypography.title2)
                .fontWeight(.bold)
            
            Text("About: \(chat.itemTitle)")
                .font(TexasTechTypography.body)
                .foregroundColor(TexasTechTheme.mediumGray)
            
            Spacer()
            
            Text("Chat interface coming soon...")
                .font(TexasTechTypography.body)
                .foregroundColor(TexasTechTheme.mediumGray)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Extensions

extension DateFormatter {
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}

#Preview {
    ChatListView()
        .environmentObject(ChatStore())
        .environmentObject(AuthenticationManager())
        .environmentObject(AIAssistant())
} 