import SwiftUI
import FirebaseCore

@main
struct RaiderReSeillApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AuthenticationManager())
                .environmentObject(ItemStore())
                .environmentObject(ChatStore())
                .environmentObject(AIAssistant())
        }
    }
} 