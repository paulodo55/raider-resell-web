'use client';

import { useState, useEffect, useContext, createContext, ReactNode } from 'react';
import { User, DistanceRange } from '@/types';
import { APP_CONSTANTS, DEFAULT_LOCATION_PREFERENCES } from '@/utils/constants';
import toast from 'react-hot-toast';

interface AuthContextType {
  currentUser: User | null;
  loading: boolean;
  signUp: (email: string, password: string, userData: Partial<User>) => Promise<boolean>;
  signIn: (email: string, password: string) => Promise<boolean>;
  signOut: () => Promise<void>;
  resetPassword: (email: string) => Promise<boolean>;
  updateUserProfile: (userData: Partial<User>) => Promise<boolean>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

interface AuthProviderProps {
  children: ReactNode;
}

// Mock user data for demonstration
const mockUsers: Record<string, User> = {};

export function AuthProvider({ children }: AuthProviderProps) {
  const [currentUser, setCurrentUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const storedUser = localStorage.getItem('raider-resell-user');
    if (storedUser) {
      try {
        const user = JSON.parse(storedUser);
        setCurrentUser({
          ...user,
          createdAt: new Date(user.createdAt),
          lastActive: new Date(user.lastActive)
        });
      } catch (error) {
        console.error('Error parsing stored user:', error);
        localStorage.removeItem('raider-resell-user');
      }
    }
    setLoading(false);
  }, []);

  const signUp = async (email: string, password: string, userData: Partial<User>): Promise<boolean> => {
    try {
      setLoading(true);
      
      // Validate Texas Tech email
      if (!email.toLowerCase().endsWith(APP_CONSTANTS.VALIDATION.TEXAS_TECH_EMAIL_SUFFIX)) {
        toast.error(APP_CONSTANTS.ERROR_MESSAGES.INVALID_EMAIL);
        return false;
      }

      // Validate password
      if (password.length < APP_CONSTANTS.VALIDATION.PASSWORD_MIN_LENGTH) {
        toast.error(APP_CONSTANTS.ERROR_MESSAGES.PASSWORD_TOO_SHORT);
        return false;
      }

      // Check if user already exists
      if (mockUsers[email]) {
        toast.error('An account with this email already exists');
        return false;
      }

      const newUser: User = {
        id: Date.now().toString(),
        email,
        firstName: userData.firstName || '',
        lastName: userData.lastName || '',
        studentID: userData.studentID || '',
        graduationYear: userData.graduationYear || new Date().getFullYear() + 4,
        rating: 0,
        totalRatings: 0,
        itemsSold: 0,
        itemsBought: 0,
        isVerified: false,
        createdAt: new Date(),
        lastActive: new Date(),
        locationPreferences: {
          ...DEFAULT_LOCATION_PREFERENCES,
          acceptedDistanceRanges: DEFAULT_LOCATION_PREFERENCES.acceptedDistanceRanges as DistanceRange[]
        },
        ...userData
      };

      mockUsers[email] = newUser;
      setCurrentUser(newUser);
      localStorage.setItem('raider-resell-user', JSON.stringify(newUser));
      toast.success(APP_CONSTANTS.SUCCESS_MESSAGES.ACCOUNT_CREATED);
      
      return true;
    } catch (error: any) {
      console.error('Sign up error:', error);
      toast.error(error.message || APP_CONSTANTS.ERROR_MESSAGES.AUTHENTICATION_ERROR);
      return false;
    } finally {
      setLoading(false);
    }
  };

  const signIn = async (email: string, password: string): Promise<boolean> => {
    try {
      setLoading(true);
      
      // For demo purposes, accept any Texas Tech email with password "password"
      if (!email.toLowerCase().endsWith(APP_CONSTANTS.VALIDATION.TEXAS_TECH_EMAIL_SUFFIX)) {
        toast.error(APP_CONSTANTS.ERROR_MESSAGES.INVALID_EMAIL);
        return false;
      }

      // Check if user exists or create a demo user
      let user = mockUsers[email];
      if (!user) {
        // Create a demo user for any Texas Tech email
        user = {
          id: Date.now().toString(),
          email,
          firstName: 'Demo',
          lastName: 'User',
          studentID: '12345678',
          graduationYear: new Date().getFullYear() + 2,
          rating: 4.8,
          totalRatings: 25,
          itemsSold: 12,
          itemsBought: 8,
          isVerified: true,
          createdAt: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000), // 30 days ago
          lastActive: new Date(),
          locationPreferences: {
            ...DEFAULT_LOCATION_PREFERENCES,
            maxDistance: 10,
            acceptedDistanceRanges: [DistanceRange.UNDER_5, DistanceRange.RANGE_5_10]
          }
        };
        mockUsers[email] = user;
      }
      
      // Update last active
      user.lastActive = new Date();
      
      setCurrentUser(user);
      localStorage.setItem('raider-resell-user', JSON.stringify(user));
      
      return true;
    } catch (error: any) {
      console.error('Sign in error:', error);
      toast.error(error.message || APP_CONSTANTS.ERROR_MESSAGES.AUTHENTICATION_ERROR);
      return false;
    } finally {
      setLoading(false);
    }
  };

  const signOut = async (): Promise<void> => {
    try {
      setCurrentUser(null);
      localStorage.removeItem('raider-resell-user');
    } catch (error: any) {
      console.error('Sign out error:', error);
      toast.error('Error signing out');
    }
  };

  const resetPassword = async (email: string): Promise<boolean> => {
    try {
      if (!email.toLowerCase().endsWith(APP_CONSTANTS.VALIDATION.TEXAS_TECH_EMAIL_SUFFIX)) {
        toast.error(APP_CONSTANTS.ERROR_MESSAGES.INVALID_EMAIL);
        return false;
      }

      toast.success(APP_CONSTANTS.SUCCESS_MESSAGES.PASSWORD_RESET);
      return true;
    } catch (error: any) {
      console.error('Password reset error:', error);
      toast.error('Error sending password reset email');
      return false;
    }
  };

  const updateUserProfile = async (userData: Partial<User>): Promise<boolean> => {
    try {
      if (!currentUser) return false;

      const updatedUser = { ...currentUser, ...userData };
      setCurrentUser(updatedUser);
      localStorage.setItem('raider-resell-user', JSON.stringify(updatedUser));
      
      // Update in mock users as well
      if (currentUser.email) {
        mockUsers[currentUser.email] = updatedUser;
      }
      
      toast.success(APP_CONSTANTS.SUCCESS_MESSAGES.PROFILE_UPDATED);
      return true;
    } catch (error: any) {
      console.error('Profile update error:', error);
      toast.error('Error updating profile');
      return false;
    }
  };

  const value: AuthContextType = {
    currentUser,
    loading,
    signUp,
    signIn,
    signOut,
    resetPassword,
    updateUserProfile
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
} 