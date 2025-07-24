'use client';

import { useState, useEffect } from 'react';
import { useAuth } from '@/hooks/useAuth';
import { useChatStore } from '@/hooks/useChatStore';
import { Card, CardContent, CardHeader } from '@/components/ui/Card';
import Button from '@/components/ui/Button';
import Input from '@/components/ui/Input';
import { ItemCategory, CONDITION_COLORS, DISTANCE_RANGE_LABELS, LOCATION_TYPE_LABELS, TRANSPORTATION_LABELS } from '@/utils/constants';
import { LocationType, DistanceRange, LocationInfo } from '@/types';
import toast from 'react-hot-toast';

// Mock data with new location system
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
    location: {
      locationType: LocationType.ON_CAMPUS,
      specificLocation: 'Knapp Hall',
      exactDistance: 0
    } as LocationInfo,
    sellerName: 'John Doe',
    sellerId: 'seller-1',
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
    location: {
      locationType: LocationType.ON_CAMPUS,
      specificLocation: 'Wall Hall',
      exactDistance: 0
    } as LocationInfo,
    sellerName: 'Sarah Smith',
    sellerId: 'seller-2',
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
    location: {
      locationType: LocationType.OFF_CAMPUS,
      specificLocation: 'University Courtyard',
      distanceRange: DistanceRange.UNDER_5,
      exactDistance: 2.3,
      address: '2324 Main St, Lubbock, TX'
    } as LocationInfo,
    sellerName: 'Mike Johnson',
    sellerId: 'buyer-1',
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
    location: {
      locationType: LocationType.OFF_CAMPUS,
      specificLocation: 'Sterling University Trails',
      distanceRange: DistanceRange.RANGE_5_10,
      exactDistance: 6.8,
      address: '6102 4th St, Lubbock, TX'
    } as LocationInfo,
    sellerName: 'Lisa Chen',
    sellerId: 'seller-4',
    views: 31,
    likes: 9,
    timeAgo: '2 days ago'
  },
  {
    id: '5',
    title: 'Gaming Chair - RGB',
    description: 'Professional gaming chair with RGB lighting. Very comfortable for long study sessions.',
    price: 150,
    originalPrice: 250,
    category: ItemCategory.FURNITURE,
    condition: 'Good',
    imageURLs: ['https://via.placeholder.com/300x200?text=Gaming+Chair'],
    location: {
      locationType: LocationType.OFF_CAMPUS,
      specificLocation: 'Tech Terrace',
      distanceRange: DistanceRange.RANGE_10_15,
      exactDistance: 12.1,
      address: '2408 26th St, Lubbock, TX'
    } as LocationInfo,
    sellerName: 'Alex Rodriguez',
    sellerId: 'seller-5',
    views: 62,
    likes: 18,
    timeAgo: '3 hours ago'
  },
  {
    id: '6',
    title: 'Calculus III Solutions Manual',
    description: 'Step-by-step solutions for all problems. Perfect for MATH 2350.',
    price: 35,
    category: ItemCategory.TEXTBOOKS,
    condition: 'Good',
    imageURLs: ['https://via.placeholder.com/300x200?text=Solutions+Manual'],
    location: {
      locationType: LocationType.OFF_CAMPUS,
      specificLocation: 'Campus Lodge',
      distanceRange: DistanceRange.RANGE_15_20,
      exactDistance: 17.5,
      address: '5720 66th St, Lubbock, TX'
    } as LocationInfo,
    sellerName: 'Emma Wilson',
    sellerId: 'seller-6',
    views: 28,
    likes: 7,
    timeAgo: '6 hours ago'
  }
];

interface MarketplaceViewProps {
  onNavigateToChat?: () => void;
}

export default function MarketplaceView({ onNavigateToChat }: MarketplaceViewProps) {
  const { currentUser } = useAuth();
  const { createChatWithSeller } = useChatStore();
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<ItemCategory | null>(null);
  const [items, setItems] = useState(mockItems);
  const [loading, setLoading] = useState(false);
  
  // Filter and Modal States
  const [showFilters, setShowFilters] = useState(false);
  const [selectedItem, setSelectedItem] = useState<any>(null);
  const [priceRange, setPriceRange] = useState<[number, number]>([0, 1000]);
  const [selectedConditions, setSelectedConditions] = useState<string[]>([]);
  const [selectedLocations, setSelectedLocations] = useState<string[]>([]);
  const [contactingseller, setContactingseller] = useState(false);
  
  // Location Filter States
  const [locationFilter, setLocationFilter] = useState<'all' | 'on_campus' | 'off_campus'>('all');
  const [selectedDistanceRanges, setSelectedDistanceRanges] = useState<DistanceRange[]>([]);
  const [maxDistance, setMaxDistance] = useState<number>(25);

  const categories = Object.values(ItemCategory);
  const conditions = ['New', 'Like New', 'Good', 'Fair', 'Poor'];
  const locations = ['Knapp Hall', 'Wall Hall', 'Murdough Hall', 'Coleman Hall', 'Chitwood Hall', 'University Courtyard', 'Sterling University Trails', 'Tech Terrace', 'Campus Lodge', 'Other'];
  const distanceRanges = Object.values(DistanceRange);

  const filteredItems = items.filter(item => {
    const matchesSearch = !searchQuery || 
      item.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      item.description.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesCategory = !selectedCategory || item.category === selectedCategory;
    const matchesPrice = item.price >= priceRange[0] && item.price <= priceRange[1];
    const matchesCondition = selectedConditions.length === 0 || selectedConditions.includes(item.condition);
    const matchesLocation = selectedLocations.length === 0 || selectedLocations.includes(item.location.specificLocation);
    
    // Location-based filtering
    const matchesLocationType = locationFilter === 'all' || 
      (locationFilter === 'on_campus' && item.location.locationType === LocationType.ON_CAMPUS) ||
      (locationFilter === 'off_campus' && item.location.locationType === LocationType.OFF_CAMPUS);
    
    const matchesDistanceRange = selectedDistanceRanges.length === 0 || 
      (item.location.distanceRange && selectedDistanceRanges.includes(item.location.distanceRange));
    
    const matchesMaxDistance = !item.location.exactDistance || item.location.exactDistance <= maxDistance;
    
    return matchesSearch && matchesCategory && matchesPrice && matchesCondition && 
           matchesLocation && matchesLocationType && matchesDistanceRange && matchesMaxDistance;
  });

  const handleItemClick = (item: any) => {
    setSelectedItem(item);
    // Simulate view increment
    setItems(prev => prev.map(i => 
      i.id === item.id ? { ...i, views: i.views + 1 } : i
    ));
  };

  const handleLikeClick = (e: React.MouseEvent, itemId: string) => {
    e.stopPropagation();
    setItems(prev => prev.map(item => 
      item.id === itemId ? { ...item, likes: item.likes + 1 } : item
    ));
  };

  const handleContactSeller = async (item: any) => {
    if (!currentUser) {
      toast.error('Please sign in to contact sellers');
      return;
    }

    if (item.sellerId === (currentUser.id || 'current-user')) {
      toast.error("You can't contact yourself!");
      return;
    }

    try {
      setContactingseller(true);
      toast.loading('Starting conversation...', { id: 'contact-seller' });

      const chatId = await createChatWithSeller(
        item.id,
        item.title,
        item.imageURLs[0],
        item.sellerId,
        item.sellerName
      );

      toast.success('Chat started! Redirecting...', { id: 'contact-seller' });
      
      // Close modal and navigate to chat
      setSelectedItem(null);
      
      // Navigate to chat tab
      if (onNavigateToChat) {
        setTimeout(() => {
          onNavigateToChat();
        }, 500);
      }

    } catch (error) {
      console.error('Error contacting seller:', error);
      toast.error('Failed to start chat. Please try again.', { id: 'contact-seller' });
    } finally {
      setContactingseller(false);
    }
  };

  const clearFilters = () => {
    setPriceRange([0, 1000]);
    setSelectedConditions([]);
    setSelectedLocations([]);
    setLocationFilter('all');
    setSelectedDistanceRanges([]);
    setMaxDistance(25);
    setShowFilters(false);
  };

  const getLocationDisplay = (location: LocationInfo) => {
    if (location.locationType === LocationType.ON_CAMPUS) {
      return `${LOCATION_TYPE_LABELS[location.locationType]} - ${location.specificLocation}`;
    } else {
      const distanceText = location.exactDistance ? 
        `${location.exactDistance.toFixed(1)} mi` : 
        (location.distanceRange ? DISTANCE_RANGE_LABELS[location.distanceRange] : 'Off Campus');
      const transportLabel = location.distanceRange ? TRANSPORTATION_LABELS[location.distanceRange] : 'Driving';
      
      return `${location.specificLocation} (${distanceText} - ${transportLabel})`;
    }
  };

  const getActiveFilterCount = () => {
    let count = 0;
    if (selectedConditions.length > 0) count++;
    if (selectedLocations.length > 0) count++;
    if (priceRange[0] > 0 || priceRange[1] < 1000) count++;
    if (locationFilter !== 'all') count++;
    if (selectedDistanceRanges.length > 0) count++;
    if (maxDistance < 25) count++;
    return count;
  };

  return (
    <div className="min-h-screen bg-texas-gray-50 md:ml-64">
      {/* Header */}
      <div className="bg-white border-b border-texas-gray-200 px-4 py-6">
        <div className="max-w-7xl mx-auto">
          <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
            <div>
              <h1 className="text-2xl font-bold text-texas-gray-900">
                Welcome, {currentUser?.firstName || 'Raider'}!
              </h1>
              <p className="text-texas-gray-600">
                Find great deals at Texas Tech
              </p>
            </div>
            
            <div className="flex items-center gap-3">
              <Button variant="outline" size="sm">
                Notifications
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
                Search
              </Button>
              <Button 
                variant="outline" 
                size="sm"
                onClick={() => setShowFilters(!showFilters)}
              >
                Filters {getActiveFilterCount() > 0 && `(${getActiveFilterCount()})`}
              </Button>
            </div>
          </div>
        </div>
      </div>

      {/* Location Filter Pills */}
      <div className="bg-white border-b border-texas-gray-200 px-4 py-4">
        <div className="max-w-7xl mx-auto">
          <div className="flex gap-2 overflow-x-auto scrollbar-hide mb-2">
            <button
              onClick={() => setLocationFilter('all')}
              className={`px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-colors ${
                locationFilter === 'all'
                  ? 'bg-texas-red text-white'
                  : 'bg-texas-gray-100 text-texas-gray-700 hover:bg-texas-gray-200'
              }`}
            >
              All Locations
            </button>
            <button
              onClick={() => setLocationFilter('on_campus')}
              className={`px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-colors ${
                locationFilter === 'on_campus'
                  ? 'bg-texas-red text-white'
                  : 'bg-texas-gray-100 text-texas-gray-700 hover:bg-texas-gray-200'
              }`}
            >
              On Campus
            </button>
            <button
              onClick={() => setLocationFilter('off_campus')}
              className={`px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-colors ${
                locationFilter === 'off_campus'
                  ? 'bg-texas-red text-white'
                  : 'bg-texas-gray-100 text-texas-gray-700 hover:bg-texas-gray-200'
              }`}
            >
              Off Campus
            </button>
          </div>
        </div>
      </div>

      {/* Filters Panel */}
      {showFilters && (
        <div className="bg-white border-b border-texas-gray-200 px-4 py-6">
          <div className="max-w-7xl mx-auto">
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
              {/* Price Range */}
              <div>
                <h3 className="font-semibold text-texas-gray-900 mb-3">Price Range</h3>
                <div className="space-y-3">
                  <div className="flex gap-2">
                    <Input
                      type="number"
                      placeholder="Min"
                      value={priceRange[0]}
                      onChange={(e) => setPriceRange([parseInt(e.target.value) || 0, priceRange[1]])}
                      className="text-sm"
                    />
                    <Input
                      type="number"
                      placeholder="Max"
                      value={priceRange[1]}
                      onChange={(e) => setPriceRange([priceRange[0], parseInt(e.target.value) || 1000])}
                      className="text-sm"
                    />
                  </div>
                  <p className="text-xs text-texas-gray-500">
                    ${priceRange[0]} - ${priceRange[1]}
                  </p>
                </div>
              </div>

              {/* Condition */}
              <div>
                <h3 className="font-semibold text-texas-gray-900 mb-3">Condition</h3>
                <div className="space-y-2 max-h-32 overflow-y-auto">
                  {conditions.map((condition) => (
                    <label key={condition} className="flex items-center gap-2 cursor-pointer">
                      <input
                        type="checkbox"
                        checked={selectedConditions.includes(condition)}
                        onChange={(e) => {
                          if (e.target.checked) {
                            setSelectedConditions([...selectedConditions, condition]);
                          } else {
                            setSelectedConditions(selectedConditions.filter(c => c !== condition));
                          }
                        }}
                        className="w-4 h-4 text-texas-red"
                      />
                      <span className="text-sm text-texas-gray-700">{condition}</span>
                    </label>
                  ))}
                </div>
              </div>

              {/* Distance Range (for off-campus) */}
              <div>
                <h3 className="font-semibold text-texas-gray-900 mb-3">Distance Range</h3>
                <div className="space-y-2 max-h-32 overflow-y-auto">
                  {distanceRanges.map((range) => (
                    <label key={range} className="flex items-center gap-2 cursor-pointer">
                      <input
                        type="checkbox"
                        checked={selectedDistanceRanges.includes(range)}
                        onChange={(e) => {
                          if (e.target.checked) {
                            setSelectedDistanceRanges([...selectedDistanceRanges, range]);
                          } else {
                            setSelectedDistanceRanges(selectedDistanceRanges.filter(r => r !== range));
                          }
                        }}
                        className="w-4 h-4 text-texas-red"
                      />
                      <span className="text-sm text-texas-gray-700">
                        {DISTANCE_RANGE_LABELS[range]}
                      </span>
                    </label>
                  ))}
                </div>
              </div>

              {/* Max Distance */}
              <div>
                <h3 className="font-semibold text-texas-gray-900 mb-3">Max Distance</h3>
                <div className="space-y-3">
                  <Input
                    type="range"
                    min="1"
                    max="25"
                    step="1"
                    value={maxDistance}
                    onChange={(e) => setMaxDistance(parseInt(e.target.value))}
                    className="w-full"
                  />
                  <p className="text-xs text-texas-gray-500 text-center">
                    Up to {maxDistance} miles
                  </p>
                </div>
              </div>
            </div>

            <div className="flex gap-2 mt-6">
              <Button onClick={clearFilters} variant="outline" size="sm">
                Clear All
              </Button>
              <Button onClick={() => setShowFilters(false)} variant="primary" size="sm">
                Apply Filters
              </Button>
            </div>
          </div>
        </div>
      )}

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
              All Categories
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
                {category}
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
            {locationFilter !== 'all' && (
              <span className="ml-2 text-texas-red">
                ({locationFilter === 'on_campus' ? 'On Campus' : 'Off Campus'})
              </span>
            )}
          </p>
        </div>

        {filteredItems.length === 0 ? (
          <div className="text-center py-12">
            <div className="text-6xl mb-4 text-texas-gray-400">Search</div>
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
              <Card 
                key={item.id} 
                variant="elevated" 
                className="hover:scale-105 transition-transform duration-200 cursor-pointer"
                onClick={() => handleItemClick(item)}
              >
                <div className="relative">
                  <img
                    src={item.imageURLs[0]}
                    alt={item.title}
                    className="w-full h-48 object-cover"
                  />
                  <div className="absolute top-3 right-3 bg-texas-red text-white px-2 py-1 rounded-full text-xs font-medium">
                    {item.condition}
                  </div>
                  {/* Location Badge */}
                  <div className="absolute top-3 left-3 bg-white bg-opacity-90 px-2 py-1 rounded-full text-xs font-medium text-texas-gray-800">
                    {item.location.locationType === LocationType.ON_CAMPUS ? 'Campus' : 
                     item.location.exactDistance ? `${item.location.exactDistance.toFixed(1)} mi` : 'Off Campus'}
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
                    <button 
                      className="text-texas-red hover:text-texas-red-600 transition-colors text-sm font-medium"
                      onClick={(e) => handleLikeClick(e, item.id)}
                    >
                      Like ({item.likes})
                    </button>
                  </div>
                  
                  <div className="flex items-center justify-between text-xs text-texas-gray-500 mb-3">
                    <span className="truncate">{getLocationDisplay(item.location)}</span>
                    <span>Views: {item.views}</span>
                  </div>
                  
                  <div className="flex items-center justify-between mt-3 pt-3 border-t border-texas-gray-100">
                    <span className="text-xs text-texas-gray-500">
                      {item.timeAgo}
                    </span>
                    <Button 
                      variant="primary" 
                      size="sm"
                      onClick={(e) => {
                        e.stopPropagation();
                        handleItemClick(item);
                      }}
                    >
                      View Details
                    </Button>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        )}
      </div>

      {/* Item Detail Modal */}
      {selectedItem && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            <div className="relative">
              <img
                src={selectedItem.imageURLs[0]}
                alt={selectedItem.title}
                className="w-full h-64 object-cover"
              />
              <button
                onClick={() => setSelectedItem(null)}
                className="absolute top-4 right-4 bg-white rounded-full p-2 hover:bg-gray-100 transition-colors text-lg font-bold"
              >
                ×
              </button>
            </div>
            
            <div className="p-6">
              <div className="flex items-start justify-between mb-4">
                <div>
                  <h2 className="text-2xl font-bold text-texas-gray-900 mb-2">
                    {selectedItem.title}
                  </h2>
                  <div className="flex items-center gap-2 mb-2">
                    <span className="text-3xl font-bold text-texas-red">
                      ${selectedItem.price}
                    </span>
                    {selectedItem.originalPrice && (
                      <span className="text-lg text-texas-gray-500 line-through">
                        ${selectedItem.originalPrice}
                      </span>
                    )}
                  </div>
                </div>
                <div className={`px-3 py-1 rounded-full text-white text-sm font-medium ${CONDITION_COLORS[selectedItem.condition] || 'bg-gray-500'}`}>
                  {selectedItem.condition}
                </div>
              </div>

              <p className="text-texas-gray-700 mb-6 leading-relaxed">
                {selectedItem.description}
              </p>

              <div className="grid grid-cols-2 gap-4 mb-6">
                <div className="bg-texas-gray-50 p-4 rounded-lg">
                  <h4 className="font-semibold text-texas-gray-900 mb-2">Location</h4>
                  <p className="text-texas-gray-600">{getLocationDisplay(selectedItem.location)}</p>
                  {selectedItem.location.address && (
                    <p className="text-xs text-texas-gray-500 mt-1">{selectedItem.location.address}</p>
                  )}
                </div>
                <div className="bg-texas-gray-50 p-4 rounded-lg">
                  <h4 className="font-semibold text-texas-gray-900 mb-2">Seller</h4>
                  <p className="text-texas-gray-600">{selectedItem.sellerName}</p>
                </div>
                <div className="bg-texas-gray-50 p-4 rounded-lg">
                  <h4 className="font-semibold text-texas-gray-900 mb-2">Views</h4>
                  <p className="text-texas-gray-600">{selectedItem.views}</p>
                </div>
                <div className="bg-texas-gray-50 p-4 rounded-lg">
                  <h4 className="font-semibold text-texas-gray-900 mb-2">Likes</h4>
                  <p className="text-texas-gray-600">{selectedItem.likes}</p>
                </div>
              </div>

              <div className="flex gap-3">
                <Button 
                  variant="primary" 
                  className="flex-1"
                  onClick={() => handleContactSeller(selectedItem)}
                  disabled={contactingseller}
                >
                  {contactingseller ? 'Starting Chat...' : 'Contact Seller'}
                </Button>
                <Button 
                  variant="outline"
                  onClick={(e) => handleLikeClick(e, selectedItem.id)}
                >
                  Like
                </Button>
              </div>

              {selectedItem.sellerId === (currentUser?.id || 'current-user') && (
                <p className="text-center text-xs text-texas-gray-500 mt-4">
                  This is your own listing
                </p>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
} 