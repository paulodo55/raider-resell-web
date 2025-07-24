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

export const APP_CONSTANTS = {
  // Validation
  VALIDATION: {
    STUDENT_ID_MIN_LENGTH: 8,
    STUDENT_ID_MAX_LENGTH: 9,
    PASSWORD_MIN_LENGTH: 6,
    TEXAS_TECH_EMAIL_SUFFIX: '@ttu.edu',
    MAX_TITLE_LENGTH: 100,
    MAX_DESCRIPTION_LENGTH: 1000
  },

  // Campus Locations
  CAMPUS_LOCATIONS: {
    DORMITORIES: [
      'Chitwood/Weymouth',
      'Coleman Hall',
      'Hulen/Clement',
      'Knapp Hall',
      'Murdough Hall',
      'Stangel/Murdough',
      'Wall/Gates',
      'Other Residence Hall'
    ],
    CAMPUS_BUILDINGS: [
      'Student Union Building',
      'Library',
      'Recreation Center',
      'Engineering Building',
      'Business Building',
      'Rawls College of Business',
      'Other Campus Building'
    ]
  },

  // Error Messages
  ERROR_MESSAGES: {
    AUTHENTICATION_ERROR: 'Authentication failed. Please check your credentials.',
    INVALID_EMAIL: 'Please enter a valid Texas Tech email address.',
    INVALID_STUDENT_ID: 'Please enter a valid 8-9 digit student ID.',
    PASSWORD_TOO_SHORT: 'Password must be at least 6 characters long.',
    PASSWORD_MISMATCH: 'Passwords do not match.'
  },

  // Success Messages
  SUCCESS_MESSAGES: {
    PROFILE_UPDATED: 'Profile updated successfully!',
    ACCOUNT_CREATED: 'Account created successfully!',
    PASSWORD_RESET: 'Password reset email sent!'
  }
};

export const CATEGORY_ICONS: Record<string, string> = {
  'Textbooks': '📚',
  'Electronics': '📱',
  'Clothing': '👕',
  'Furniture': '🛏️',
  'Sports & Recreation': '⚽',
  'Tickets': '🎫',
  'Dorm Supplies': '🏠',
  'Tech Gear': '💻',
  'Other': '📦'
};

export const CONDITION_COLORS: Record<string, string> = {
  'New': 'bg-green-500',
  'Like New': 'bg-blue-500',
  'Good': 'bg-orange-500',
  'Fair': 'bg-yellow-500',
  'Poor': 'bg-red-500'
}; 