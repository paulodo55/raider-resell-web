'use client';

import { useState } from 'react';
import { useAuth } from '@/hooks/useAuth';
import Button from '@/components/ui/Button';
import Input from '@/components/ui/Input';
import { APP_CONSTANTS } from '@/utils/constants';

interface SignUpFormProps {
  onSwitchToSignIn: () => void;
}

export default function SignUpForm({ onSwitchToSignIn }: SignUpFormProps) {
  const { signUp, loading } = useAuth();
  const [formData, setFormData] = useState({
    firstName: '',
    lastName: '',
    email: '',
    studentID: '',
    graduationYear: new Date().getFullYear() + 4,
    password: '',
    confirmPassword: ''
  });
  const [errors, setErrors] = useState<Record<string, string>>({});

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ 
      ...prev, 
      [name]: name === 'graduationYear' ? parseInt(value) : value 
    }));
    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: '' }));
    }
  };

  const validateForm = () => {
    const newErrors: Record<string, string> = {};

    if (!formData.firstName.trim()) {
      newErrors.firstName = 'First name is required';
    }

    if (!formData.lastName.trim()) {
      newErrors.lastName = 'Last name is required';
    }

    if (!formData.email) {
      newErrors.email = 'Email is required';
    } else if (!formData.email.toLowerCase().endsWith(APP_CONSTANTS.VALIDATION.TEXAS_TECH_EMAIL_SUFFIX)) {
      newErrors.email = APP_CONSTANTS.ERROR_MESSAGES.INVALID_EMAIL;
    }

    if (!formData.studentID) {
      newErrors.studentID = 'Student ID is required';
    } else if (
      formData.studentID.length < APP_CONSTANTS.VALIDATION.STUDENT_ID_MIN_LENGTH ||
      formData.studentID.length > APP_CONSTANTS.VALIDATION.STUDENT_ID_MAX_LENGTH ||
      !/^\d+$/.test(formData.studentID)
    ) {
      newErrors.studentID = APP_CONSTANTS.ERROR_MESSAGES.INVALID_STUDENT_ID;
    }

    if (!formData.password) {
      newErrors.password = 'Password is required';
    } else if (formData.password.length < APP_CONSTANTS.VALIDATION.PASSWORD_MIN_LENGTH) {
      newErrors.password = APP_CONSTANTS.ERROR_MESSAGES.PASSWORD_TOO_SHORT;
    }

    if (!formData.confirmPassword) {
      newErrors.confirmPassword = 'Please confirm your password';
    } else if (formData.password !== formData.confirmPassword) {
      newErrors.confirmPassword = APP_CONSTANTS.ERROR_MESSAGES.PASSWORD_MISMATCH;
    }

    const currentYear = new Date().getFullYear();
    if (formData.graduationYear < currentYear || formData.graduationYear > currentYear + 6) {
      newErrors.graduationYear = 'Please select a valid graduation year';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!validateForm()) return;

    const success = await signUp(formData.email, formData.password, {
      firstName: formData.firstName.trim(),
      lastName: formData.lastName.trim(),
      studentID: formData.studentID,
      graduationYear: formData.graduationYear
    });

    if (success) {
      // User will be automatically redirected by the auth context
    }
  };

  const graduationYears = Array.from(
    { length: 7 }, 
    (_, i) => new Date().getFullYear() + i
  );

  return (
    <div className="p-8">
      <div className="text-center mb-8">
        <div className="flex items-center justify-center mb-4">
          <button
            onClick={onSwitchToSignIn}
            className="absolute left-8 text-texas-red hover:text-texas-red-600 transition-colors"
          >
            ← Back
          </button>
          <h2 className="text-2xl font-bold text-texas-gray-900">
            Join Raider ReSell
          </h2>
        </div>
        <p className="text-texas-gray-600">
          Create your account to start buying and selling
        </p>
      </div>

      <form onSubmit={handleSubmit} className="space-y-6">
        <div className="grid grid-cols-2 gap-4">
          <Input
            label="First Name"
            type="text"
            name="firstName"
            value={formData.firstName}
            onChange={handleInputChange}
            placeholder="First"
            error={errors.firstName}
            autoComplete="given-name"
          />

          <Input
            label="Last Name"
            type="text"
            name="lastName"
            value={formData.lastName}
            onChange={handleInputChange}
            placeholder="Last"
            error={errors.lastName}
            autoComplete="family-name"
          />
        </div>

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
          label="Student ID"
          type="text"
          name="studentID"
          value={formData.studentID}
          onChange={handleInputChange}
          placeholder="12345678"
          error={errors.studentID}
          maxLength={9}
        />

        <div>
          <label className="block text-sm font-medium text-texas-gray-700 mb-2">
            Expected Graduation Year
          </label>
          <select
            name="graduationYear"
            value={formData.graduationYear}
            onChange={handleInputChange}
            className="w-full px-4 py-3 border border-texas-gray-300 rounded-lg focus:ring-2 focus:ring-texas-red-500 focus:border-transparent text-texas-gray-900 transition-all duration-200"
          >
            {graduationYears.map(year => (
              <option key={year} value={year}>
                {year}
              </option>
            ))}
          </select>
          {errors.graduationYear && (
            <p className="mt-1 text-sm text-red-600">{errors.graduationYear}</p>
          )}
        </div>

        <Input
          label="Password"
          type="password"
          name="password"
          value={formData.password}
          onChange={handleInputChange}
          placeholder="Enter password"
          error={errors.password}
          autoComplete="new-password"
        />

        <Input
          label="Confirm Password"
          type="password"
          name="confirmPassword"
          value={formData.confirmPassword}
          onChange={handleInputChange}
          placeholder="Confirm password"
          error={errors.confirmPassword}
          autoComplete="new-password"
        />

        <Button
          type="submit"
          variant="primary"
          size="lg"
          className="w-full"
          loading={loading}
          disabled={loading}
        >
          Create Account
        </Button>

        <div className="text-center">
          <p className="text-texas-gray-600">
            Already have an account?{' '}
            <button
              type="button"
              onClick={onSwitchToSignIn}
              className="text-texas-red hover:text-texas-red-600 font-medium transition-colors"
            >
              Sign In
            </button>
          </p>
        </div>
      </form>
    </div>
  );
} 