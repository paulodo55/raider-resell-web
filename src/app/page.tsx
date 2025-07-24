'use client';

import { useAuth } from '@/hooks/useAuth';
import AuthenticationPage from '@/components/auth/AuthenticationPage';
import MarketplacePage from '@/components/marketplace/MarketplacePage';
import LoadingSpinner from '@/components/ui/LoadingSpinner';

export default function HomePage() {
  const { currentUser, loading } = useAuth();

  if (loading) {
    return <LoadingSpinner />;
  }

  return currentUser ? <MarketplacePage /> : <AuthenticationPage />;
} 