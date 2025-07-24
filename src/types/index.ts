export interface User {
  id?: string;
  email: string;
  firstName: string;
  lastName: string;
  studentID: string;
  profileImageURL?: string;
  phoneNumber?: string;
  dormitory?: string;
  graduationYear: number;
  major?: string;
  rating: number;
  totalRatings: number;
  itemsSold: number;
  itemsBought: number;
  isVerified: boolean;
  createdAt: Date;
  lastActive: Date;
}

export enum ItemCategory {
  TEXTBOOKS = 'Textbooks',
  ELECTRONICS = 'Electronics',
  CLOTHING = 'Clothing',
  FURNITURE = 'Furniture',      
  SPORTS = 'Sports & Recreation',
  TICKETS = 'Tickets',
  DORM = 'Dorm Supplies',
  TECH_GEAR = 'Tech Gear',
  OTHER = 'Other'
}

export enum ItemCondition {
  NEW = 'New',
  LIKE_NEW = 'Like New',
  GOOD = 'Good',
  FAIR = 'Fair',
  POOR = 'Poor'
}

export enum ItemStatus {
  ACTIVE = 'active',
  SOLD = 'sold',
  PENDING = 'pending',
  DRAFT = 'draft'
}

export interface Item {
  id?: string;
  title: string;
  description: string;
  price: number;
  originalPrice?: number;
  category: ItemCategory;
  condition: ItemCondition;
  status: ItemStatus;
  sellerID: string;
  sellerName: string;
  imageURLs: string[];
  location: string;
  isNegotiable: boolean;
  views: number;
  likes: number;
  createdAt: Date;
  updatedAt: Date;
  soldAt?: Date;
  buyerID?: string;
  tags: string[];
  aiSuggestedPrice?: number;
  aiMarketAnalysis?: string;
}

export enum SortOption {
  NEWEST = 'newest',
  OLDEST = 'oldest',
  PRICE_LOW_TO_HIGH = 'priceLowToHigh',
  PRICE_HIGH_TO_LOW = 'priceHighToLow',
  MOST_VIEWED = 'mostViewed',
  MOST_LIKED = 'mostLiked'
}

// Chat Types
export enum MessageType {
  TEXT = 'text',
  IMAGE = 'image',
  OFFER = 'offer',
  SYSTEM = 'system'
}

export enum MessageStatus {
  SENT = 'sent',
  DELIVERED = 'delivered',
  READ = 'read'
}

export interface Message {
  id: string;
  chatID: string;
  senderID: string;
  senderName: string;
  type: MessageType;
  content: string;
  imageURL?: string;
  offerID?: string;
  status: MessageStatus;
  createdAt: Date;
  updatedAt: Date;
}

export enum OfferStatus {
  PENDING = 'pending',
  ACCEPTED = 'accepted',
  DECLINED = 'declined',
  COUNTER = 'counter',
  EXPIRED = 'expired'
}

export interface Offer {
  id: string;
  chatID: string;
  itemID: string;
  buyerID: string;
  sellerID: string;
  originalPrice: number;
  offerPrice: number;
  message?: string;
  status: OfferStatus;
  expiresAt: Date;
  createdAt: Date;
  updatedAt: Date;
}

export interface Chat {
  id: string;
  itemID: string;
  itemTitle: string;
  itemImageURL: string;
  buyerID: string;
  buyerName: string;
  sellerID: string;
  sellerName: string;
  lastMessage?: Message;
  unreadCount: number;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
} 