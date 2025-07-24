'use client';

interface NavigationProps {
  activeTab: string;
  onTabChange: (tab: 'marketplace' | 'profile' | 'chats') => void;
}

export default function Navigation({ activeTab, onTabChange }: NavigationProps) {
  const tabs = [
    {
      id: 'marketplace' as const,
      label: 'Marketplace',
      icon: '🏪',
      activeIcon: '🏪'
    },
    {
      id: 'chats' as const,
      label: 'Chats',
      icon: '💬',
      activeIcon: '💬'
    },
    {
      id: 'profile' as const,
      label: 'Profile',
      icon: '👤',
      activeIcon: '👤'
    }
  ];

  return (
    <>
      {/* Mobile Navigation */}
      <div className="fixed bottom-0 left-0 right-0 bg-white border-t border-texas-gray-200 md:hidden">
        <div className="grid grid-cols-3">
          {tabs.map((tab) => (
            <button
              key={tab.id}
              onClick={() => onTabChange(tab.id)}
              className={`flex flex-col items-center py-4 px-2 text-sm font-medium transition-colors ${
                activeTab === tab.id
                  ? 'text-texas-red bg-texas-red-50'
                  : 'text-texas-gray-600 hover:text-texas-red'
              }`}
            >
              <span className="text-2xl mb-1">
                {activeTab === tab.id ? tab.activeIcon : tab.icon}
              </span>
              <span>{tab.label}</span>
            </button>
          ))}
        </div>
      </div>

      {/* Desktop Navigation */}
      <div className="hidden md:fixed md:top-0 md:left-0 md:h-full md:w-64 md:bg-white md:border-r md:border-texas-gray-200 md:flex md:flex-col">
        <div className="p-6">
          <div className="flex items-center">
            <span className="text-3xl">🏛️</span>
            <div className="ml-3">
              <h1 className="text-xl font-bold texas-text-gradient">
                Raider ReSell
              </h1>
              <p className="text-xs text-texas-gray-500">
                Texas Tech Marketplace
              </p>
            </div>
          </div>
        </div>

        <nav className="flex-1 px-4">
          {tabs.map((tab) => (
            <button
              key={tab.id}
              onClick={() => onTabChange(tab.id)}
              className={`w-full flex items-center px-4 py-3 mb-2 rounded-lg text-sm font-medium transition-all ${
                activeTab === tab.id
                  ? 'bg-texas-red text-white shadow-lg'
                  : 'text-texas-gray-700 hover:bg-texas-gray-100 hover:text-texas-red'
              }`}
            >
              <span className="text-xl mr-3">
                {activeTab === tab.id ? tab.activeIcon : tab.icon}
              </span>
              {tab.label}
            </button>
          ))}
        </nav>

        <div className="p-4 border-t border-texas-gray-200">
          <div className="text-center mb-4">
            <div className="inline-flex items-center px-3 py-2 bg-texas-red-50 rounded-full">
              <span className="text-texas-red text-sm font-medium">
                ✨ New: Real-time Chat System!
              </span>
            </div>
          </div>
          <p className="text-xs text-texas-gray-500 text-center">
            Wreck &apos;Em Tech! 🔴⚫
          </p>
        </div>
      </div>
    </>
  );
} 