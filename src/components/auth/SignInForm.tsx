'use client';

import { useState } from 'react';
import { useAuth } from '@/hooks/useAuth';
import Button from '@/components/ui/Button';
import Input from '@/components/ui/Input';
import { APP_CONSTANTS } from '@/utils/constants';

interface SignInFormProps {
  onSwitchToSignUp: () => void;
}

export default function SignInForm({ onSwitchToSignUp }: SignInFormProps) {
  const { signIn, resetPassword, loading } = useAuth();
  const [formData, setFormData] = useState({
    email: '',
    password: ''
  });
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [showForgotPassword, setShowForgotPassword] = useState(false);

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: '' }));
    }
  };

  const validateForm = () => {
    const newErrors: Record<string, string> = {};

    if (!formData.email) {
      newErrors.email = 'Email is required';
    } else if (!formData.email.toLowerCase().endsWith(APP_CONSTANTS.VALIDATION.TEXAS_TECH_EMAIL_SUFFIX)) {
      newErrors.email = APP_CONSTANTS.ERROR_MESSAGES.INVALID_EMAIL;
    }

    if (!formData.password) {
      newErrors.password = 'Password is required';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!validateForm()) return;

    await signIn(formData.email, formData.password);
  };

  const handleForgotPassword = async () => {
    if (!formData.email) {
      setErrors({ email: 'Please enter your email address first' });
      return;
    }

    await resetPassword(formData.email);
    setShowForgotPassword(false);
  };

  return (
    <div className="p-8">
      <div className="text-center mb-8">
        <h2 className="text-2xl font-bold text-texas-gray-900 mb-2">
          Welcome Back
        </h2>
        <p className="text-texas-gray-600">
          Sign in to your Raider ReSell account
        </p>
      </div>

      <form onSubmit={handleSubmit} className="space-y-6">
        <Input
          label="Texas Tech Email"
          type="email"
          name="email"
          value={formData.email}
          onChange={handleInputChange}
          placeholder="your.email@ttu.edu"
          error={errors.email}
          autoComplete="email"
        />

        <Input
          label="Password"
          type="password"
          name="password"
          value={formData.password}
          onChange={handleInputChange}
          placeholder="Enter your password"
          error={errors.password}
          autoComplete="current-password"
        />

        <div className="flex items-center justify-between">
          <div></div>
          <button
            type="button"
            onClick={() => setShowForgotPassword(true)}
            className="text-sm text-texas-red hover:text-texas-red-600 transition-colors"
          >
            Forgot password?
          </button>
        </div>

        <Button
          type="submit"
          variant="primary"
          size="lg"
          className="w-full"
          loading={loading}
          disabled={loading}
        >
          Sign In
        </Button>

        <div className="text-center">
          <p className="text-texas-gray-600">
            Don&apos;t have an account?{' '}
            <button
              type="button"
              onClick={onSwitchToSignUp}
              className="text-texas-red hover:text-texas-red-600 font-medium transition-colors"
            >
              Sign Up
            </button>
          </p>
        </div>
      </form>

      {/* Forgot Password Modal */}
      {showForgotPassword && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-xl p-6 w-full max-w-md">
            <h3 className="text-lg font-semibold text-texas-gray-900 mb-4">
              Reset Password
            </h3>
            <p className="text-texas-gray-600 mb-4 text-sm">
              Enter your Texas Tech email address to receive a password reset link.
            </p>
            <div className="flex gap-3">
              <Button
                variant="outline"
                onClick={() => setShowForgotPassword(false)}
                className="flex-1"
              >
                Cancel
              </Button>
              <Button
                variant="primary"
                onClick={handleForgotPassword}
                className="flex-1"
                loading={loading}
              >
                Send Reset Email
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
} 