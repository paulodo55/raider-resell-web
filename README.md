# 🏈 Raider ReSell

A mobile marketplace app exclusively for Texas Tech University students, built with SwiftUI and powered by AI.

## 📱 Overview

Raider ReSell is a modern, user-friendly marketplace app designed specifically for Texas Tech University students aged 18-25. The app allows students to buy and sell items within the campus community, featuring real-time chat, AI-powered price analysis, and a beautiful Texas Tech-themed interface.

## ✨ Features

### 🔐 **Authentication & Security**
- Texas Tech email verification (@ttu.edu required)
- Student ID validation
- Secure Firebase Authentication
- Campus-exclusive access

### 🏪 **Marketplace**
- Browse items by category (Textbooks, Electronics, Furniture, etc.)
- Advanced search and filtering
- Featured items section
- Real-time item updates
- Photo uploads for listings
- View counting and favorites system

### 💬 **Chat System**
- Real-time messaging between buyers and sellers
- Image sharing in chats
- Offer system with negotiations
- Unread message indicators
- Chat history management

### 🤖 **AI Integration (Gemini)**
- Smart price analysis and suggestions
- Market research for different categories
- AI chatbot for marketplace guidance
- Item description optimization
- Similar item recommendations
- Trend analysis

### 🎨 **Texas Tech Themed UI**
- Official Texas Tech colors (Red, White, Black)
- Modern, friendly interface
- Responsive design for all iOS devices
- Custom UI components and animations

### 📸 **Camera Integration**
- Take photos directly in the app
- Multiple image uploads per listing
- Image compression and optimization
- Photo gallery selection

### 💰 **Pricing & Offers**
- AI-suggested pricing
- Negotiable price options
- Offer making and counter-offers
- Price change capabilities
- Market value analysis

## 🛠 Tech Stack

- **Frontend**: SwiftUI (iOS 16+)
- **Backend**: Firebase (Auth, Firestore, Storage)
- **AI**: Google Gemini AI
- **Image Loading**: SDWebImageSwiftUI
- **Networking**: Alamofire
- **Chat UI**: Custom SwiftUI components

## 📦 Installation & Setup

### Prerequisites
- Xcode 15.0 or later
- iOS 16.0 or later
- Firebase project
- Google Gemini API key

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/raider-resell.git
   cd raider-resell
   ```

2. **Install Dependencies**
   The project uses Swift Package Manager. Dependencies will be automatically resolved when you open the project in Xcode.

3. **Firebase Setup**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Enable Authentication, Firestore Database, and Storage
   - Download `GoogleService-Info.plist` and add it to your Xcode project
   - Configure Authentication to allow email/password sign-in

4. **Gemini AI Setup**
   - Get a Gemini API key from [Google AI Studio](https://makersuite.google.com)
   - Add your API key to `Info.plist`:
     ```xml
     <key>GEMINI_API_KEY</key>
     <string>YOUR_API_KEY_HERE</string>
     ```

5. **Build and Run**
   - Open `Package.swift` in Xcode (or open the folder directly in Xcode)
   - Select your target device or simulator
   - Press Cmd+R to build and run

## 🗂 Project Structure

```
RaiderReSell/
├── RaiderReSeillApp.swift          # Main app entry point
├── Info.plist                      # App configuration
├── Models/                         # Data models
│   ├── User.swift                  # User model with TTU validation
│   ├── Item.swift                  # Marketplace item model
│   └── Chat.swift                  # Chat and messaging models
├── Managers/                       # Business logic and services
│   ├── AuthenticationManager.swift # User authentication
│   ├── ItemStore.swift            # Item management
│   ├── ChatStore.swift            # Chat functionality
│   └── AIAssistant.swift          # Gemini AI integration
├── Views/                          # SwiftUI views
│   ├── ContentView.swift          # Main app container
│   ├── MarketplaceView.swift      # Main marketplace interface
│   ├── ChatListView.swift         # Chat conversations list
│   ├── CreateItemView.swift       # Item creation with camera
│   └── ProfileView.swift          # User profile and settings
└── Theme/
    └── TexasTechTheme.swift       # Texas Tech styling and colors
```

## 🎯 Usage

### For Sellers
1. **Create Account**: Sign up with your @ttu.edu email address
2. **List Items**: Take photos and create detailed listings
3. **AI Pricing**: Get AI-suggested prices based on market analysis
4. **Manage Chats**: Respond to buyer inquiries and negotiate prices
5. **Track Performance**: View item statistics and seller ratings

### For Buyers
1. **Browse & Search**: Find items by category or search terms
2. **Filter Results**: Use advanced filters for price, condition, location
3. **Contact Sellers**: Start conversations and make offers
4. **AI Assistance**: Get buying advice and market insights
5. **Safe Transactions**: Follow built-in safety guidelines

### AI Features
- **Price Analysis**: Get smart pricing suggestions for your items
- **Market Research**: Understand demand and pricing trends
- **Chatbot Help**: Ask questions about marketplace best practices
- **Safety Tips**: Receive AI-generated safety recommendations

## 🔒 Security & Privacy

- All user data is encrypted and stored securely in Firebase
- Texas Tech email verification ensures campus-only access
- Chat messages are private between users
- Personal information is protected and not shared with third parties
- Secure payment recommendations for transactions

## 🤝 Contributing

We welcome contributions from the Texas Tech community! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🎓 About Texas Tech

This app is created for the Texas Tech University community. Wreck 'Em Tech! 🔴⚫

## 📞 Support

For support, email support@raiderresell.com or create an issue in this repository.

## 🚀 Future Features

- [ ] Push notifications for new messages
- [ ] In-app payment integration
- [ ] Rating and review system
- [ ] Item condition verification
- [ ] Campus pickup locations
- [ ] Seasonal marketplace events
- [ ] Social features and user profiles

---

**Made with ❤️ for the Texas Tech Red Raiders community** 