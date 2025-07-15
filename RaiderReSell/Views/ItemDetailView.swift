import SwiftUI
import SDWebImageSwiftUI

struct ItemDetailView: View {
    let item: Item
    @EnvironmentObject var chatStore: ChatStore
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var aiAssistant: AIAssistant
    
    @State private var showingChat = false
    @State private var showingOfferSheet = false
    @State private var offerAmount = ""
    @State private var selectedImageIndex = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Image carousel
                imageCarousel
                
                // Item details
                itemInfoSection
                
                // Seller info
                sellerInfoSection
                
                // AI Analysis
                if let analysis = aiAssistant.priceAnalysis {
                    aiAnalysisSection(analysis)
                }
                
                // Description
                descriptionSection
            }
            .padding(.horizontal, 20)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                shareButton
            }
        }
        .safeAreaInset(edge: .bottom) {
            actionButtonsSection
        }
        .sheet(isPresented: $showingOfferSheet) {
            OfferSheetView(
                item: item,
                offerAmount: $offerAmount,
                onSubmit: makeOffer
            )
        }
        .onAppear {
            // Get AI price analysis for this item
            Task {
                await aiAssistant.analyzePriceForItem(
                    title: item.title,
                    description: item.description,
                    condition: item.condition,
                    category: item.category
                )
            }
        }
    }
    
    // MARK: - Image Carousel
    private var imageCarousel: some View {
        TabView(selection: $selectedImageIndex) {
            ForEach(0..<item.imageURLs.count, id: \.self) { index in
                WebImage(url: URL(string: item.imageURLs[index]))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 300)
                    .clipped()
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .frame(height: 300)
        .cornerRadius(12)
    }
    
    // MARK: - Item Info Section
    private var itemInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(item.title)
                    .font(TexasTechTypography.title2)
                    .fontWeight(.bold)
                    .foregroundColor(TexasTechTheme.black)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "heart")
                        .font(.title2)
                        .foregroundColor(TexasTechTheme.primaryRed)
                }
            }
            
            HStack {
                Text(item.formattedPrice)
                    .font(TexasTechTypography.title1)
                    .fontWeight(.bold)
                    .foregroundColor(TexasTechTheme.primaryRed)
                
                if let originalPrice = item.formattedOriginalPrice {
                    Text(originalPrice)
                        .font(TexasTechTypography.headline)
                        .strikethrough()
                        .foregroundColor(TexasTechTheme.mediumGray)
                }
                
                if let discount = item.discountPercentage {
                    Text("\(discount)% OFF")
                        .font(TexasTechTypography.caption1)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(TexasTechTheme.success)
                        .foregroundColor(TexasTechTheme.white)
                        .cornerRadius(6)
                }
                
                Spacer()
            }
            
            HStack(spacing: 16) {
                TagView(title: item.condition.rawValue, color: Color(item.condition.color))
                TagView(title: item.category.rawValue, color: TexasTechTheme.primaryRed)
                TagView(title: item.location, color: TexasTechTheme.mediumGray)
            }
            
            HStack {
                Image(systemName: "eye")
                Text("\(item.views) views")
                
                Image(systemName: "heart")
                Text("\(item.likes) likes")
                
                Spacer()
                
                Text("Posted \(item.timeAgo)")
            }
            .font(TexasTechTypography.caption1)
            .foregroundColor(TexasTechTheme.mediumGray)
        }
    }
    
    // MARK: - Seller Info Section
    private var sellerInfoSection: some View {
        HStack {
            Circle()
                .fill(TexasTechTheme.primaryRed.opacity(0.1))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(String(item.sellerName.prefix(1)))
                        .font(TexasTechTypography.headline)
                        .fontWeight(.bold)
                        .foregroundColor(TexasTechTheme.primaryRed)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.sellerName)
                    .font(TexasTechTypography.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(TexasTechTheme.black)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(TexasTechTheme.gold)
                        .font(.caption)
                    Text("4.8 (23 reviews)")
                        .font(TexasTechTypography.caption1)
                        .foregroundColor(TexasTechTheme.mediumGray)
                }
            }
            
            Spacer()
            
            Button("View Profile") {
                // Handle view profile
            }
            .textButton()
        }
        .padding(.vertical, 12)
        .texasTechCard()
    }
    
    // MARK: - AI Analysis Section
    private func aiAnalysisSection(_ analysis: AIAssistant.PriceAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(TexasTechTheme.primaryRed)
                Text("AI Price Analysis")
                    .font(TexasTechTypography.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(TexasTechTheme.black)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Suggested Price:")
                        .font(TexasTechTypography.subheadline)
                        .foregroundColor(TexasTechTheme.mediumGray)
                    
                    Spacer()
                    
                    Text("$\(String(format: "%.2f", analysis.suggestedPrice))")
                        .font(TexasTechTypography.headline)
                        .fontWeight(.bold)
                        .foregroundColor(TexasTechTheme.primaryRed)
                }
                
                HStack {
                    Text("Market Trend:")
                        .font(TexasTechTypography.subheadline)
                        .foregroundColor(TexasTechTheme.mediumGray)
                    
                    Spacer()
                    
                    Text(analysis.marketTrend.capitalized)
                        .font(TexasTechTypography.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(TexasTechTheme.black)
                }
                
                Text(analysis.reasoning)
                    .font(TexasTechTypography.caption1)
                    .foregroundColor(TexasTechTheme.mediumGray)
                    .padding(.top, 4)
            }
        }
        .padding()
        .texasTechCard()
    }
    
    // MARK: - Description Section
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Description")
                .font(TexasTechTypography.headline)
                .fontWeight(.semibold)
                .foregroundColor(TexasTechTheme.black)
            
            Text(item.description)
                .font(TexasTechTypography.body)
                .foregroundColor(TexasTechTheme.black)
                .lineSpacing(4)
        }
    }
    
    // MARK: - Share Button
    private var shareButton: some View {
        Button(action: shareItem) {
            Image(systemName: "square.and.arrow.up")
                .font(.title2)
                .foregroundColor(TexasTechTheme.primaryRed)
        }
    }
    
    // MARK: - Action Buttons
    private var actionButtonsSection: some View {
        HStack(spacing: 12) {
            Button("Message Seller") {
                startChat()
            }
            .secondaryButton()
            .frame(maxWidth: .infinity)
            
            Button("Make Offer") {
                showingOfferSheet = true
            }
            .primaryButton()
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(TexasTechTheme.white)
        .shadow(color: TexasTechTheme.cardShadow, radius: 8, x: 0, y: -2)
    }
    
    // MARK: - Helper Functions
    private func startChat() {
        guard let currentUser = authManager.currentUser else { return }
        
        Task {
            let chatID = await chatStore.createChat(
                itemID: item.id ?? "",
                itemTitle: item.title,
                itemPrice: item.price,
                sellerID: item.sellerID,
                sellerName: item.sellerName,
                itemImageURL: item.imageURLs.first
            )
            
            if chatID != nil {
                showingChat = true
            }
        }
    }
    
    private func makeOffer() {
        guard let amount = Double(offerAmount) else { return }
        
        Task {
            // Create offer logic here
            showingOfferSheet = false
        }
    }
    
    private func shareItem() {
        // Share item logic
    }
}

// MARK: - Supporting Views

struct TagView: View {
    let title: String
    let color: Color
    
    var body: some View {
        Text(title)
            .font(TexasTechTypography.caption1)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .cornerRadius(12)
    }
}

struct OfferSheetView: View {
    let item: Item
    @Binding var offerAmount: String
    let onSubmit: () -> Void
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Text("Make an Offer")
                        .font(TexasTechTypography.title2)
                        .fontWeight(.bold)
                    
                    Text("Current Price: \(item.formattedPrice)")
                        .font(TexasTechTypography.headline)
                        .foregroundColor(TexasTechTheme.primaryRed)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Offer")
                        .font(TexasTechTypography.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("Enter amount", text: $offerAmount)
                        .keyboardType(.decimalPad)
                        .texasTechTextField()
                }
                
                Spacer()
                
                Button("Submit Offer") {
                    onSubmit()
                }
                .primaryButton()
                .disabled(offerAmount.isEmpty)
            }
            .padding()
            .navigationBarItems(
                trailing: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

#Preview {
    NavigationView {
        ItemDetailView(item: Item(
            title: "MacBook Pro 13\"",
            description: "Great condition MacBook Pro perfect for college students. Comes with charger and original box.",
            price: 899.99,
            category: .electronics,
            condition: .good,
            sellerID: "123",
            sellerName: "John Doe",
            location: "Wall/Gates Hall",
            imageURLs: []
        ))
    }
    .environmentObject(ChatStore())
    .environmentObject(AuthenticationManager())
    .environmentObject(AIAssistant())
} 