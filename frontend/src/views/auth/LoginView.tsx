import React, { useState } from 'react';
import { authApi } from '../../api/client';
import { User } from '../../types';
import { Lock, Mail, AlertCircle, ArrowRight, ShieldCheck, CheckCircle2, Eye, EyeOff } from 'lucide-react';

interface LoginViewProps {
  onLoginSuccess: (user: User) => void;
  onNavigateApply: () => void;
  onNavigateRegister: () => void;
  onNavigateForgotPassword: () => void;
  onOpenDownload?: () => void;
}

export const LoginView: React.FC<LoginViewProps> = ({
  onLoginSuccess,
  onNavigateApply,
  onNavigateRegister,
  onNavigateForgotPassword,
  onOpenDownload,
}) => {
  const [identifier, setIdentifier] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setErrorMessage(null);

    if (!identifier.trim() || !password.trim()) {
      setErrorMessage('Please enter your login email / student number and password.');
      return;
    }

    setIsLoading(true);
    try {
      const data = await authApi.login(identifier.trim(), password.trim());
      if (data.success && data.user) {
        onLoginSuccess(data.user);
      } else {
        setErrorMessage(data.message || 'Invalid login credentials.');
      }
    } catch (err: any) {
      const msg = err.response?.data?.message || err.message || 'Authentication failed. Please check your credentials.';
      setErrorMessage(msg);
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
        {/* Brand Header */}
        <div style={{ textAlign: 'center', marginBottom: '20px' }}>
          <div style={{ display: 'flex', justifyContent: 'center', marginBottom: '12px' }}>
            <img
              src="/images/logo-3d.jpg"
              alt="ThutoTech Logo"
              style={{
                width: '96px',
                height: '96px',
                borderRadius: '20px',
                boxShadow: '0 8px 24px rgba(22, 196, 127, 0.35)',
                border: '2px solid rgba(255, 255, 255, 0.2)',
                objectFit: 'cover',
              }}
            />
          </div>
          <div style={{
            display: 'inline-flex',
            alignItems: 'center',
            gap: '8px',
            background: 'rgba(22, 196, 127, 0.15)',
            color: 'var(--primary-green)',
            padding: '4px 12px',
            borderRadius: '9999px',
            fontSize: '11px',
            fontWeight: '700',
            marginBottom: '8px',
            border: '1px solid rgba(22, 196, 127, 0.3)',
            letterSpacing: '0.05em',
          }}>
            <ShieldCheck size={14} /> LEARN • CONNECT • EMPOWER
          </div>
          <h2 style={{ color: 'white', fontSize: '24px', fontWeight: '800', fontFamily: 'var(--font-heading)' }}>
            Sign In to ThutoTech
          </h2>
          <p style={{ color: 'rgba(255, 255, 255, 0.7)', fontSize: '12px', marginTop: '2px' }}>
            Unified Portal for Admins, Educators, Parents & Learners
          </p>
        </div>

        {/* Login Card */}
        <div className="glass-card animate-fade-in" style={{ padding: '32px 28px', backgroundColor: '#FFFFFF' }}>
          {errorMessage && (
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
              <span>{errorMessage}</span>
            </div>
          )}

          <form onSubmit={handleSubmit}>
            <div className="form-group">
              <label className="form-label">Email or Student ID Number</label>
              <div style={{ position: 'relative' }}>
                <input
                  type="text"
                  className="form-control"
                  style={{ paddingLeft: '40px' }}
                  placeholder="e.g. thutotech.admin@gmail.com"
                  value={identifier}
                  onChange={(e) => setIdentifier(e.target.value)}
                  disabled={isLoading}
                />
                <Mail size={18} style={{ position: 'absolute', left: '12px', top: '12px', color: 'var(--text-muted)' }} />
              </div>
            </div>

            <div className="form-group">
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '6px' }}>
                <label className="form-label" style={{ marginBottom: 0 }}>Password</label>
                <button
                  type="button"
                  onClick={onNavigateForgotPassword}
                  style={{ background: 'none', border: 'none', color: 'var(--info-blue)', fontSize: '12px', cursor: 'pointer', fontWeight: '600' }}
                >
                  Forgot password?
                </button>
              </div>
              <div style={{ position: 'relative' }}>
                <input
                  type={showPassword ? 'text' : 'password'}
                  className="form-control"
                  style={{ paddingLeft: '40px', paddingRight: '40px' }}
                  placeholder="••••••••••••"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  disabled={isLoading}
                />
                <Lock size={18} style={{ position: 'absolute', left: '12px', top: '12px', color: 'var(--text-muted)' }} />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  style={{
                    position: 'absolute',
                    right: '12px',
                    top: '10px',
                    background: 'none',
                    border: 'none',
                    cursor: 'pointer',
                    color: 'var(--text-muted)',
                    padding: '2px',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                  }}
                  title={showPassword ? 'Hide Password' : 'Show Password'}
                >
                  {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                </button>
              </div>
            </div>

            <button
              type="submit"
              className="btn btn-primary"
              style={{ width: '100%', padding: '12px', fontSize: '15px', marginTop: '10px' }}
              disabled={isLoading}
            >
              {isLoading ? 'Authenticating...' : 'Sign In to Portal'}
              {!isLoading && <ArrowRight size={18} />}
            </button>
          </form>

          {/* Quick Onboarding Links */}
          <div style={{ marginTop: '24px', paddingTop: '20px', borderTop: '1px solid var(--card-border)' }}>
            <div style={{ fontSize: '12px', fontWeight: '700', color: 'var(--text-muted)', marginBottom: '10px', textTransform: 'uppercase' }}>
              New to ThutoTech?
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
              <button
                type="button"
                onClick={onNavigateApply}
                className="btn btn-outline"
                style={{ width: '100%', justifyContent: 'flex-start', fontSize: '13px', padding: '10px 14px' }}
              >
                <CheckCircle2 size={16} color="var(--primary-green)" />
                <span>Submit 2026 CAPS Admission Application</span>
              </button>
              <button
                type="button"
                onClick={onNavigateRegister}
                className="btn btn-outline"
                style={{ width: '100%', justifyContent: 'flex-start', fontSize: '13px', padding: '10px 14px' }}
              >
                <Lock size={16} color="var(--purple-accent)" />
                <span>Complete Registration with Admission Token</span>
              </button>

              {onOpenDownload && (
                <button
                  type="button"
                  onClick={onOpenDownload}
                  className="btn btn-navy"
                  style={{ width: '100%', justifyContent: 'center', fontSize: '13px', padding: '10px 14px', marginTop: '4px' }}
                >
                  <ArrowRight size={16} color="var(--primary-green)" />
                  <span>📲 Download Mobile App (Android APK)</span>
                </button>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
