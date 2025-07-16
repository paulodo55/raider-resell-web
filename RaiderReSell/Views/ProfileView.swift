import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var chatStore: ChatStore
    
    @State private var showingEditProfile = false
    @State private var showingSettings = false
    @State private var showingMyListings = false
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Section
                    VStack(spacing: 16) {
                        // Profile Image
                        AsyncImage(url: URL(string: authManager.currentUser?.profileImageURL ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Circle()
                                .fill(TexasTechTheme.lightGray)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(TexasTechTheme.mediumGray)
                                )
                        }
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        
                        // User Info
                        VStack(spacing: 8) {
                            Text(authManager.currentUser?.fullName ?? "Unknown User")
                                .font(TexasTechTypography.title2)
                                .fontWeight(.bold)
                                .foregroundColor(TexasTechTheme.black)
                            
                            Text(authManager.currentUser?.email ?? "")
                                .font(TexasTechTypography.subheadline)
                                .foregroundColor(TexasTechTheme.mediumGray)
                            
                            Text("Class of \(authManager.currentUser?.graduationYear ?? 2024)")
                                .font(TexasTechTypography.caption1)
                                .foregroundColor(TexasTechTheme.primaryRed)
                        }
                        
                        // Stats
                        HStack(spacing: 16) {
                            StatCard(
                                title: "Items\nSold",
                                value: "\(authManager.currentUser?.itemsSold ?? 0)",
                                icon: "bag.fill",
                                color: TexasTechTheme.primaryRed
                            )
                            
                            StatCard(
                                title: "Items\nBought",
                                value: "\(authManager.currentUser?.itemsBought ?? 0)",
                                icon: "cart.fill",
                                color: TexasTechTheme.primaryRed
                            )
                            
                            StatCard(
                                title: "Rating",
                                value: String(format: "%.1f", authManager.currentUser?.rating ?? 0.0),
                                icon: "star.fill",
                                color: TexasTechTheme.gold
                            )
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            ActionButton(
                                title: "Edit Profile",
                                subtitle: "Update your info",
                                icon: "person.crop.circle",
                                color: TexasTechTheme.primaryRed
                            ) {
                                showingEditProfile = true
                            }
                            
                            ActionButton(
                                title: "My Listings",
                                subtitle: "View your items",
                                icon: "list.bullet.rectangle",
                                color: TexasTechTheme.primaryRed
                            ) {
                                showingMyListings = true
                            }
                        }
                        
                        Button(action: shareProfile) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.title3)
                                    .foregroundColor(TexasTechTheme.primaryRed)
                                
                                Text("Share Profile")
                                    .font(TexasTechTypography.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(TexasTechTheme.black)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(TexasTechTheme.mediumGray)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .texasTechCard()
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal)
                    
                    // Menu Options
                    VStack(spacing: 0) {
                        MenuRowItem(
                            title: "Settings",
                            subtitle: "Notifications, privacy, and more",
                            icon: "gear"
                        ) {
                            showingSettings = true
                        }
                        
                        Divider()
                        
                        MenuRowItem(
                            title: "Help & Support",
                            subtitle: "Get help with the app",
                            icon: "questionmark.circle"
                        ) {
                            // Open help
                        }
                        
                        Divider()
                        
                        MenuRowItem(
                            title: "About",
                            subtitle: "App version and info",
                            icon: "info.circle"
                        ) {
                            // Open about
                        }
                        
                        Divider()
                        
                        Button(action: {
                            showingLogoutAlert = true
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: "arrow.right.square")
                                    .font(.title3)
                                    .foregroundColor(TexasTechTheme.error)
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Log Out")
                                        .font(TexasTechTypography.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(TexasTechTheme.error)
                                    
                                    Text("Sign out of your account")
                                        .font(TexasTechTypography.caption1)
                                        .foregroundColor(TexasTechTheme.mediumGray)
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .texasTechCard()
                    .padding(.horizontal)
                }
                .padding(.bottom, 100)
            }
            .navigationBarHidden(true)
            .background(TexasTechTheme.lightGray.opacity(0.3))
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingMyListings) {
            MyListingsView()
        }
        .alert("Log Out", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Log Out", role: .destructive) {
                authManager.signOut()
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
    }
    
    // MARK: - Profile Actions
    
    private func shareProfile() {
        let shareText = "Check out \(self.authManager.currentUser?.fullName ?? "this user")'s profile on Raider ReSell - Texas Tech's marketplace app!"
        let shareURL = URL(string: "https://raiderresell.com/profile/\(self.authManager.currentUser?.id ?? "")")
        
        let activityVC = UIActivityViewController(
            activityItems: [shareText, shareURL].compactMap { $0 },
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
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