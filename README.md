# 🏈 Raider ReSell - Web Application

A modern web marketplace exclusively for Texas Tech University students, built with Next.js and powered by AI.

## 📱 Overview

Raider ReSell is a user-friendly marketplace web application designed specifically for Texas Tech University students. The app allows students to buy and sell items within the campus community, featuring real-time chat, AI-powered price analysis, and a beautiful Texas Tech-themed interface.

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

### 💬 **Chat System** (Coming Soon)
- Real-time messaging between buyers and sellers
- Image sharing in chats
- Offer system with negotiations
- Unread message indicators
- Chat history management

### 🤖 **AI Integration** (Coming Soon)
- Smart price analysis and suggestions
- Market research for different categories
- AI chatbot for marketplace guidance
- Item description optimization
- Similar item recommendations
- Trend analysis

### 🎨 **Texas Tech Themed UI**
- Official Texas Tech colors (Red, White, Black)
- Modern, responsive design
- Custom UI components and animations
- Mobile-first design approach

### 📸 **Camera Integration** (Coming Soon)
- Take photos directly in the app
- Multiple image uploads per listing
- Image compression and optimization
- Photo gallery selection

### 💰 **Pricing & Offers** (Coming Soon)
- AI-suggested pricing
- Negotiable price options
- Offer making and counter-offers
- Price change capabilities
- Market value analysis

## 🛠 Tech Stack

- **Frontend**: Next.js 14 with TypeScript
- **Styling**: Tailwind CSS
- **Backend**: Firebase (Auth, Firestore, Storage)
- **AI**: Google Gemini AI (Coming Soon)
- **Deployment**: Vercel
- **State Management**: React Context
- **UI Components**: Custom component library

## 📦 Installation & Setup

### Prerequisites
- Node.js 18.0 or later
- npm or yarn
- Firebase project
- Google Gemini API key (optional)

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/raider-resell-website.git
   cd raider-resell-website
   ```

2. **Install Dependencies**
   ```bash
   npm install
   # or
   yarn install
   ```

3. **Firebase Setup**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Enable Authentication, Firestore Database, and Storage
   - Copy your Firebase configuration
   - Update `.env.local` with your Firebase credentials

4. **Environment Variables**
   Create a `.env.local` file in the root directory:
   ```env
   NEXT_PUBLIC_FIREBASE_API_KEY=your_api_key_here
   NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
   NEXT_PUBLIC_FIREBASE_PROJECT_ID=your_project_id
   NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=your_project.appspot.com
   NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
   NEXT_PUBLIC_FIREBASE_APP_ID=your_app_id
   GEMINI_API_KEY=your_gemini_api_key_here
   ```

5. **Build and Run**
   ```bash
   # Development
   npm run dev
   # or
   yarn dev

   # Production
   npm run build && npm run start
   # or
   yarn build && yarn start
   ```

6. **Deploy to Vercel**
   ```bash
   # Install Vercel CLI
   npm i -g vercel

   # Deploy
   vercel

   # Or connect your GitHub repository to Vercel for automatic deployments
   ```

## 🗂 Project Structure

```
raider-resell-website/
├── src/
│   ├── app/                    # Next.js 14 App Router
│   │   ├── globals.css         # Global styles
│   │   ├── layout.tsx          # Root layout
│   │   └── page.tsx           # Home page
│   ├── components/            # React components
│   │   ├── ui/                # Reusable UI components
│   │   ├── auth/              # Authentication components
│   │   └── marketplace/       # Marketplace components
│   ├── hooks/                 # Custom React hooks
│   │   └── useAuth.ts         # Authentication hook
│   ├── lib/                   # Utility libraries
│   │   └── firebase.ts        # Firebase configuration
│   ├── types/                 # TypeScript type definitions
│   │   └── index.ts           # Main type definitions
│   └── utils/                 # Utility functions
│       └── constants.ts       # App constants
├── public/                    # Static assets
├── package.json              # Dependencies and scripts
├── tailwind.config.ts        # Tailwind CSS configuration
├── tsconfig.json            # TypeScript configuration
├── next.config.js           # Next.js configuration
└── vercel.json              # Vercel deployment configuration
```

## 🎯 Usage

### For Sellers
1. **Create Account**: Sign up with your @ttu.edu email address
2. **List Items**: Create detailed listings with photos (Coming Soon)
3. **AI Pricing**: Get AI-suggested prices based on market analysis (Coming Soon)
4. **Manage Chats**: Respond to buyer inquiries and negotiate prices (Coming Soon)
5. **Track Performance**: View item statistics and seller ratings

### For Buyers
1. **Browse & Search**: Find items by category or search terms
2. **Filter Results**: Use advanced filters for price, condition, location (Coming Soon)
3. **Contact Sellers**: Start conversations and make offers (Coming Soon)
4. **AI Assistance**: Get buying advice and market insights (Coming Soon)
5. **Safe Transactions**: Follow built-in safety guidelines

### Current Features (MVP)
- **Authentication**: Sign up and sign in with Texas Tech email
- **Marketplace Browsing**: View items with category filtering
- **Search**: Find items by title and description
- **Responsive Design**: Works on desktop and mobile devices
- **User Profiles**: View basic profile information

## 🚀 Deployment

### Vercel (Recommended)

1. **Connect Repository**
   - Go to [Vercel Dashboard](https://vercel.com/dashboard)
   - Import your GitHub repository
   - Configure environment variables in Vercel dashboard

2. **Automatic Deployments**
   - Push to main branch triggers automatic deployment
   - Preview deployments for pull requests

3. **Custom Domain** (Optional)
   - Add your custom domain in Vercel dashboard
   - Configure DNS settings as instructed

### Other Platforms

The application can also be deployed on:
- **Netlify**: Static hosting with serverless functions
- **AWS Amplify**: Full-stack hosting with CI/CD
- **Railway**: Simple deployment with database hosting

## 🔒 Security & Privacy

- All user data is encrypted and stored securely in Firebase
- Texas Tech email verification ensures campus-only access
- Chat messages are private between users (Coming Soon)
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

For support, create an issue in this repository or contact the development team.

## 🚧 Roadmap

### Phase 1 (Current - MVP)
- [x] User authentication with Texas Tech email
- [x] Basic marketplace browsing
- [x] Item search and filtering
- [x] Responsive design
- [x] User profiles

### Phase 2 (Coming Soon)
- [ ] Item creation and management
- [ ] Real-time chat system
- [ ] Image upload and management
- [ ] Advanced filtering options
- [ ] Push notifications

### Phase 3 (Future)
- [ ] AI price analysis and suggestions
- [ ] In-app payment integration
- [ ] Rating and review system
- [ ] Item condition verification
- [ ] Campus pickup locations
- [ ] Mobile app (React Native)

---

**Made with ❤️ for the Texas Tech Red Raiders community** 