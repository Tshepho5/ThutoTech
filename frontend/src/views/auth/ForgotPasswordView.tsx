import React, { useState } from 'react';
import { api } from '../../api/client';
import { Mail, KeyRound, Lock, ArrowLeft, CheckCircle2, AlertCircle } from 'lucide-react';

interface ForgotPasswordViewProps {
  onBackToLogin: () => void;
}

export const ForgotPasswordView: React.FC<ForgotPasswordViewProps> = ({ onBackToLogin }) => {
  const [step, setStep] = useState<'REQUEST' | 'VERIFY' | 'DONE'>('REQUEST');
  const [email, setEmail] = useState('');
  const [otp, setOtp] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

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

        <div className="glass-card animate-fade-in" style={{ padding: '32px 28px', backgroundColor: '#FFFFFF' }}>
          <h2 style={{ fontSize: '22px', fontWeight: '800', color: 'var(--primary-navy)', marginBottom: '8px' }}>
            Password Recovery
          </h2>

          {error && (
            <div style={{ background: '#FEE2E2', border: '1px solid #FECACA', color: 'var(--danger-red)', padding: '10px 14px', borderRadius: '10px', fontSize: '13px', display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '16px' }}>
              <AlertCircle size={16} />
              <span>{error}</span>
            </div>
          )}

          {message && (
            <div style={{ background: 'rgba(22, 196, 127, 0.12)', border: '1px solid var(--primary-green)', color: '#0F766E', padding: '10px 14px', borderRadius: '10px', fontSize: '13px', display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '16px' }}>
              <CheckCircle2 size={16} />
              <span>{message}</span>
            </div>
          )}

          {step === 'REQUEST' && (
            <form onSubmit={handleRequestOtp}>
              <p style={{ fontSize: '13px', color: 'var(--text-muted)', marginBottom: '16px' }}>
                Enter your registered ThutoTech account email to receive a secure 2-minute OTP.
              </p>
              <div className="form-group">
                <label className="form-label">Email Address</label>
                <div style={{ position: 'relative' }}>
                  <input
                    type="email"
                    className="form-control"
                    style={{ paddingLeft: '38px' }}
                    placeholder="user@thutotech.co.za"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    disabled={isLoading}
                  />
                  <Mail size={16} style={{ position: 'absolute', left: '12px', top: '12px', color: 'var(--text-muted)' }} />
                </div>
              </div>
              <button type="submit" className="btn btn-primary" style={{ width: '100%', padding: '12px' }} disabled={isLoading}>
                {isLoading ? 'Dispatching OTP...' : 'Send 2-Minute Security OTP'}
              </button>
            </form>
          )}

          {step === 'VERIFY' && (
            <form onSubmit={handleResetPassword}>
              <div className="form-group">
                <label className="form-label">6-Digit Security OTP</label>
                <div style={{ position: 'relative' }}>
                  <input
                    type="text"
                    maxLength={6}
                    className="form-control"
                    style={{ paddingLeft: '38px', letterSpacing: '4px', fontWeight: 'bold' }}
                    placeholder="123456"
                    value={otp}
                    onChange={(e) => setOtp(e.target.value)}
                  />
                  <KeyRound size={16} style={{ position: 'absolute', left: '12px', top: '12px', color: 'var(--text-muted)' }} />
                </div>
              </div>

              <div className="form-group">
                <label className="form-label">New Password</label>
                <div style={{ position: 'relative' }}>
                  <input
                    type="password"
                    className="form-control"
                    style={{ paddingLeft: '38px' }}
                    placeholder="••••••••••••"
                    value={newPassword}
                    onChange={(e) => setNewPassword(e.target.value)}
                  />
                  <Lock size={16} style={{ position: 'absolute', left: '12px', top: '12px', color: 'var(--text-muted)' }} />
                </div>
              </div>

              <div className="form-group">
                <label className="form-label">Confirm New Password</label>
                <div style={{ position: 'relative' }}>
                  <input
                    type="password"
                    className="form-control"
                    style={{ paddingLeft: '38px' }}
                    placeholder="••••••••••••"
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                  />
                  <Lock size={16} style={{ position: 'absolute', left: '12px', top: '12px', color: 'var(--text-muted)' }} />
                </div>
              </div>

              <button type="submit" className="btn btn-primary" style={{ width: '100%', padding: '12px' }} disabled={isLoading}>
                {isLoading ? 'Resetting Password...' : 'Save & Activate New Password'}
              </button>
            </form>
          )}

          {step === 'DONE' && (
            <div style={{ textAlign: 'center', padding: '16px 0' }}>
              <div style={{ width: '56px', height: '56px', borderRadius: '50%', background: 'rgba(22, 196, 127, 0.15)', color: 'var(--primary-green)', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 16px auto' }}>
                <CheckCircle2 size={32} />
              </div>
              <h3 style={{ fontSize: '18px', color: 'var(--primary-navy)', marginBottom: '8px' }}>
                Password Updated Successfully!
              </h3>
              <p style={{ fontSize: '13px', color: 'var(--text-muted)', marginBottom: '20px' }}>
                Your account password has been updated. You may now sign in using your new credentials.
              </p>
              <button onClick={onBackToLogin} className="btn btn-primary" style={{ width: '100%' }}>
                Return to Sign In
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
