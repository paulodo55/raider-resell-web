'use client';

import { createContext, useContext, useState, ReactNode } from 'react';
import { Chat, Message } from '@/types';

interface ChatStoreContextType {
  createChatWithSeller: (itemId: string, itemTitle: string, itemImageURL: string, sellerId: string, sellerName: string) => Promise<string>;
  navigateToChat: (chatId: string) => void;
  onChatNavigate?: (chatId: string) => void;
  setOnChatNavigate: (callback: (chatId: string) => void) => void;
}

const ChatStoreContext = createContext<ChatStoreContextType | undefined>(undefined);

interface ChatStoreProviderProps {
  children: ReactNode;
}

export function ChatStoreProvider({ children }: ChatStoreProviderProps) {
  const [onChatNavigate, setOnChatNavigate] = useState<((chatId: string) => void) | undefined>();

  const createChatWithSeller = async (
    itemId: string, 
    itemTitle: string, 
    itemImageURL: string, 
    sellerId: string, 
    sellerName: string
  ): Promise<string> => {
    // In a real app, this would create a chat in the database
    // For demo purposes, we'll return a mock chat ID
    const chatId = `chat_${itemId}_${Date.now()}`;
    
    // Simulate API delay
    await new Promise(resolve => setTimeout(resolve, 500));
    
    return chatId;
  };

  const navigateToChat = (chatId: string) => {
    if (onChatNavigate) {
      onChatNavigate(chatId);
    }
  };

  return (
    <ChatStoreContext.Provider value={{
      createChatWithSeller,
      navigateToChat,
      onChatNavigate,
      setOnChatNavigate
    }}>
      {children}
    </ChatStoreContext.Provider>
  );
}

export function useChatStore() {
  const context = useContext(ChatStoreContext);
  if (context === undefined) {
    throw new Error('useChatStore must be used within a ChatStoreProvider');
  }
  return context;
} 