'use client';

import { useState, useEffect } from 'react';
import { useAuth } from '@/hooks/useAuth';
import { Card, CardContent, CardHeader } from '@/components/ui/Card';
import Button from '@/components/ui/Button';
import Input from '@/components/ui/Input';
import { LocationPreferences, DistanceRange } from '@/types';
import { DISTANCE_RANGE_LABELS, TRANSPORTATION_LABELS, DEFAULT_LOCATION_PREFERENCES, APP_CONSTANTS } from '@/utils/constants';
import toast from 'react-hot-toast';

interface LocationPreferencesProps {
  onClose: () => void;
}

export default function LocationPreferencesModal({ onClose }: LocationPreferencesProps) {
  const { currentUser, updateUserProfile } = useAuth();
  const [preferences, setPreferences] = useState<LocationPreferences>(
    currentUser?.locationPreferences || {
      ...DEFAULT_LOCATION_PREFERENCES,
      acceptedDistanceRanges: DEFAULT_LOCATION_PREFERENCES.acceptedDistanceRanges as DistanceRange[]
    }
  );
  const [saving, setSaving] = useState(false);

  const distanceRanges = Object.values(DistanceRange);
  const excludableAreas = [
    ...APP_CONSTANTS.OFF_CAMPUS_AREAS.NEARBY_COMPLEXES,
    ...APP_CONSTANTS.OFF_CAMPUS_AREAS.NEIGHBORHOODS
  ];

  const handleDistanceRangeToggle = (range: DistanceRange) => {
    const isSelected = preferences.acceptedDistanceRanges.includes(range);
    if (isSelected) {
      setPreferences({
        ...preferences,
        acceptedDistanceRanges: preferences.acceptedDistanceRanges.filter(r => r !== range)
      });
    } else {
      setPreferences({
        ...preferences,
        acceptedDistanceRanges: [...preferences.acceptedDistanceRanges, range]
      });
    }
  };

  const handleExcludedAreaToggle = (area: string) => {
    const excludedAreas = preferences.excludedAreas || [];
    const isExcluded = excludedAreas.includes(area);
    
    if (isExcluded) {
      setPreferences({
        ...preferences,
        excludedAreas: excludedAreas.filter(a => a !== area)
      });
    } else {
      setPreferences({
        ...preferences,
        excludedAreas: [...excludedAreas, area]
      });
    }
  };

  const handleSave = async () => {
    try {
      setSaving(true);
      
      // Validate preferences
      if (preferences.acceptedDistanceRanges.length === 0 && !preferences.preferOnCampus) {
        toast.error('Please select at least one distance range or prefer on-campus items');
        return;
      }

      if (preferences.maxDistance < 1 || preferences.maxDistance > 50) {
        toast.error('Maximum distance must be between 1 and 50 miles');
        return;
      }

      const success = await updateUserProfile({
        locationPreferences: preferences
      });

      if (success) {
        toast.success(APP_CONSTANTS.SUCCESS_MESSAGES.LOCATION_PREFERENCES_UPDATED);
        onClose();
      }
    } catch (error) {
      console.error('Error saving location preferences:', error);
      toast.error('Failed to save preferences. Please try again.');
    } finally {
      setSaving(false);
    }
  };

  const resetToDefaults = () => {
    setPreferences({
      ...DEFAULT_LOCATION_PREFERENCES,
      acceptedDistanceRanges: DEFAULT_LOCATION_PREFERENCES.acceptedDistanceRanges as DistanceRange[]
    });
    toast.success('Reset to default preferences');
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
      <div className="bg-white rounded-xl max-w-4xl w-full max-h-[90vh] overflow-y-auto">
        <div className="sticky top-0 bg-white border-b border-texas-gray-200 p-6 rounded-t-xl">
          <div className="flex items-center justify-between">
            <h2 className="text-2xl font-bold text-texas-gray-900">
              Location Preferences
            </h2>
            <button
              onClick={onClose}
              className="p-2 hover:bg-texas-gray-100 rounded-full transition-colors text-lg font-bold"
            >
              ×
            </button>
          </div>
          <p className="text-texas-gray-600 mt-2">
            Customize how you want to see items based on location and distance
          </p>
        </div>

        <div className="p-6 space-y-8">
          {/* Campus Preference */}
          <Card>
            <CardHeader>
              <h3 className="text-lg font-semibold text-texas-gray-900">
                Campus Preference
              </h3>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <label className="flex items-center gap-3 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={preferences.preferOnCampus}
                    onChange={(e) => setPreferences({
                      ...preferences,
                      preferOnCampus: e.target.checked
                    })}
                    className="w-5 h-5 text-texas-red"
                  />
                  <div>
                    <span className="font-medium text-texas-gray-900">
                      Prefer on-campus items
                    </span>
                    <p className="text-sm text-texas-gray-600">
                      Show on-campus items first and highlight them in search results
                    </p>
                  </div>
                </label>
              </div>
            </CardContent>
          </Card>

          {/* Maximum Distance */}
          <Card>
            <CardHeader>
              <h3 className="text-lg font-semibold text-texas-gray-900">
                Maximum Distance
              </h3>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-texas-gray-700 mb-2">
                    Maximum distance for off-campus items
                  </label>
                  <div className="flex items-center gap-4">
                    <Input
                      type="range"
                      min="1"
                      max="50"
                      step="1"
                      value={preferences.maxDistance}
                      onChange={(e) => setPreferences({
                        ...preferences,
                        maxDistance: parseInt(e.target.value)
                      })}
                      className="flex-1"
                    />
                    <div className="bg-texas-red text-white px-3 py-2 rounded-lg font-medium min-w-[80px] text-center">
                      {preferences.maxDistance} mi
                    </div>
                  </div>
                  <p className="text-xs text-texas-gray-500 mt-2">
                    Items farther than this distance will be hidden from your search results
                  </p>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Distance Ranges */}
          <Card>
            <CardHeader>
              <h3 className="text-lg font-semibold text-texas-gray-900">
                Accepted Distance Ranges
              </h3>
              <p className="text-sm text-texas-gray-600">
                Select which distance ranges you're comfortable with for off-campus items
              </p>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
                {distanceRanges.map((range) => {
                  const isSelected = preferences.acceptedDistanceRanges.includes(range);
                  return (
                    <button
                      key={range}
                      onClick={() => handleDistanceRangeToggle(range)}
                      className={`flex items-center gap-3 p-3 rounded-lg border-2 transition-all ${
                        isSelected
                          ? 'border-texas-red bg-texas-red-50 text-texas-red'
                          : 'border-texas-gray-200 bg-white text-texas-gray-700 hover:border-texas-red-300'
                      }`}
                    >
                      <span className="text-sm font-medium">
                        {TRANSPORTATION_LABELS[range]}
                      </span>
                      <span className="font-medium">
                        {DISTANCE_RANGE_LABELS[range]}
                      </span>
                      {isSelected && (
                        <span className="ml-auto text-texas-red font-bold">✓</span>
                      )}
                    </button>
                  );
                })}
              </div>
              {preferences.acceptedDistanceRanges.length === 0 && (
                <p className="text-sm text-orange-600 mt-3 p-3 bg-orange-50 rounded-lg">
                  Warning: No distance ranges selected. You'll only see on-campus items.
                </p>
              )}
            </CardContent>
          </Card>

          {/* Excluded Areas */}
          <Card>
            <CardHeader>
              <h3 className="text-lg font-semibold text-texas-gray-900">
                Excluded Areas
              </h3>
              <p className="text-sm text-texas-gray-600">
                Hide items from specific areas you want to avoid
              </p>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div>
                  <h4 className="font-medium text-texas-gray-900 mb-2">Apartment Complexes</h4>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-2">
                    {APP_CONSTANTS.OFF_CAMPUS_AREAS.NEARBY_COMPLEXES.map((complex) => {
                      const isExcluded = preferences.excludedAreas?.includes(complex);
                      return (
                        <label key={complex} className="flex items-center gap-2 cursor-pointer">
                          <input
                            type="checkbox"
                            checked={isExcluded}
                            onChange={() => handleExcludedAreaToggle(complex)}
                            className="w-4 h-4 text-texas-red"
                          />
                          <span className="text-sm text-texas-gray-700">{complex}</span>
                        </label>
                      );
                    })}
                  </div>
                </div>

                <div>
                  <h4 className="font-medium text-texas-gray-900 mb-2">Neighborhoods</h4>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-2">
                    {APP_CONSTANTS.OFF_CAMPUS_AREAS.NEIGHBORHOODS.map((neighborhood) => {
                      const isExcluded = preferences.excludedAreas?.includes(neighborhood);
                      return (
                        <label key={neighborhood} className="flex items-center gap-2 cursor-pointer">
                          <input
                            type="checkbox"
                            checked={isExcluded}
                            onChange={() => handleExcludedAreaToggle(neighborhood)}
                            className="w-4 h-4 text-texas-red"
                          />
                          <span className="text-sm text-texas-gray-700">{neighborhood}</span>
                        </label>
                      );
                    })}
                  </div>
                </div>

                {preferences.excludedAreas && preferences.excludedAreas.length > 0 && (
                  <div className="p-3 bg-red-50 rounded-lg">
                    <p className="text-sm text-red-700">
                      Excluding {preferences.excludedAreas.length} area(s) from your search results
                    </p>
                  </div>
                )}
              </div>
            </CardContent>
          </Card>

          {/* Summary */}
          <Card variant="outlined">
            <CardHeader>
              <h3 className="text-lg font-semibold text-texas-gray-900">
                Preferences Summary
              </h3>
            </CardHeader>
            <CardContent>
              <div className="space-y-2 text-sm text-texas-gray-700">
                <div className="flex items-center gap-2">
                  <span className="font-medium">Campus preference:</span>
                  <span>{preferences.preferOnCampus ? 'Prefer on-campus' : 'No preference'}</span>
                </div>
                <div className="flex items-center gap-2">
                  <span className="font-medium">Maximum distance:</span>
                  <span>{preferences.maxDistance} miles</span>
                </div>
                <div className="flex items-center gap-2">
                  <span className="font-medium">Accepted ranges:</span>
                  <span>
                    {preferences.acceptedDistanceRanges.length > 0 
                      ? `${preferences.acceptedDistanceRanges.length} range(s) selected`
                      : 'None selected'
                    }
                  </span>
                </div>
                <div className="flex items-center gap-2">
                  <span className="font-medium">Excluded areas:</span>
                  <span>
                    {preferences.excludedAreas && preferences.excludedAreas.length > 0
                      ? `${preferences.excludedAreas.length} area(s) excluded`
                      : 'None excluded'
                    }
                  </span>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Footer */}
        <div className="sticky bottom-0 bg-white border-t border-texas-gray-200 p-6 rounded-b-xl">
          <div className="flex gap-3">
            <Button
              onClick={resetToDefaults}
              variant="outline"
              className="flex-1"
            >
              Reset to Defaults
            </Button>
            <Button
              onClick={onClose}
              variant="outline"
              className="flex-1"
            >
              Cancel
            </Button>
            <Button
              onClick={handleSave}
              variant="primary"
              disabled={saving}
              className="flex-1"
            >
              {saving ? 'Saving...' : 'Save Preferences'}
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
} 