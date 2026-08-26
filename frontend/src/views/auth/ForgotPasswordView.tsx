import React, { useState } from 'react';
import { api } from '../../api/client';
import { Mail, KeyRound, Lock, ArrowLeft, CheckCircle2, AlertCircle, Eye, EyeOff } from 'lucide-react';

interface ForgotPasswordViewProps {
  onBackToLogin: () => void;
}

export const ForgotPasswordView: React.FC<ForgotPasswordViewProps> = ({ onBackToLogin }) => {
  const [step, setStep] = useState<'REQUEST' | 'VERIFY' | 'DONE'>('REQUEST');
  const [email, setEmail] = useState('');
  const [otp, setOtp] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [showNewPassword, setShowNewPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const handleOtpChange = (val: string) => {
    if (/[^0-9]/.test(val)) {
      setError('OTP must contain digits (0-9) only.');
      return;
    }
    setError(null);
    setOtp(val);
  };

  const handleRequestOtp = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    if (!email.trim()) {
      setError('Please enter your registered email address.');
      return;
    }

    setIsLoading(true);
    try {
      await api.post('/auth/forgot-password', { email: email.trim() });
      setStep('VERIFY');
      setMessage(`A 6-digit security OTP code has been dispatched to ${email}. Code expires in 2 minutes.`);
    } catch (err: any) {
      setError(err.response?.data?.message || 'Unable to dispatch OTP. Please check your email.');
    } finally {
      setIsLoading(false);
    }
  };

  const handleResetPassword = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    if (!otp.trim() || !newPassword.trim()) {
      setError('Please enter both the OTP and your new password.');
      return;
    }
    if (newPassword !== confirmPassword) {
      setError('Passwords do not match.');
      return;
    }

    setIsLoading(true);
    try {
      await api.post('/auth/reset-password', {
        email: email.trim(),
        otp: otp.trim(),
        newPassword: newPassword.trim(),
      });
      setStep('DONE');
    } catch (err: any) {
      setError(err.response?.data?.message || 'Invalid or expired OTP.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div style={{
      minHeight: 'calc(100vh - 70px)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      padding: '24px 16px',
      background: 'linear-gradient(135deg, #0B192C 0%, #0F172A 50%, #1E293B 100%)',
    }}>
      <div style={{ width: '100%', maxWidth: '440px' }}>
        <button
          onClick={onBackToLogin}
          className="btn btn-outline"
          style={{ color: 'white', borderColor: 'rgba(255,255,255,0.2)', marginBottom: '16px', fontSize: '13px' }}
        >
          <ArrowLeft size={16} /> Back to Sign In
        </button>

        <div className="glass-card animate-fade-in card-watermark" style={{ padding: '32px 28px', backgroundColor: '#FFFFFF' }}>
          <div style={{ textAlign: 'center', marginBottom: '24px' }}>
            <div style={{ display: 'flex', justifyContent: 'center', marginBottom: '12px' }}>
              <img
                src="/images/logo-3d.jpg"
                alt="ThutoTech 3D Logo"
                style={{
                  width: '74px',
                  height: '74px',
                  borderRadius: '16px',
                  boxShadow: '0 6px 18px rgba(22, 196, 127, 0.3)',
                  objectFit: 'cover',
                }}
              />
            </div>
            <div style={{ fontSize: '11px', color: 'var(--text-muted)', letterSpacing: '0.04em', marginBottom: '6px', fontWeight: '700' }}>
              THUTOTECH • LEARN • CONNECT • EMPOWER
            </div>
            <h2 style={{ fontSize: '22px', fontWeight: '800', color: 'var(--primary-navy)', fontFamily: 'var(--font-heading)' }}>
              {step === 'REQUEST' && 'Reset Account Password'}
              {step === 'VERIFY' && 'Enter Verification OTP'}
              {step === 'DONE' && 'Password Reset Complete'}
            </h2>
            <p style={{ fontSize: '13px', color: 'var(--text-muted)', marginTop: '4px' }}>
              {step === 'REQUEST' && 'Enter your verified account email to receive a single-use OTP code.'}
              {step === 'VERIFY' && 'Check your email inbox for your 6-digit verification code.'}
              {step === 'DONE' && 'Your credentials have been securely updated.'}
            </p>
          </div>

          {error && (
            <div style={{
              background: '#FEE2E2',
              border: '1px solid #FECACA',
              color: 'var(--danger-red)',
              padding: '12px',
              borderRadius: 'var(--radius-md)',
              fontSize: '13px',
              display: 'flex',
              alignItems: 'center',
              gap: '8px',
              marginBottom: '20px',
            }}>
              <AlertCircle size={18} style={{ flexShrink: 0 }} />
              <span>{error}</span>
            </div>
          )}

          {message && (
            <div style={{
              background: 'rgba(22, 196, 127, 0.1)',
              border: '1px solid var(--primary-green)',
              color: 'var(--primary-navy)',
              padding: '12px',
              borderRadius: 'var(--radius-md)',
              fontSize: '13px',
              display: 'flex',
              alignItems: 'center',
              gap: '8px',
              marginBottom: '20px',
            }}>
              <CheckCircle2 size={18} color="var(--primary-green)" style={{ flexShrink: 0 }} />
              <span>{message}</span>
            </div>
          )}

          {step === 'REQUEST' && (
            <form onSubmit={handleRequestOtp}>
              <div className="form-group">
                <label className="form-label">Registered Account Email</label>
                <div style={{ position: 'relative' }}>
                  <input
                    type="email"
                    className="form-control"
                    style={{ paddingLeft: '40px' }}
                    placeholder="e.g. parent@gmail.com"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    required
                    disabled={isLoading}
                  />
                  <Mail size={18} style={{ position: 'absolute', left: '12px', top: '12px', color: 'var(--text-muted)' }} />
                </div>
              </div>

              <button
                type="submit"
                className="btn btn-primary"
                style={{ width: '100%', padding: '12px', fontSize: '14px', marginTop: '12px' }}
                disabled={isLoading}
              >
                {isLoading ? 'Dispatching OTP...' : 'Send Security OTP'}
              </button>
            </form>
          )}

          {step === 'VERIFY' && (
            <form onSubmit={handleResetPassword}>
              <div className="form-group">
                <label className="form-label">6-Digit OTP Code *</label>
                <div style={{ position: 'relative' }}>
                  <input
                    type="text"
                    className="form-control"
                    style={{ paddingLeft: '40px', letterSpacing: '4px', fontWeight: 'bold', fontSize: '16px' }}
                    placeholder="123456"
                    maxLength={6}
                    value={otp}
                    onChange={(e) => handleOtpChange(e.target.value)}
                    required
                  />
                  <KeyRound size={18} style={{ position: 'absolute', left: '12px', top: '12px', color: 'var(--text-muted)' }} />
                </div>
              </div>

              <div className="form-group">
                <label className="form-label">New Password *</label>
                <div style={{ position: 'relative' }}>
                  <input
                    type={showNewPassword ? 'text' : 'password'}
                    className="form-control"
                    style={{ paddingLeft: '40px', paddingRight: '40px' }}
                    placeholder="••••••••••••"
                    value={newPassword}
                    onChange={(e) => setNewPassword(e.target.value)}
                    required
                  />
                  <Lock size={18} style={{ position: 'absolute', left: '12px', top: '12px', color: 'var(--text-muted)' }} />
                  <button
                    type="button"
                    onClick={() => setShowNewPassword(!showNewPassword)}
                    style={{ position: 'absolute', right: '12px', top: '10px', background: 'none', border: 'none', cursor: 'pointer', color: 'var(--text-muted)' }}
                  >
                    {showNewPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                  </button>
                </div>
              </div>

              <div className="form-group">
                <label className="form-label">Confirm New Password *</label>
                <div style={{ position: 'relative' }}>
                  <input
                    type="password"
                    className="form-control"
                    style={{ paddingLeft: '40px' }}
                    placeholder="••••••••••••"
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    required
                  />
                  <Lock size={18} style={{ position: 'absolute', left: '12px', top: '12px', color: 'var(--text-muted)' }} />
                </div>
              </div>

              <button
                type="submit"
                className="btn btn-primary"
                style={{ width: '100%', padding: '12px', fontSize: '14px', marginTop: '12px' }}
                disabled={isLoading}
              >
                {isLoading ? 'Resetting Password...' : 'Save New Password'}
              </button>
            </form>
          )}

          {step === 'DONE' && (
            <div style={{ textAlign: 'center' }}>
              <div style={{
                background: 'rgba(22, 196, 127, 0.1)',
                padding: '20px',
                borderRadius: '12px',
                marginBottom: '20px',
                color: 'var(--primary-navy)',
                fontSize: '14px',
              }}>
                🎉 Your account password has been successfully updated. You may now sign in using your new credentials.
              </div>
              <button onClick={onBackToLogin} className="btn btn-primary" style={{ width: '100%', padding: '12px' }}>
                Sign In Now
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
