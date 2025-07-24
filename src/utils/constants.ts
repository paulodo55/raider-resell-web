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

  // Off-Campus Areas
  OFF_CAMPUS_AREAS: {
    NEARBY_COMPLEXES: [
      'University Courtyard',
      'Sterling University Trails',
      'U Centre on Turner',
      'Campus Lodge',
      'Raider\'s Pass',
      'The Edge',
      'Gateway at Lubbock',
      'University Pointe'
    ],
    NEIGHBORHOODS: [
      'Tech Terrace',
      'Overton',
      'Maxey Park',
      'Heart of Lubbock',
      'Depot District',
      'South Lubbock',
      'West Lubbock',
      'Other Area'
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
    PASSWORD_RESET: 'Password reset email sent!',
    LOCATION_PREFERENCES_UPDATED: 'Location preferences updated successfully!'
  }
};

export const CONDITION_COLORS: Record<string, string> = {
  'New': 'bg-green-500',
  'Like New': 'bg-blue-500',
  'Good': 'bg-orange-500',
  'Fair': 'bg-yellow-500',
  'Poor': 'bg-red-500'
};

// Location Constants
export const DISTANCE_RANGE_LABELS: Record<string, string> = {
  'under_5': 'Under 5 miles',
  '5_to_10': '5-10 miles',
  '10_to_15': '10-15 miles',
  '15_to_20': '15-20 miles',
  '20_to_25': '20-25 miles',
  'over_25': 'Over 25 miles'
};

export const LOCATION_TYPE_LABELS: Record<string, string> = {
  'on_campus': 'On Campus',
  'off_campus': 'Off Campus'
};

export const TRANSPORTATION_LABELS: Record<string, string> = {
  'under_5': 'Walking',
  '5_to_10': 'Biking',
  '10_to_15': 'Driving',
  '15_to_20': 'Driving',
  '20_to_25': 'Driving',
  'over_25': 'Extended Drive'
};

export const DEFAULT_LOCATION_PREFERENCES = {
  maxDistance: 15,
  preferOnCampus: true,
  acceptedDistanceRanges: ['under_5', '5_to_10', '10_to_15'],
  excludedAreas: []
}; 