'use client';

import { useAuth } from '@/hooks/useAuth';
import Button from '@/components/ui/Button';

export default function ProfileView() {
  const { currentUser, signOut } = useAuth();

  return (
    <div className="min-h-screen bg-texas-gray-50 md:ml-64">
      <div className="max-w-4xl mx-auto px-4 py-8">
        <div className="bg-white rounded-xl shadow-lg p-8">
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
          
          <div className="flex justify-center">
            <Button 
              onClick={signOut}
              variant="outline"
            >
              Sign Out
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
} 