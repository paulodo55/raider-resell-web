'use client';

import { useState } from 'react';
import { useAuth } from '@/hooks/useAuth';
import { useChatStore } from '@/hooks/useChatStore';
import MarketplaceView from './MarketplaceView';
import ProfileView from './ProfileView';
import ChatView from './ChatView';
import Navigation from './Navigation';

type Tab = 'marketplace' | 'profile' | 'chats';

export default function MarketplacePage() {
  const [activeTab, setActiveTab] = useState<Tab>('marketplace');
  const { currentUser } = useAuth();

  const handleNavigateToChat = () => {
    setActiveTab('chats');
  };

  const renderActiveTab = () => {
    switch (activeTab) {
      case 'marketplace':
        return <MarketplaceView onNavigateToChat={handleNavigateToChat} />;
      case 'profile':
        return <ProfileView />;
      case 'chats':
        return <ChatView />;
      default:
        return <MarketplaceView onNavigateToChat={handleNavigateToChat} />;
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