import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var chatStore: ChatStore
    
    @State private var showingEditProfile = false
    @State private var showingSettings = false
    @State private var showingMyListings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    profileHeaderSection
                    
                    // Stats Section
                    statsSection
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Menu Items
                    menuItemsSection
                    
                    // Sign Out Button
                    signOutSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .background(TexasTechTheme.lightGray.opacity(0.3))
            .navigationBarHidden(true)
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingMyListings) {
                MyListingsView()
            }
        }
    }
    
    // MARK: - Profile Header Section
    private var profileHeaderSection: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Profile")
                    .font(TexasTechTypography.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(TexasTechTheme.black)
                
                Spacer()
                
                Button(action: { showingSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                        .foregroundColor(TexasTechTheme.primaryRed)
                }
            }
            
            VStack(spacing: 16) {
                // Profile Picture
                ZStack {
                    Circle()
                        .fill(TexasTechTheme.primaryGradient)
                        .frame(width: 100, height: 100)
                    
                    if let profileImageURL = authManager.currentUser?.profileImageURL {
                        AsyncImage(url: URL(string: profileImageURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                    } else {
                        Text(authManager.currentUser?.firstName.prefix(1) ?? "R")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(TexasTechTheme.white)
                    }
                    
                    // Edit button
                    Button(action: { showingEditProfile = true }) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(TexasTechTheme.white)
                            .padding(8)
                            .background(TexasTechTheme.primaryRed)
                            .clipShape(Circle())
                    }
                    .offset(x: 35, y: 35)
                }
                
                // User Info
                VStack(spacing: 8) {
                    Text(authManager.currentUser?.fullName ?? "Raider")
                        .font(TexasTechTypography.title2)
                        .fontWeight(.bold)
                        .foregroundColor(TexasTechTheme.black)
                    
                    VStack(spacing: 4) {
                        Text(authManager.currentUser?.email ?? "")
                            .font(TexasTechTypography.subheadline)
                            .foregroundColor(TexasTechTheme.mediumGray)
                        
                        HStack(spacing: 16) {
                            Label {
                                Text("Class of \(authManager.currentUser?.graduationYear ?? 2024)")
                                    .font(TexasTechTypography.caption1)
                                    .foregroundColor(TexasTechTheme.mediumGray)
                            } icon: {
                                Image(systemName: "graduationcap.fill")
                                    .foregroundColor(TexasTechTheme.primaryRed)
                                    .font(.caption)
                            }
                            
                            if let dormitory = authManager.currentUser?.dormitory {
                                Label {
                                    Text(dormitory)
                                        .font(TexasTechTypography.caption1)
                                        .foregroundColor(TexasTechTheme.mediumGray)
                                } icon: {
                                    Image(systemName: "house.fill")
                                        .foregroundColor(TexasTechTheme.primaryRed)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    
                    // Rating
                    HStack(spacing: 4) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < Int(authManager.currentUser?.rating ?? 0) ? "star.fill" : "star")
                                .foregroundColor(TexasTechTheme.gold)
                                .font(.caption)
                        }
                        
                        Text(authManager.currentUser?.displayRating ?? "No ratings yet")
                            .font(TexasTechTypography.caption1)
                            .foregroundColor(TexasTechTheme.mediumGray)
                    }
                    .padding(.top, 4)
                    
                    // Verification Badge
                    if authManager.currentUser?.isVerified == true {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(TexasTechTheme.success)
                            Text("Verified Student")
                                .font(TexasTechTypography.caption1)
                                .foregroundColor(TexasTechTheme.success)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(TexasTechTheme.success.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
            }
        }
        .padding()
        .texasTechCard()
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Items Sold",
                value: "\(authManager.currentUser?.itemsSold ?? 0)",
                icon: "cart.fill",
                color: TexasTechTheme.success
            )
            
            StatCard(
                title: "Items Bought",
                value: "\(authManager.currentUser?.itemsBought ?? 0)",
                icon: "bag.fill",
                color: TexasTechTheme.primaryRed
            )
            
            StatCard(
                title: "Active Listings",
                value: "\(itemStore.userItems.count)",
                icon: "tag.fill",
                color: TexasTechTheme.gold
            )
        }
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(TexasTechTypography.headline)
                .fontWeight(.semibold)
                .foregroundColor(TexasTechTheme.black)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ActionButton(
                    title: "My Listings",
                    subtitle: "\(itemStore.userItems.count) active",
                    icon: "list.bullet.rectangle.portrait.fill",
                    color: TexasTechTheme.primaryRed
                ) {
                    showingMyListings = true
                }
                
                ActionButton(
                    title: "Saved Items",
                    subtitle: "View favorites",
                    icon: "heart.fill",
                    color: TexasTechTheme.gold
                ) {
                    // Handle saved items
                }
                
                ActionButton(
                    title: "Purchase History",
                    subtitle: "Past orders",
                    icon: "clock.arrow.circlepath",
                    color: TexasTechTheme.success
                ) {
                    // Handle purchase history
                }
                
                ActionButton(
                    title: "Share Profile",
                    subtitle: "Invite friends",
                    icon: "square.and.arrow.up.fill",
                    color: TexasTechTheme.mediumGray
                ) {
                    // Handle share profile
                }
            }
        }
        .padding()
        .texasTechCard()
    }
    
    // MARK: - Menu Items Section
    private var menuItemsSection: some View {
        VStack(spacing: 12) {
            MenuRowItem(
                title: "Edit Profile",
                subtitle: "Update your information",
                icon: "person.crop.circle.fill",
                action: { showingEditProfile = true }
            )
            
            MenuRowItem(
                title: "Payment Methods",
                subtitle: "Manage payment options",
                icon: "creditcard.fill",
                action: { /* Handle payment methods */ }
            )
            
            MenuRowItem(
                title: "Notifications",
                subtitle: "Manage your preferences",
                icon: "bell.fill",
                action: { /* Handle notifications */ }
            )
            
            MenuRowItem(
                title: "Help & Support",
                subtitle: "Get help with the app",
                icon: "questionmark.circle.fill",
                action: { /* Handle help */ }
            )
            
            MenuRowItem(
                title: "Privacy & Safety",
                subtitle: "Security settings",
                icon: "shield.fill",
                action: { /* Handle privacy */ }
            )
            
            MenuRowItem(
                title: "About Raider ReSell",
                subtitle: "App info and version",
                icon: "info.circle.fill",
                action: { /* Handle about */ }
            )
        }
        .texasTechCard()
    }
    
    // MARK: - Sign Out Section
    private var signOutSection: some View {
        Button("Sign Out") {
            authManager.signOut()
        }
        .font(TexasTechTypography.headline)
        .fontWeight(.semibold)
        .foregroundColor(TexasTechTheme.error)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(TexasTechTheme.white)
        .cornerRadius(12)
        .shadow(color: TexasTechTheme.cardShadow, radius: 2, x: 0, y: 1)
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(TexasTechTypography.title3)
                .fontWeight(.bold)
                .foregroundColor(TexasTechTheme.black)
            
            Text(title)
                .font(TexasTechTypography.caption1)
                .foregroundColor(TexasTechTheme.mediumGray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .texasTechCard()
    }
}

struct ActionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(TexasTechTypography.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(TexasTechTheme.black)
                    
                    Text(subtitle)
                        .font(TexasTechTypography.caption2)
                        .foregroundColor(TexasTechTheme.mediumGray)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .texasTechCard()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MenuRowItem: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(TexasTechTheme.primaryRed)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(TexasTechTypography.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(TexasTechTheme.black)
                    
                    Text(subtitle)
                        .font(TexasTechTypography.caption1)
                        .foregroundColor(TexasTechTheme.mediumGray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(TexasTechTheme.mediumGray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Supporting Modal Views

struct EditProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phoneNumber = ""
    @State private var dormitory = ""
    @State private var major = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Edit Profile")
                    .font(TexasTechTypography.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                VStack(spacing: 16) {
                    TextField("First Name", text: $firstName)
                        .texasTechTextField()
                    
                    TextField("Last Name", text: $lastName)
                        .texasTechTextField()
                    
                    TextField("Phone Number", text: $phoneNumber)
                        .texasTechTextField()
                    
                    TextField("Dormitory/Housing", text: $dormitory)
                        .texasTechTextField()
                    
                    TextField("Major", text: $major)
                        .texasTechTextField()
                }
                
                Spacer()
                
                Button("Save Changes") {
                    // Save profile changes
                    presentationMode.wrappedValue.dismiss()
                }
                .primaryButton()
            }
            .padding()
            .navigationBarItems(
                trailing: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .onAppear {
            if let user = authManager.currentUser {
                firstName = user.firstName
                lastName = user.lastName
                phoneNumber = user.phoneNumber ?? ""
                dormitory = user.dormitory ?? ""
                major = user.major ?? ""
            }
        }
    }
}

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Settings")
                    .font(TexasTechTypography.title2)
                    .fontWeight(.bold)
                    .padding()
                
                Text("Settings coming soon...")
                    .font(TexasTechTypography.body)
                    .foregroundColor(TexasTechTheme.mediumGray)
                
                Spacer()
            }
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct MyListingsView: View {
    @EnvironmentObject var itemStore: ItemStore
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Text("My Listings")
                    .font(TexasTechTypography.title2)
                    .fontWeight(.bold)
                    .padding()
                
                if itemStore.userItems.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "tray")
                            .font(.system(size: 48))
                            .foregroundColor(TexasTechTheme.mediumGray)
                        
                        Text("No active listings")
                            .font(TexasTechTypography.headline)
                            .foregroundColor(TexasTechTheme.black)
                        
                        Text("Start selling items to see them here")
                            .font(TexasTechTypography.body)
                            .foregroundColor(TexasTechTheme.mediumGray)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(itemStore.userItems) { item in
                                // Item row view
                                HStack {
                                    AsyncImage(url: URL(string: item.imageURLs.first ?? "")) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Rectangle()
                                            .fill(TexasTechTheme.lightGray)
                                    }
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(8)
                                    
                                    VStack(alignment: .leading) {
                                        Text(item.title)
                                            .font(TexasTechTypography.subheadline)
                                            .fontWeight(.medium)
                                        
                                        Text(item.formattedPrice)
                                            .font(TexasTechTypography.headline)
                                            .foregroundColor(TexasTechTheme.primaryRed)
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                                .texasTechCard()
                            }
                        }
                        .padding()
                    }
                }
                
                Spacer()
            }
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticationManager())
        .environmentObject(ItemStore())
        .environmentObject(ChatStore())
} 