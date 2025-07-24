'use client';

import { useState, useEffect } from 'react';
import { useAuth } from '@/hooks/useAuth';
import { Card, CardContent, CardHeader } from '@/components/ui/Card';
import Button from '@/components/ui/Button';
import Input from '@/components/ui/Input';
import { ItemCategory, CATEGORY_ICONS } from '@/utils/constants';

// Mock data for demonstration
const mockItems = [
  {
    id: '1',
    title: 'MacBook Pro 13" 2022',
    description: 'Excellent condition, barely used. Perfect for computer science students.',
    price: 899,
    originalPrice: 1299,
    category: ItemCategory.ELECTRONICS,
    condition: 'Like New',
    imageURLs: ['https://via.placeholder.com/300x200?text=MacBook'],
    location: 'Knapp Hall',
    sellerName: 'John Doe',
    views: 45,
    likes: 12,
    timeAgo: '2 hours ago'
  },
  {
    id: '2',
    title: 'Introduction to Algorithms Textbook',
    description: 'CS 3341 textbook in great condition. No highlighting or marks.',
    price: 85,
    originalPrice: 150,
    category: ItemCategory.TEXTBOOKS,
    condition: 'Good',
    imageURLs: ['https://via.placeholder.com/300x200?text=Textbook'],
    location: 'Wall Hall',
    sellerName: 'Sarah Smith',
    views: 23,
    likes: 8,
    timeAgo: '5 hours ago'
  },
  {
    id: '3',
    title: 'Texas Tech Hoodie',
    description: 'Official Red Raiders hoodie, size L. Worn a few times.',
    price: 25,
    category: ItemCategory.CLOTHING,
    condition: 'Good',
    imageURLs: ['https://via.placeholder.com/300x200?text=Hoodie'],
    location: 'Murdough Hall',
    sellerName: 'Mike Johnson',
    views: 18,
    likes: 5,
    timeAgo: '1 day ago'
  },
  {
    id: '4',
    title: 'Desk Lamp + Study Chair',
    description: 'Perfect for dorm room studying. Both items for one price!',
    price: 40,
    category: ItemCategory.FURNITURE,
    condition: 'Fair',
    imageURLs: ['https://via.placeholder.com/300x200?text=Furniture'],
    location: 'Coleman Hall',
    sellerName: 'Lisa Chen',
    views: 31,
    likes: 9,
    timeAgo: '2 days ago'
  }
];

export default function MarketplaceView() {
  const { currentUser } = useAuth();
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<ItemCategory | null>(null);
  const [items, setItems] = useState(mockItems);
  const [loading, setLoading] = useState(false);

  const categories = Object.values(ItemCategory);

  const filteredItems = items.filter(item => {
    const matchesSearch = !searchQuery || 
      item.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      item.description.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesCategory = !selectedCategory || item.category === selectedCategory;
    return matchesSearch && matchesCategory;
  });

  return (
    <div className="min-h-screen bg-texas-gray-50 md:ml-64">
      {/* Header */}
      <div className="bg-white border-b border-texas-gray-200 px-4 py-6">
        <div className="max-w-7xl mx-auto">
          <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
            <div>
              <h1 className="text-2xl font-bold text-texas-gray-900">
                Hey, {currentUser?.firstName || 'Raider'}! 👋
              </h1>
              <p className="text-texas-gray-600">
                Find great deals at Texas Tech
              </p>
            </div>
            
            <div className="flex items-center gap-3">
              <Button variant="outline" size="sm">
                🔔 Notifications
              </Button>
            </div>
          </div>
        </div>
      </div>

      {/* Search and Filters */}
      <div className="bg-white border-b border-texas-gray-200 px-4 py-4">
        <div className="max-w-7xl mx-auto">
          <div className="flex flex-col md:flex-row gap-4">
            <div className="flex-1">
              <Input
                type="text"
                placeholder="Search items..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="pl-10"
              />
            </div>
            <div className="flex gap-2">
              <Button variant="primary" size="sm">
                🔍 Search
              </Button>
              <Button variant="outline" size="sm">
                ⚙️ Filters
              </Button>
            </div>
          </div>
        </div>
      </div>

      {/* Category Pills */}
      <div className="bg-white border-b border-texas-gray-200 px-4 py-4">
        <div className="max-w-7xl mx-auto">
          <div className="flex gap-2 overflow-x-auto scrollbar-hide">
            <button
              onClick={() => setSelectedCategory(null)}
              className={`px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-colors ${
                !selectedCategory
                  ? 'bg-texas-red text-white'
                  : 'bg-texas-gray-100 text-texas-gray-700 hover:bg-texas-gray-200'
              }`}
            >
              🏪 All
            </button>
            {categories.map((category) => (
              <button
                key={category}
                onClick={() => setSelectedCategory(category)}
                className={`px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-colors ${
                  selectedCategory === category
                    ? 'bg-texas-red text-white'
                    : 'bg-texas-gray-100 text-texas-gray-700 hover:bg-texas-gray-200'
                }`}
              >
                {CATEGORY_ICONS[category]} {category}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Items Grid */}
      <div className="max-w-7xl mx-auto px-4 py-8">
        <div className="mb-6">
          <h2 className="text-xl font-semibold text-texas-gray-900 mb-2">
            {selectedCategory ? `${selectedCategory} Items` : 'All Items'}
          </h2>
          <p className="text-texas-gray-600">
            {filteredItems.length} items found
          </p>
        </div>

        {filteredItems.length === 0 ? (
          <div className="text-center py-12">
            <div className="text-6xl mb-4">🔍</div>
            <h3 className="text-xl font-semibold text-texas-gray-900 mb-2">
              No items found
            </h3>
            <p className="text-texas-gray-600">
              Try adjusting your search or browse different categories
            </p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            {filteredItems.map((item) => (
              <Card key={item.id} variant="elevated" className="hover:scale-105 transition-transform duration-200 cursor-pointer">
                <div className="relative">
                  <img
                    src={item.imageURLs[0]}
                    alt={item.title}
                    className="w-full h-48 object-cover"
                  />
                  <div className="absolute top-3 right-3 bg-texas-red text-white px-2 py-1 rounded-full text-xs font-medium">
                    {item.condition}
                  </div>
                </div>
                <CardContent className="p-4">
                  <div className="mb-3">
                    <h3 className="font-semibold text-texas-gray-900 line-clamp-2 mb-1">
                      {item.title}
                    </h3>
                    <p className="text-sm text-texas-gray-600 line-clamp-2">
                      {item.description}
                    </p>
                  </div>
                  
                  <div className="flex items-center justify-between mb-3">
                    <div className="flex items-center gap-2">
                      <span className="text-xl font-bold text-texas-red">
                        ${item.price}
                      </span>
                      {item.originalPrice && (
                        <span className="text-sm text-texas-gray-500 line-through">
                          ${item.originalPrice}
                        </span>
                      )}
                    </div>
                    <button className="text-texas-red hover:text-texas-red-600 transition-colors">
                      ❤️ {item.likes}
                    </button>
                  </div>
                  
                  <div className="flex items-center justify-between text-xs text-texas-gray-500">
                    <span>📍 {item.location}</span>
                    <span>👁️ {item.views}</span>
                  </div>
                  
                  <div className="flex items-center justify-between mt-3 pt-3 border-t border-texas-gray-100">
                    <span className="text-xs text-texas-gray-500">
                      {item.timeAgo}
                    </span>
                    <Button variant="primary" size="sm">
                      View Details
                    </Button>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        )}
      </div>
    </div>
  );
} 