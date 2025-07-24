'use client';

import { useState } from 'react';
import SignInForm from './SignInForm';
import SignUpForm from './SignUpForm';
import { Card, CardContent } from '@/components/ui/Card';

export default function AuthenticationPage() {
  const [isSignUp, setIsSignUp] = useState(false);

  return (
    <div className="min-h-screen flex flex-col bg-gradient-to-br from-texas-red-50 to-texas-gray-50">
      {/* Header Section */}
      <div className="texas-gradient text-white">
        <div className="container mx-auto px-4 py-16 text-center">
          <div className="animate-fade-in">
            <div className="text-6xl mb-4">⭐</div>
            <h1 className="text-4xl md:text-5xl font-bold mb-4">
              Raider ReSell
            </h1>
            <p className="text-xl md:text-2xl text-texas-red-100 max-w-2xl mx-auto">
              Texas Tech University Marketplace
            </p>
            <p className="mt-4 text-texas-red-200 max-w-md mx-auto">
              Buy and sell items within the Red Raider community
            </p>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="flex-1 flex items-center justify-center px-4 py-8">
        <div className="w-full max-w-md animate-slide-up">
          <Card variant="elevated">
            <CardContent className="p-0">
              {isSignUp ? (
                <SignUpForm onSwitchToSignIn={() => setIsSignUp(false)} />
              ) : (
                <SignInForm onSwitchToSignUp={() => setIsSignUp(true)} />
              )}
            </CardContent>
          </Card>
        </div>
      </div>

      {/* Footer */}
      <div className="py-8 text-center text-texas-gray-600">
        <p className="text-sm">
          Made with care for the Texas Tech Red Raiders community
        </p>
        <p className="text-xs mt-2">
          Wreck 'Em Tech! Red & Black
        </p>
      </div>
    </div>
  );
} 