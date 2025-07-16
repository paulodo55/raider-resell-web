import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthenticationManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    init() {
        setupAuthStateListener()
    }
    
    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
    
    private func setupAuthStateListener() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            DispatchQueue.main.async {
                if let user = user {
                    Task {
                        await self?.fetchUserData(uid: user.uid)
                    }
                } else {
                    self?.currentUser = nil
                    self?.isAuthenticated = false
                }
            }
        }
    }
    
    // MARK: - Sign Up
    func signUp(email: String, password: String, firstName: String, lastName: String, studentID: String, graduationYear: Int) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            // Validate Texas Tech email
            guard isValidTexasTechEmail(email) else {
                await MainActor.run {
                    errorMessage = "Please use your Texas Tech email address (@ttu.edu)"
                    isLoading = false
                }
                return
            }
            
            // Create Firebase Auth user
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            
            // Create user document
            let newUser = User(
                email: email,
                firstName: firstName,
                lastName: lastName,
                studentID: studentID,
                graduationYear: graduationYear
            )
            
            try await db.collection(AppConstants.FirebaseCollections.users).document(authResult.user.uid).setData(from: newUser)
            
            await MainActor.run {
                currentUser = newUser
                isAuthenticated = true
                isLoading = false
            }
            
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    // MARK: - Sign In
    func signIn(email: String, password: String) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            await fetchUserData(uid: authResult.user.uid)
            
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    // MARK: - Sign Out
    func signOut() {
        do {
            try Auth.auth().signOut()
            currentUser = nil
            isAuthenticated = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Fetch User Data
    private func fetchUserData(uid: String) async {
        do {
            let document = try await db.collection(AppConstants.FirebaseCollections.users).document(uid).getDocument()
            
            if let userData = try? document.data(as: User.self) {
                await MainActor.run {
                    currentUser = userData
                    isAuthenticated = true
                    isLoading = false
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = AppConstants.ErrorMessages.networkError
                isLoading = false
            }
        }
    }
    
    // MARK: - Update User Profile
    func updateUserProfile(_ updatedUser: User) async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        do {
            try await db.collection(AppConstants.FirebaseCollections.users).document(currentUserId).setData(from: updatedUser, merge: true)
            
            await MainActor.run {
                currentUser = updatedUser
            }
        } catch {
            await MainActor.run {
                errorMessage = AppConstants.ErrorMessages.networkError
            }
        }
    }
    
    // MARK: - Reset Password
    func resetPassword(email: String) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            await MainActor.run {
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    // MARK: - Validation
    private func isValidTexasTechEmail(_ email: String) -> Bool {
        return email.lowercased().hasSuffix(AppConstants.Validation.texasTechEmailSuffix)
    }
    
    func validateStudentID(_ studentID: String) -> Bool {
        // Texas Tech student IDs are typically 8-9 digits
        let regex = "^[0-9]{\(AppConstants.Validation.studentIDMinLength),\(AppConstants.Validation.studentIDMaxLength)}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: studentID)
    }
    
    func validateGraduationYear(_ year: Int) -> Bool {
        let currentYear = Calendar.current.component(.year, from: Date())
        return year >= currentYear && year <= currentYear + 6
    }
    
    // MARK: - User Status Updates
    func updateLastActive() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        do {
            try await db.collection(AppConstants.FirebaseCollections.users).document(currentUserId).updateData([
                "lastActive": FieldValue.serverTimestamp()
            ])
        } catch {
            // Silently fail - this is a background operation
        }
    }
    
    func incrementItemsSold() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        do {
            try await db.collection(AppConstants.FirebaseCollections.users).document(currentUserId).updateData([
                "itemsSold": FieldValue.increment(Int64(1))
            ])
            
            // Update local user
            await MainActor.run {
                currentUser?.itemsSold += 1
            }
        } catch {
            // Silently fail - this is a background operation
        }
    }
    
    func incrementItemsBought() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        do {
            try await db.collection(AppConstants.FirebaseCollections.users).document(currentUserId).updateData([
                "itemsBought": FieldValue.increment(Int64(1))
            ])
            
            // Update local user
            await MainActor.run {
                currentUser?.itemsBought += 1
            }
        } catch {
            // Silently fail - this is a background operation
        }
    }
} 