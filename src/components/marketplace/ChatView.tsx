'use client';

import { useState, useEffect, useRef } from 'react';
import { useAuth } from '@/hooks/useAuth';
import { Card, CardContent } from '@/components/ui/Card';
import Button from '@/components/ui/Button';
import Input from '@/components/ui/Input';
import { Chat, Message, MessageType, MessageStatus, Offer, OfferStatus } from '@/types';

// Mock chat data
const mockChats: Chat[] = [
  {
    id: '1',
    itemID: '1',
    itemTitle: 'MacBook Pro 13" 2022',
    itemImageURL: 'https://via.placeholder.com/60x60?text=MacBook',
    buyerID: 'current-user',
    buyerName: 'Demo User',
    sellerID: 'seller-1',
    sellerName: 'John Doe',
    unreadCount: 2,
    isActive: true,
    createdAt: new Date(Date.now() - 2 * 60 * 60 * 1000),
    updatedAt: new Date(Date.now() - 30 * 60 * 1000)
  },
  {
    id: '2',
    itemID: '2',
    itemTitle: 'Introduction to Algorithms Textbook',
    itemImageURL: 'https://via.placeholder.com/60x60?text=Textbook',
    buyerID: 'current-user',
    buyerName: 'Demo User',
    sellerID: 'seller-2',
    sellerName: 'Sarah Smith',
    unreadCount: 0,
    isActive: true,
    createdAt: new Date(Date.now() - 24 * 60 * 60 * 1000),
    updatedAt: new Date(Date.now() - 3 * 60 * 60 * 1000)
  },
  {
    id: '3',
    itemID: '3',
    itemTitle: 'Texas Tech Hoodie',
    itemImageURL: 'https://via.placeholder.com/60x60?text=Hoodie',
    buyerID: 'buyer-1',
    buyerName: 'Mike Johnson',
    sellerID: 'current-user',
    sellerName: 'Demo User',
    unreadCount: 1,
    isActive: true,
    createdAt: new Date(Date.now() - 48 * 60 * 60 * 1000),
    updatedAt: new Date(Date.now() - 6 * 60 * 60 * 1000)
  }
];

const mockMessages: { [chatId: string]: Message[] } = {
  '1': [
    {
      id: 'm1',
      chatID: '1',
      senderID: 'seller-1',
      senderName: 'John Doe',
      type: MessageType.TEXT,
      content: 'Hi! Thanks for your interest in the MacBook Pro. It\'s in excellent condition.',
      status: MessageStatus.READ,
      createdAt: new Date(Date.now() - 2 * 60 * 60 * 1000),
      updatedAt: new Date(Date.now() - 2 * 60 * 60 * 1000)
    },
    {
      id: 'm2',
      chatID: '1',
      senderID: 'current-user',
      senderName: 'Demo User',
      type: MessageType.TEXT,
      content: 'Great! Would you be willing to negotiate on the price?',
      status: MessageStatus.READ,
      createdAt: new Date(Date.now() - 90 * 60 * 1000),
      updatedAt: new Date(Date.now() - 90 * 60 * 1000)
    },
    {
      id: 'm3',
      chatID: '1',
      senderID: 'seller-1',
      senderName: 'John Doe',
      type: MessageType.TEXT,
      content: 'I could do $850. That\'s the lowest I can go.',
      status: MessageStatus.DELIVERED,
      createdAt: new Date(Date.now() - 30 * 60 * 1000),
      updatedAt: new Date(Date.now() - 30 * 60 * 1000)
    }
  ],
  '2': [
    {
      id: 'm4',
      chatID: '2',
      senderID: 'current-user',
      senderName: 'Demo User',
      type: MessageType.TEXT,
      content: 'Is this textbook still available?',
      status: MessageStatus.READ,
      createdAt: new Date(Date.now() - 4 * 60 * 60 * 1000),
      updatedAt: new Date(Date.now() - 4 * 60 * 60 * 1000)
    },
    {
      id: 'm5',
      chatID: '2',
      senderID: 'seller-2',
      senderName: 'Sarah Smith',
      type: MessageType.TEXT,
      content: 'Yes! It\'s still available. When would you like to meet?',
      status: MessageStatus.READ,
      createdAt: new Date(Date.now() - 3 * 60 * 60 * 1000),
      updatedAt: new Date(Date.now() - 3 * 60 * 60 * 1000)
    }
  ],
  '3': [
    {
      id: 'm6',
      chatID: '3',
      senderID: 'buyer-1',
      senderName: 'Mike Johnson',
      type: MessageType.TEXT,
      content: 'Hey! I\'m interested in the Texas Tech hoodie. Is it still available?',
      status: MessageStatus.DELIVERED,
      createdAt: new Date(Date.now() - 6 * 60 * 60 * 1000),
      updatedAt: new Date(Date.now() - 6 * 60 * 60 * 1000)
    }
  ]
};

export default function ChatView() {
  const { currentUser } = useAuth();
  const [chats, setChats] = useState<Chat[]>(mockChats);
  const [selectedChat, setSelectedChat] = useState<Chat | null>(null);
  const [messages, setMessages] = useState<{ [chatId: string]: Message[] }>(mockMessages);
  const [newMessage, setNewMessage] = useState('');
  const [loading, setLoading] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    if (selectedChat) {
      scrollToBottom();
      // Mark messages as read
      markMessagesAsRead(selectedChat.id);
    }
  }, [selectedChat, messages]);

  const markMessagesAsRead = (chatId: string) => {
    setChats(prev => prev.map(chat => 
      chat.id === chatId ? { ...chat, unreadCount: 0 } : chat
    ));
  };

  const sendMessage = async () => {
    if (!selectedChat || !newMessage.trim() || !currentUser) return;

    const message: Message = {
      id: `m${Date.now()}`,
      chatID: selectedChat.id,
      senderID: currentUser.id || 'current-user',
      senderName: `${currentUser.firstName} ${currentUser.lastName}`,
      type: MessageType.TEXT,
      content: newMessage.trim(),
      status: MessageStatus.SENT,
      createdAt: new Date(),
      updatedAt: new Date()
    };

    // Add message
    setMessages(prev => ({
      ...prev,
      [selectedChat.id]: [...(prev[selectedChat.id] || []), message]
    }));

    // Update chat's last message and timestamp
    setChats(prev => prev.map(chat =>
      chat.id === selectedChat.id
        ? { ...chat, lastMessage: message, updatedAt: new Date() }
        : chat
    ));

    setNewMessage('');

    // Simulate delivery after a short delay
    setTimeout(() => {
      setMessages(prev => ({
        ...prev,
        [selectedChat.id]: prev[selectedChat.id].map(msg =>
          msg.id === message.id ? { ...msg, status: MessageStatus.DELIVERED } : msg
        )
      }));
    }, 1000);

    // Simulate a response from the other party
    setTimeout(() => {
      const isUserSeller = selectedChat.sellerID === (currentUser.id || 'current-user');
      const responseFrom = isUserSeller ? selectedChat.buyerName : selectedChat.sellerName;
      const responseFromId = isUserSeller ? selectedChat.buyerID : selectedChat.sellerID;
      
      const responses = [
        "Thanks for your message! I'll get back to you soon.",
        "That sounds good to me!",
        "Let me think about it and I'll let you know.",
        "When would be a good time to meet?",
        "I'm flexible on the price. What did you have in mind?"
      ];

      const randomResponse = responses[Math.floor(Math.random() * responses.length)];

      const responseMessage: Message = {
        id: `m${Date.now()}_response`,
        chatID: selectedChat.id,
        senderID: responseFromId,
        senderName: responseFrom,
        type: MessageType.TEXT,
        content: randomResponse,
        status: MessageStatus.DELIVERED,
        createdAt: new Date(),
        updatedAt: new Date()
      };

      setMessages(prev => ({
        ...prev,
        [selectedChat.id]: [...(prev[selectedChat.id] || []), responseMessage]
      }));

      setChats(prev => prev.map(chat =>
        chat.id === selectedChat.id
          ? { 
              ...chat, 
              lastMessage: responseMessage, 
              updatedAt: new Date(),
              unreadCount: chat.id === selectedChat.id && selectedChat ? 0 : chat.unreadCount + 1
            }
          : chat
      ));
    }, 3000 + Math.random() * 2000); // Random delay between 3-5 seconds
  };

  const formatTime = (date: Date) => {
    const now = new Date();
    const diffInMinutes = Math.floor((now.getTime() - date.getTime()) / (1000 * 60));
    
    if (diffInMinutes < 1) return 'Just now';
    if (diffInMinutes < 60) return `${diffInMinutes}m ago`;
    if (diffInMinutes < 1440) return `${Math.floor(diffInMinutes / 60)}h ago`;
    return `${Math.floor(diffInMinutes / 1440)}d ago`;
  };

  const getLastMessagePreview = (chat: Chat) => {
    const chatMessages = messages[chat.id] || [];
    const lastMessage = chatMessages[chatMessages.length - 1];
    
    if (!lastMessage) return 'Start a conversation...';
    
    const isCurrentUser = lastMessage.senderID === (currentUser?.id || 'current-user');
    const prefix = isCurrentUser ? 'You: ' : '';
    
    return `${prefix}${lastMessage.content}`;
  };

  if (!selectedChat) {
    return (
      <div className="min-h-screen bg-texas-gray-50 md:ml-64">
        {/* Header */}
        <div className="bg-white border-b border-texas-gray-200 px-4 py-6">
          <div className="max-w-7xl mx-auto">
            <h1 className="text-2xl font-bold text-texas-gray-900">
              Messages
            </h1>
            <p className="text-texas-gray-600">
              Chat with buyers and sellers
            </p>
          </div>
        </div>

        {/* Chat List */}
        <div className="max-w-4xl mx-auto px-4 py-8">
          {chats.length === 0 ? (
            <div className="text-center py-12">
              <div className="text-6xl mb-4 text-texas-gray-400">Chat</div>
              <h3 className="text-xl font-semibold text-texas-gray-900 mb-2">
                No conversations yet
              </h3>
              <p className="text-texas-gray-600">
                Start chatting by contacting sellers from the marketplace
              </p>
            </div>
          ) : (
            <div className="space-y-4">
              {chats
                .sort((a, b) => b.updatedAt.getTime() - a.updatedAt.getTime())
                .map((chat) => (
                <Card
                  key={chat.id}
                  variant="elevated"
                  className="hover:shadow-lg transition-shadow cursor-pointer"
                  onClick={() => setSelectedChat(chat)}
                >
                  <CardContent className="p-4">
                    <div className="flex items-center gap-4">
                      <img
                        src={chat.itemImageURL}
                        alt={chat.itemTitle}
                        className="w-16 h-16 rounded-lg object-cover"
                      />
                      
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center justify-between mb-1">
                          <h3 className="font-semibold text-texas-gray-900 truncate">
                            {chat.itemTitle}
                          </h3>
                          <span className="text-xs text-texas-gray-500">
                            {formatTime(chat.updatedAt)}
                          </span>
                        </div>
                        
                        <p className="text-sm text-texas-gray-600 mb-2">
                          with {currentUser?.id === chat.sellerID ? chat.buyerName : chat.sellerName}
                        </p>
                        
                        <p className="text-sm text-texas-gray-700 truncate">
                          {getLastMessagePreview(chat)}
                        </p>
                      </div>
                      
                      {chat.unreadCount > 0 && (
                        <div className="bg-texas-red text-white rounded-full w-6 h-6 flex items-center justify-center text-xs font-medium">
                          {chat.unreadCount}
                        </div>
                      )}
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

  // Chat Window View
  const chatMessages = messages[selectedChat.id] || [];
  const otherPerson = currentUser?.id === selectedChat.sellerID ? selectedChat.buyerName : selectedChat.sellerName;

  return (
    <div className="min-h-screen bg-texas-gray-50 md:ml-64 flex flex-col">
      {/* Chat Header */}
      <div className="bg-white border-b border-texas-gray-200 px-4 py-4 flex-shrink-0">
        <div className="flex items-center gap-4">
          <Button
            variant="outline"
            size="sm"
            onClick={() => setSelectedChat(null)}
          >
            Back
          </Button>
          
          <img
            src={selectedChat.itemImageURL}
            alt={selectedChat.itemTitle}
            className="w-12 h-12 rounded-lg object-cover"
          />
          
          <div className="flex-1 min-w-0">
            <h2 className="font-semibold text-texas-gray-900 truncate">
              {selectedChat.itemTitle}
            </h2>
            <p className="text-sm text-texas-gray-600">
              with {otherPerson}
            </p>
          </div>
        </div>
      </div>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto px-4 py-6">
        <div className="max-w-4xl mx-auto space-y-4">
          {chatMessages.map((message) => {
            const isCurrentUser = message.senderID === (currentUser?.id || 'current-user');
            
            return (
              <div
                key={message.id}
                className={`flex ${isCurrentUser ? 'justify-end' : 'justify-start'}`}
              >
                <div className={`max-w-xs lg:max-w-md px-4 py-2 rounded-lg ${
                  isCurrentUser
                    ? 'bg-texas-red text-white'
                    : 'bg-white border border-texas-gray-200 text-texas-gray-900'
                }`}>
                  <p className="text-sm">{message.content}</p>
                  <div className={`flex items-center gap-1 mt-1 text-xs ${
                    isCurrentUser ? 'text-texas-red-100' : 'text-texas-gray-500'
                  }`}>
                    <span>{formatTime(message.createdAt)}</span>
                    {isCurrentUser && (
                      <span>
                        {message.status === MessageStatus.SENT && 'Sent'}
                        {message.status === MessageStatus.DELIVERED && 'Delivered'}
                        {message.status === MessageStatus.READ && 'Read'}
                      </span>
                    )}
                  </div>
                </div>
              </div>
            );
          })}
          <div ref={messagesEndRef} />
        </div>
      </div>

      {/* Message Input */}
      <div className="bg-white border-t border-texas-gray-200 px-4 py-4 flex-shrink-0">
        <div className="max-w-4xl mx-auto">
          <div className="flex gap-2">
            <Input
              placeholder="Type your message..."
              value={newMessage}
              onChange={(e) => setNewMessage(e.target.value)}
              onKeyPress={(e) => {
                if (e.key === 'Enter' && !e.shiftKey) {
                  e.preventDefault();
                  sendMessage();
                }
              }}
              className="flex-1"
            />
            <Button
              onClick={sendMessage}
              disabled={!newMessage.trim() || loading}
              variant="primary"
            >
              Send
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
} 