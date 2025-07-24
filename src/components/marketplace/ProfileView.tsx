'use client';

import { useState } from 'react';
import { useAuth } from '@/hooks/useAuth';
import Button from '@/components/ui/Button';
import { Card, CardContent } from '@/components/ui/Card';
import LocationPreferencesModal from '../profile/LocationPreferences';
import { DISTANCE_RANGE_LABELS, LOCATION_ICONS } from '@/utils/constants';

export default function ProfileView() {
  const { currentUser, signOut } = useAuth();
  const [showLocationPreferences, setShowLocationPreferences] = useState(false);

  const getLocationPreferencesSummary = () => {
    const prefs = currentUser?.locationPreferences;
    if (!prefs) return 'Not set';

    const parts = [];
    if (prefs.preferOnCampus) parts.push('🏫 Prefers on-campus');
    parts.push(`🚗 Max ${prefs.maxDistance} miles`);
    if (prefs.acceptedDistanceRanges.length > 0) {
      parts.push(`📏 ${prefs.acceptedDistanceRanges.length} range(s)`);
    }
    if (prefs.excludedAreas && prefs.excludedAreas.length > 0) {
      parts.push(`🚫 ${prefs.excludedAreas.length} excluded area(s)`);
    }

    return parts.join(', ');
  };

  return (
    <div className="min-h-screen bg-texas-gray-50 md:ml-64">
      <div className="max-w-4xl mx-auto px-4 py-8">
        {/* Profile Header */}
        <Card variant="elevated" className="mb-8">
          <CardContent className="p-8">
            <div className="text-center mb-8">
              <div className="text-6xl mb-4">👤</div>
              <h2 className="text-2xl font-bold text-texas-gray-900 mb-2">
                {currentUser?.firstName} {currentUser?.lastName}
              </h2>
              <p className="text-texas-gray-600">
                {currentUser?.email}
              </p>
              <div className="mt-4 inline-flex items-center px-3 py-1 rounded-full text-sm bg-texas-red-50 text-texas-red">
                🎓 Class of {currentUser?.graduationYear}
              </div>
            </div>
            
            {/* Stats Grid */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
              <div className="text-center p-4 bg-texas-gray-50 rounded-lg">
                <div className="text-2xl font-bold text-texas-red">
                  {currentUser?.itemsSold || 0}
                </div>
                <div className="text-sm text-texas-gray-600">Items Sold</div>
              </div>
              <div className="text-center p-4 bg-texas-gray-50 rounded-lg">
                <div className="text-2xl font-bold text-texas-red">
                  {currentUser?.itemsBought || 0}
                </div>
                <div className="text-sm text-texas-gray-600">Items Bought</div>
              </div>
              <div className="text-center p-4 bg-texas-gray-50 rounded-lg">
                <div className="text-2xl font-bold text-texas-red">
                  {currentUser?.rating?.toFixed(1) || '0.0'}
                </div>
                <div className="text-sm text-texas-gray-600">Rating</div>
              </div>
            </div>

            {/* Action Buttons */}
            <div className="flex flex-col md:flex-row gap-4">
              <Button 
                variant="primary" 
                className="flex-1"
                onClick={() => setShowLocationPreferences(true)}
              >
                📍 Location Preferences
              </Button>
              <Button variant="outline" className="flex-1">
                ⚙️ Account Settings
              </Button>
              <Button 
                variant="outline" 
                onClick={signOut}
                className="flex-1 hover:bg-red-50 hover:text-red-600 hover:border-red-200"
              >
                🚪 Sign Out
              </Button>
            </div>
          </CardContent>
        </Card>

        {/* Location Preferences Summary */}
        <Card variant="outlined" className="mb-8">
          <CardContent className="p-6">
            <div className="flex items-start justify-between">
              <div className="flex-1">
                <h3 className="text-lg font-semibold text-texas-gray-900 mb-2">
                  📍 Location Preferences
                </h3>
                <p className="text-sm text-texas-gray-600 mb-4">
                  {getLocationPreferencesSummary()}
                </p>
                
                {currentUser?.locationPreferences && (
                  <div className="space-y-2 text-xs text-texas-gray-500">
                    {currentUser.locationPreferences.preferOnCampus && (
                      <div className="flex items-center gap-2">
                        <span>🏫</span>
                        <span>Prefers on-campus items</span>
                      </div>
                    )}
                    
                    {currentUser.locationPreferences.acceptedDistanceRanges.length > 0 && (
                      <div className="flex items-start gap-2">
                        <span>📏</span>
                        <div>
                          <span>Accepted ranges: </span>
                          <div className="flex flex-wrap gap-1 mt-1">
                            {currentUser.locationPreferences.acceptedDistanceRanges.map((range) => (
                              <span 
                                key={range}
                                className="inline-flex items-center gap-1 px-2 py-1 bg-texas-gray-100 rounded text-xs"
                              >
                                {LOCATION_ICONS[range]} {DISTANCE_RANGE_LABELS[range]}
                              </span>
                            ))}
                          </div>
                        </div>
                      </div>
                    )}

                    {currentUser.locationPreferences.excludedAreas && 
                     currentUser.locationPreferences.excludedAreas.length > 0 && (
                      <div className="flex items-start gap-2">
                        <span>🚫</span>
                        <div>
                          <span>Excluded areas: </span>
                          <span>{currentUser.locationPreferences.excludedAreas.join(', ')}</span>
                        </div>
                      </div>
                    )}
                  </div>
                )}
              </div>
              
              <Button 
                variant="outline" 
                size="sm"
                onClick={() => setShowLocationPreferences(true)}
              >
                Edit
              </Button>
            </div>
          </CardContent>
        </Card>

        {/* Account Information */}
        <Card variant="outlined">
          <CardContent className="p-6">
            <h3 className="text-lg font-semibold text-texas-gray-900 mb-4">
              📋 Account Information
            </h3>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label className="block text-sm font-medium text-texas-gray-700 mb-1">
                  Student ID
                </label>
                <p className="text-texas-gray-900">{currentUser?.studentID}</p>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-texas-gray-700 mb-1">
                  Graduation Year
                </label>
                <p className="text-texas-gray-900">{currentUser?.graduationYear}</p>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-texas-gray-700 mb-1">
                  Account Status
                </label>
                <div className="flex items-center gap-2">
                  <span className={`w-3 h-3 rounded-full ${
                    currentUser?.isVerified ? 'bg-green-500' : 'bg-yellow-500'
                  }`}></span>
                  <span className="text-texas-gray-900">
                    {currentUser?.isVerified ? 'Verified' : 'Pending Verification'}
                  </span>
                </div>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-texas-gray-700 mb-1">
                  Member Since
                </label>
                <p className="text-texas-gray-900">
                  {currentUser?.createdAt?.toLocaleDateString('en-US', {
                    year: 'numeric',
                    month: 'long',
                    day: 'numeric'
                  })}
                </p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Location Preferences Modal */}
      {showLocationPreferences && (
        <LocationPreferencesModal
          onClose={() => setShowLocationPreferences(false)}
        />
      )}
    </div>
  );
} 