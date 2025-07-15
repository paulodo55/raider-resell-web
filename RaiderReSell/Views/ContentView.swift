import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var chatStore: ChatStore
    @EnvironmentObject var aiAssistant: AIAssistant
    
    @State private var selectedTab = 0
    @State private var showingProfile = false
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                mainTabView
            } else {
                AuthenticationView()
            }
        }
        .preferredColorScheme(.light)
    }
    
    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            // Marketplace Tab
            MarketplaceView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "storefront.fill" : "storefront")
                    Text("Resell Market")
                }
                .tag(0)
            
            // Chat Tab
            ChatListView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "message.fill" : "message")
                    Text("Chats")
                }
                .badge(chatStore.getUnreadMessagesCount() > 0 ? chatStore.getUnreadMessagesCount() : nil)
                .tag(1)
            
            // Sell Tab (Camera/Add Item)
            CreateItemView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Sell")
                }
                .tag(2)
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "person.fill" : "person")
                    Text("Profile")
                }
                .tag(3)
        }
        .accentColor(TexasTechTheme.primaryRed)
        .onAppear {
            setupTabBarAppearance()
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white
        
        // Selected tab item color
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(TexasTechTheme.primaryRed)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(TexasTechTheme.primaryRed)
        ]
        
        // Unselected tab item color
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(TexasTechTheme.mediumGray)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(TexasTechTheme.mediumGray)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - Authentication View

struct AuthenticationView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var isShowingSignUp = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with logo and branding
                headerSection
                
                // Main content
                if isShowingSignUp {
                    SignUpView(isShowingSignUp: $isShowingSignUp)
                } else {
                    SignInView(isShowingSignUp: $isShowingSignUp)
                }
                
                Spacer()
            }
            .background(TexasTechTheme.backgroundGradient)
            .navigationBarHidden(true)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Texas Tech themed header
            ZStack {
                TexasTechTheme.primaryGradient
                    .frame(height: 200)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 0)
                            .path(in: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200))
                    )
                
                VStack(spacing: 12) {
                    // App logo/icon
                    Image(systemName: "building.columns.fill")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(TexasTechTheme.white)
                    
                    Text("Raider ReSell")
                        .font(TexasTechTypography.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(TexasTechTheme.white)
                    
                    Text("Texas Tech University Marketplace")
                        .font(TexasTechTypography.subheadline)
                        .foregroundColor(TexasTechTheme.white.opacity(0.9))
                }
                .padding(.top, 50)
            }
        }
    }
}

// MARK: - Sign In View

struct SignInView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Binding var isShowingSignUp: Bool
    
    @State private var email = ""
    @State private var password = ""
    @State private var showingForgotPassword = false
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Welcome Back")
                    .font(TexasTechTypography.title1)
                    .fontWeight(.bold)
                    .foregroundColor(TexasTechTheme.black)
                
                Text("Sign in to your Raider ReSell account")
                    .font(TexasTechTypography.body)
                    .foregroundColor(TexasTechTheme.mediumGray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            
            VStack(spacing: 16) {
                // Email field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(TexasTechTypography.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(TexasTechTheme.black)
                    
                    TextField("your.email@ttu.edu", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .texasTechTextField()
                }
                
                // Password field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(TexasTechTypography.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(TexasTechTheme.black)
                    
                    SecureField("Enter your password", text: $password)
                        .texasTechTextField()
                }
                
                // Forgot password
                HStack {
                    Spacer()
                    Button("Forgot Password?") {
                        showingForgotPassword = true
                    }
                    .font(TexasTechTypography.footnote)
                    .textButton()
                }
            }
            .padding(.horizontal, 24)
            
            // Sign in button
            VStack(spacing: 12) {
                Button("Sign In") {
                    Task {
                        await authManager.signIn(email: email, password: password)
                    }
                }
                .primaryButton()
                .disabled(email.isEmpty || password.isEmpty || authManager.isLoading)
                .padding(.horizontal, 24)
                
                // Sign up option
                HStack {
                    Text("Don't have an account?")
                        .font(TexasTechTypography.footnote)
                        .foregroundColor(TexasTechTheme.mediumGray)
                    
                    Button("Sign Up") {
                        isShowingSignUp = true
                    }
                    .font(TexasTechTypography.footnote)
                    .textButton()
                }
            }
            
            // Error message
            if let errorMessage = authManager.errorMessage {
                Text(errorMessage)
                    .font(TexasTechTypography.footnote)
                    .foregroundColor(TexasTechTheme.error)
                    .padding(.horizontal, 24)
                    .multilineTextAlignment(.center)
            }
            
            // Loading indicator
            if authManager.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: TexasTechTheme.primaryRed))
            }
        }
        .padding(.top, 32)
        .alert("Reset Password", isPresented: $showingForgotPassword) {
            TextField("Email", text: $email)
            Button("Send Reset Email") {
                Task {
                    await authManager.resetPassword(email: email)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter your Texas Tech email address to receive a password reset link.")
        }
    }
}

// MARK: - Sign Up View

struct SignUpView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Binding var isShowingSignUp: Bool
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var studentID = ""
    @State private var graduationYear = Calendar.current.component(.year, from: Date()) + 4
    
    private let graduationYears = Array(2024...2030)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Button(action: {
                            isShowingSignUp = false
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(TexasTechTheme.primaryRed)
                        }
                        
                        Spacer()
                    }
                    
                    Text("Join Raider ReSell")
                        .font(TexasTechTypography.title1)
                        .fontWeight(.bold)
                        .foregroundColor(TexasTechTheme.black)
                    
                    Text("Create your account to start buying and selling")
                        .font(TexasTechTypography.body)
                        .foregroundColor(TexasTechTheme.mediumGray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                
                VStack(spacing: 16) {
                    // Name fields
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("First Name")
                                .font(TexasTechTypography.caption1)
                                .fontWeight(.medium)
                                .foregroundColor(TexasTechTheme.black)
                            
                            TextField("First", text: $firstName)
                                .texasTechTextField()
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Last Name")
                                .font(TexasTechTypography.caption1)
                                .fontWeight(.medium)
                                .foregroundColor(TexasTechTheme.black)
                            
                            TextField("Last", text: $lastName)
                                .texasTechTextField()
                        }
                    }
                    
                    // Email field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Texas Tech Email")
                            .font(TexasTechTypography.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(TexasTechTheme.black)
                        
                        TextField("your.email@ttu.edu", text: $email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .texasTechTextField()
                    }
                    
                    // Student ID
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Student ID")
                            .font(TexasTechTypography.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(TexasTechTheme.black)
                        
                        TextField("12345678", text: $studentID)
                            .keyboardType(.numberPad)
                            .texasTechTextField()
                    }
                    
                    // Graduation Year
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Expected Graduation Year")
                            .font(TexasTechTypography.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(TexasTechTheme.black)
                        
                        Picker("Graduation Year", selection: $graduationYear) {
                            ForEach(graduationYears, id: \.self) { year in
                                Text(String(year)).tag(year)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(TexasTechTheme.lightGray)
                        .cornerRadius(8)
                    }
                    
                    // Password fields
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(TexasTechTypography.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(TexasTechTheme.black)
                        
                        SecureField("Enter password", text: $password)
                            .texasTechTextField()
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirm Password")
                            .font(TexasTechTypography.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(TexasTechTheme.black)
                        
                        SecureField("Confirm password", text: $confirmPassword)
                            .texasTechTextField()
                    }
                }
                .padding(.horizontal, 24)
                
                // Sign up button
                Button("Create Account") {
                    Task {
                        await authManager.signUp(
                            email: email,
                            password: password,
                            firstName: firstName,
                            lastName: lastName,
                            studentID: studentID,
                            graduationYear: graduationYear
                        )
                    }
                }
                .primaryButton()
                .disabled(!isFormValid || authManager.isLoading)
                .padding(.horizontal, 24)
                
                // Error message
                if let errorMessage = authManager.errorMessage {
                    Text(errorMessage)
                        .font(TexasTechTypography.footnote)
                        .foregroundColor(TexasTechTheme.error)
                        .padding(.horizontal, 24)
                        .multilineTextAlignment(.center)
                }
                
                // Loading indicator
                if authManager.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: TexasTechTheme.primaryRed))
                }
            }
            .padding(.top, 32)
            .padding(.bottom, 50)
        }
    }
    
    private var isFormValid: Bool {
        return !firstName.isEmpty &&
               !lastName.isEmpty &&
               !email.isEmpty &&
               email.hasSuffix("@ttu.edu") &&
               authManager.validateStudentID(studentID) &&
               password.count >= 6 &&
               password == confirmPassword
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationManager())
        .environmentObject(ItemStore())
        .environmentObject(ChatStore())
        .environmentObject(AIAssistant())
} 