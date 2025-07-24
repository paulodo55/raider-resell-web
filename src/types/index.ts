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
  locationPreferences?: LocationPreferences;
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

// Location Types
export enum LocationType {
  ON_CAMPUS = 'on_campus',
  OFF_CAMPUS = 'off_campus'
}

export enum DistanceRange {
  UNDER_5 = 'under_5',
  RANGE_5_10 = '5_to_10',
  RANGE_10_15 = '10_to_15', 
  RANGE_15_20 = '15_to_20',
  RANGE_20_25 = '20_to_25',
  OVER_25 = 'over_25'
}

export interface LocationInfo {
  locationType: LocationType;
  specificLocation: string; // e.g., "Knapp Hall" or "4th Street Apartments"
  distanceRange?: DistanceRange; // Only for off-campus locations
  exactDistance?: number; // In miles, for precise calculations
  address?: string; // Full address for off-campus locations
}

export interface LocationPreferences {
  maxDistance: number; // Maximum distance in miles
  preferOnCampus: boolean;
  acceptedDistanceRanges: DistanceRange[];
  excludedAreas?: string[]; // Areas user wants to avoid
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
  location: LocationInfo; // Updated to use LocationInfo instead of string
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
  MOST_LIKED = 'mostLiked',
  CLOSEST_DISTANCE = 'closestDistance'
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