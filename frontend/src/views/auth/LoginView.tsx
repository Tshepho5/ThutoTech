import React, { useState } from 'react';
import { authApi } from '../../api/client';
import { User } from '../../types';
import { Lock, Mail, AlertCircle, ArrowRight, ShieldCheck, CheckCircle2, Eye, EyeOff } from 'lucide-react';

interface LoginViewProps {
  onLoginSuccess: (user: User) => void;
  onNavigateApply: () => void;
  onNavigateRegister: () => void;
  onNavigateForgotPassword: () => void;
}

export const LoginView: React.FC<LoginViewProps> = ({
  onLoginSuccess,
  onNavigateApply,
  onNavigateRegister,
  onNavigateForgotPassword,
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
        <div style={{ textAlign: 'center', marginBottom: '24px' }}>
          <div style={{
            display: 'inline-flex',
            alignItems: 'center',
            gap: '8px',
            background: 'rgba(22, 196, 127, 0.15)',
            color: 'var(--primary-green)',
            padding: '6px 14px',
            borderRadius: '9999px',
            fontSize: '12px',
            fontWeight: '700',
            marginBottom: '12px',
            border: '1px solid rgba(22, 196, 127, 0.3)',
          }}>
            <ShieldCheck size={16} /> SECURE AUTHENTICATION GATEWAY
          </div>
          <h2 style={{ color: 'white', fontSize: '26px', fontWeight: '800' }}>
            Sign In to ThutoTech
          </h2>
          <p style={{ color: 'rgba(255, 255, 255, 0.7)', fontSize: '13px', marginTop: '4px' }}>
            Unified portal for Super Admins, Educators, Parents & Learners
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

            <button
              type="button"
              onClick={() => {
                setIdentifier('thutotech.admin@gmail.com');
                setPassword('#Admin#$5$');
              }}
              style={{
                width: '100%',
                marginTop: '10px',
                background: 'rgba(239, 68, 68, 0.08)',
                border: '1px solid rgba(239, 68, 68, 0.3)',
                color: 'var(--danger-red)',
                borderRadius: '8px',
                padding: '8px',
                fontSize: '12px',
                fontWeight: '700',
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                gap: '6px',
              }}
            >
              <ShieldCheck size={14} /> Quick-Fill Super Admin (Lebogang Makola)
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
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
