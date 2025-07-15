import SwiftUI
import SDWebImageSwiftUI

struct MarketplaceView: View {
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var aiAssistant: AIAssistant
    
    @State private var searchText = ""
    @State private var selectedCategory: ItemCategory? = nil
    @State private var showingFilters = false
    @State private var showingSort = false
    @State private var sortOption: ItemStore.SortOption = .newest
    @State private var minPrice: String = ""
    @State private var maxPrice: String = ""
    @State private var selectedCondition: ItemCondition? = nil
    
    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Category Pills
                categoryScrollView
                
                // Content
                if searchText.isEmpty && selectedCategory == nil {
                    mainContentView
                } else {
                    searchResultsView
                }
            }
            .navigationBarHidden(true)
            .background(TexasTechTheme.lightGray.opacity(0.3))
            .sheet(isPresented: $showingFilters) {
                FiltersView(
                    minPrice: $minPrice,
                    maxPrice: $maxPrice,
                    selectedCondition: $selectedCondition,
                    onApply: applyFilters
                )
            }
            .actionSheet(isPresented: $showingSort) {
                ActionSheet(
                    title: Text("Sort Items"),
                    buttons: ItemStore.SortOption.allCases.map { option in
                        .default(Text(option.rawValue)) {
                            sortOption = option
                            itemStore.sortItems(by: option)
                        }
                    } + [.cancel()]
                )
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Top bar with greeting and profile
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hey, \(authManager.currentUser?.firstName ?? "Raider")! 👋")
                        .font(TexasTechTypography.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(TexasTechTheme.black)
                    
                    Text("Find great deals at Texas Tech")
                        .font(TexasTechTypography.caption1)
                        .foregroundColor(TexasTechTheme.mediumGray)
                }
                
                Spacer()
                
                // Notifications/Profile button
                Button(action: {}) {
                    ZStack {
                        Circle()
                            .fill(TexasTechTheme.primaryRed.opacity(0.1))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "bell")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(TexasTechTheme.primaryRed)
                    }
                }
            }
            
            // Search bar
            HStack(spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(TexasTechTheme.mediumGray)
                        .font(.system(size: 16))
                    
                    TextField("Search items...", text: $searchText)
                        .font(TexasTechTypography.body)
                        .onSubmit {
                            performSearch()
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            itemStore.searchResults = []
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(TexasTechTheme.mediumGray)
                                .font(.system(size: 16))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(TexasTechTheme.white)
                .cornerRadius(12)
                .shadow(color: TexasTechTheme.cardShadow, radius: 2, x: 0, y: 1)
                
                // Filter button
                Button(action: { showingFilters = true }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(TexasTechTheme.primaryRed)
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(TexasTechTheme.white)
                    }
                }
                
                // Sort button
                Button(action: { showingSort = true }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(TexasTechTheme.white)
                            .frame(width: 44, height: 44)
                            .shadow(color: TexasTechTheme.cardShadow, radius: 2, x: 0, y: 1)
                        
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(TexasTechTheme.primaryRed)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 16)
        .background(TexasTechTheme.white)
    }
    
    // MARK: - Category Pills
    private var categoryScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All Categories pill
                CategoryPill(
                    title: "All",
                    icon: "grid.circle.fill",
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                    performSearch()
                }
                
                // Category pills
                ForEach(ItemCategory.allCases, id: \.self) { category in
                    CategoryPill(
                        title: category.rawValue,
                        icon: category.icon,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                        performSearch()
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 8)
        .background(TexasTechTheme.white)
    }
    
    // MARK: - Main Content
    private var mainContentView: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                // Featured Items Section
                if !itemStore.featuredItems.isEmpty {
                    featuredItemsSection
                }
                
                // Recent Items Grid
                recentItemsSection
            }
            .padding(.top, 16)
        }
        .refreshable {
            itemStore.fetchItems()
        }
    }
    
    private var featuredItemsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("🔥 Featured Items")
                    .font(TexasTechTypography.title3)
                    .fontWeight(.bold)
                    .foregroundColor(TexasTechTheme.black)
                
                Spacer()
                
                Button("View All") {
                    // Handle view all featured items
                }
                .textButton()
                .font(TexasTechTypography.footnote)
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(itemStore.featuredItems.prefix(10)) { item in
                        FeaturedItemCard(item: item)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var recentItemsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("📦 Recent Items")
                    .font(TexasTechTypography.title3)
                    .fontWeight(.bold)
                    .foregroundColor(TexasTechTheme.black)
                
                Spacer()
                
                Text("\(itemStore.items.count) items")
                    .font(TexasTechTypography.caption1)
                    .foregroundColor(TexasTechTheme.mediumGray)
            }
            .padding(.horizontal, 20)
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(itemStore.items) { item in
                    ItemCard(item: item)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Search Results
    private var searchResultsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Search Results")
                    .font(TexasTechTypography.title3)
                    .fontWeight(.bold)
                    .foregroundColor(TexasTechTheme.black)
                
                Spacer()
                
                Text("\(itemStore.searchResults.count) items")
                    .font(TexasTechTypography.caption1)
                    .foregroundColor(TexasTechTheme.mediumGray)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            if itemStore.searchResults.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(TexasTechTheme.mediumGray)
                    
                    Text("No items found")
                        .font(TexasTechTypography.headline)
                        .foregroundColor(TexasTechTheme.black)
                    
                    Text("Try adjusting your search or filters")
                        .font(TexasTechTypography.body)
                        .foregroundColor(TexasTechTheme.mediumGray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(itemStore.searchResults) { item in
                            ItemCard(item: item)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    private func performSearch() {
        let minPriceValue = Double(minPrice) ?? nil
        let maxPriceValue = Double(maxPrice) ?? nil
        
        itemStore.searchItems(
            query: searchText,
            category: selectedCategory,
            minPrice: minPriceValue,
            maxPrice: maxPriceValue,
            condition: selectedCondition
        )
    }
    
    private func applyFilters() {
        performSearch()
        showingFilters = false
    }
}

// MARK: - Category Pill Component

struct CategoryPill: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                
                Text(title)
                    .font(TexasTechTypography.caption1)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                isSelected ? TexasTechTheme.primaryRed : TexasTechTheme.lightGray
            )
            .foregroundColor(
                isSelected ? TexasTechTheme.white : TexasTechTheme.black
            )
            .cornerRadius(20)
        }
    }
}

// MARK: - Featured Item Card

struct FeaturedItemCard: View {
    let item: Item
    
    var body: some View {
        NavigationLink(destination: ItemDetailView(item: item)) {
            VStack(alignment: .leading, spacing: 12) {
                // Image
                ZStack(alignment: .topTrailing) {
                    if let firstImageURL = item.imageURLs.first {
                        WebImage(url: URL(string: firstImageURL))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 200, height: 150)
                            .clipped()
                            .cornerRadius(12)
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(TexasTechTheme.lightGray)
                            .frame(width: 200, height: 150)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 24))
                                    .foregroundColor(TexasTechTheme.mediumGray)
                            )
                    }
                    
                    // Condition badge
                    Text(item.condition.rawValue)
                        .font(TexasTechTypography.caption2)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(item.condition.color).opacity(0.9))
                        .foregroundColor(TexasTechTheme.white)
                        .cornerRadius(8)
                        .padding(8)
                }
                
                // Item details
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(TexasTechTypography.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(TexasTechTheme.black)
                        .lineLimit(2)
                    
                    Text(item.formattedPrice)
                        .font(TexasTechTypography.headline)
                        .fontWeight(.bold)
                        .foregroundColor(TexasTechTheme.primaryRed)
                    
                    HStack {
                        Image(systemName: "location")
                            .font(.system(size: 10))
                        Text(item.location)
                            .font(TexasTechTypography.caption2)
                        
                        Spacer()
                        
                        Text(item.timeAgo)
                            .font(TexasTechTypography.caption2)
                    }
                    .foregroundColor(TexasTechTheme.mediumGray)
                }
            }
        }
        .frame(width: 200)
        .texasTechCard()
        .padding(.bottom, 4)
    }
}

// MARK: - Item Card

struct ItemCard: View {
    let item: Item
    @EnvironmentObject var itemStore: ItemStore
    
    var body: some View {
        NavigationLink(destination: ItemDetailView(item: item)) {
            VStack(alignment: .leading, spacing: 12) {
                // Image
                ZStack(alignment: .topTrailing) {
                    if let firstImageURL = item.imageURLs.first {
                        WebImage(url: URL(string: firstImageURL))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 120)
                            .clipped()
                            .cornerRadius(8)
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(TexasTechTheme.lightGray)
                            .frame(height: 120)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 20))
                                    .foregroundColor(TexasTechTheme.mediumGray)
                            )
                    }
                    
                    // Like button
                    Button(action: {
                        Task {
                            await itemStore.toggleLike(for: item, userID: "currentUser")
                        }
                    }) {
                        Image(systemName: "heart")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(TexasTechTheme.primaryRed)
                            .padding(8)
                            .background(TexasTechTheme.white.opacity(0.9))
                            .clipShape(Circle())
                    }
                    .padding(8)
                }
                
                // Item details
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title)
                        .font(TexasTechTypography.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(TexasTechTheme.black)
                        .lineLimit(2)
                    
                    Text(item.formattedPrice)
                        .font(TexasTechTypography.headline)
                        .fontWeight(.bold)
                        .foregroundColor(TexasTechTheme.primaryRed)
                    
                    HStack {
                        Image(systemName: "location")
                            .font(.system(size: 10))
                        Text(item.location)
                            .font(TexasTechTypography.caption2)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "eye")
                                .font(.system(size: 10))
                            Text("\(item.views)")
                                .font(TexasTechTypography.caption2)
                        }
                    }
                    .foregroundColor(TexasTechTheme.mediumGray)
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
        }
        .texasTechCard()
        .onAppear {
            // Increment view count when item appears
            Task {
                await itemStore.incrementViews(for: item)
            }
        }
    }
}

// MARK: - Filters View

struct FiltersView: View {
    @Binding var minPrice: String
    @Binding var maxPrice: String
    @Binding var selectedCondition: ItemCondition?
    let onApply: () -> Void
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 24) {
                // Price Range
                VStack(alignment: .leading, spacing: 12) {
                    Text("Price Range")
                        .font(TexasTechTypography.headline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 12) {
                        TextField("Min", text: $minPrice)
                            .keyboardType(.decimalPad)
                            .texasTechTextField()
                        
                        Text("to")
                            .foregroundColor(TexasTechTheme.mediumGray)
                        
                        TextField("Max", text: $maxPrice)
                            .keyboardType(.decimalPad)
                            .texasTechTextField()
                    }
                }
                
                // Condition
                VStack(alignment: .leading, spacing: 12) {
                    Text("Condition")
                        .font(TexasTechTypography.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 8) {
                        ForEach(ItemCondition.allCases, id: \.self) { condition in
                            Button(action: {
                                selectedCondition = selectedCondition == condition ? nil : condition
                            }) {
                                HStack {
                                    Text(condition.rawValue)
                                        .font(TexasTechTypography.body)
                                        .foregroundColor(TexasTechTheme.black)
                                    
                                    Spacer()
                                    
                                    if selectedCondition == condition {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(TexasTechTheme.primaryRed)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    selectedCondition == condition
                                        ? TexasTechTheme.primaryRed.opacity(0.1)
                                        : TexasTechTheme.lightGray
                                )
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Apply button
                Button("Apply Filters") {
                    onApply()
                }
                .primaryButton()
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 20)
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Clear") {
                    minPrice = ""
                    maxPrice = ""
                    selectedCondition = nil
                },
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

#Preview {
    MarketplaceView()
        .environmentObject(ItemStore())
        .environmentObject(AuthenticationManager())
        .environmentObject(AIAssistant())
} 