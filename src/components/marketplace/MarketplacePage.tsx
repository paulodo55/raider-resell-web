'use client';

import { useState } from 'react';
import { useAuth } from '@/hooks/useAuth';
import MarketplaceView from './MarketplaceView';
import ProfileView from './ProfileView';
import Navigation from './Navigation';

type Tab = 'marketplace' | 'profile';

export default function MarketplacePage() {
  const [activeTab, setActiveTab] = useState<Tab>('marketplace');
  const { currentUser } = useAuth();

  const renderActiveTab = () => {
    switch (activeTab) {
      case 'marketplace':
        return <MarketplaceView />;
      case 'profile':
        return <ProfileView />;
      default:
        return <MarketplaceView />;
    }
  };

  return (
    <div className="min-h-screen bg-texas-gray-50">
      <div className="pb-20 md:pb-0">
        {renderActiveTab()}
      </div>
      
      <Navigation 
        activeTab={activeTab} 
        onTabChange={setActiveTab}
      />
    </div>
  );
} 