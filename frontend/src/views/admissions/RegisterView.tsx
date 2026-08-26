import React, { useState } from 'react';
import { admissionsApi } from '../../api/client';
import { ShieldCheck, Mail, AlertCircle, ArrowLeft, KeyRound, Lock, UserCheck, Eye, EyeOff } from 'lucide-react';

interface RegisterViewProps {
  onBackToLogin: () => void;
}

export const RegisterView: React.FC<RegisterViewProps> = ({ onBackToLogin }) => {
  const [token, setToken] = useState('');
  const [parentName, setParentName] = useState('');
  const [parentSurname, setParentSurname] = useState('');
  const [parentEmail, setParentEmail] = useState('');
  const [parentPassword, setParentPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);

  // Primary child activation
  const [learnerName, setLearnerName] = useState('');
  const [learnerSurname, setLearnerSurname] = useState('');
  const [learnerIdNumber, setLearnerIdNumber] = useState('');

  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [isSuccess, setIsSuccess] = useState(false);

  // Strict String Validation
  const handleStringChange = (val: string, setter: (v: string) => void, fieldName: string) => {
    if (/[0-9]/.test(val)) {
      setError(`${fieldName} must contain letters only. Numbers (0-9) are not allowed.`);
      return;
    }
    setError(null);
    setter(val);
  };

  // Strict Integer Validation
  const handleNumberChange = (val: string, setter: (v: string) => void, fieldName: string) => {
    if (/[^0-9]/.test(val)) {
      setError(`${fieldName} must contain numbers only (0-9). Letters are not allowed.`);
      return;
    }
    setError(null);
    setter(val);
  };

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    if (!token.trim() || !parentEmail.trim() || !parentPassword.trim()) {
      setError('Please provide your admission registration token and parent account credentials.');
      return;
    }

    if (parentPassword !== confirmPassword) {
      setError('Parent passwords do not match.');
      return;
    }

    setIsLoading(true);
    try {
      const res = await admissionsApi.register({
        registrationToken: token.trim(),
        parentName: parentName.trim() || 'Parent',
        parentSurname: parentSurname.trim() || 'Makola',
        parentEmail: parentEmail.trim(),
        parentPassword: parentPassword.trim(),
        learnerName: learnerName.trim() || 'Learner',
        learnerSurname: learnerSurname.trim() || 'Makola',
        learnerIdNumber: learnerIdNumber.trim() || '0000000000000',
      });

      if (res.success) {
        setIsSuccess(true);
      } else {
        setError(res.message || 'Registration token verification failed.');
      }
    } catch (err: any) {
      setError(err.response?.data?.message || 'Invalid or unapproved registration token.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div style={{ maxWidth: '600px', margin: '32px auto', padding: '0 20px' }}>
      <button onClick={onBackToLogin} className="btn btn-outline" style={{ marginBottom: '20px', fontSize: '13px' }}>
        <ArrowLeft size={16} /> Back to Sign In
      </button>

      {isSuccess ? (
        <div className="glass-card animate-fade-in" style={{ padding: '40px', textAlign: 'center', backgroundColor: '#FFFFFF' }}>
          <div style={{
            width: '64px',
            height: '64px',
            borderRadius: '50%',
            background: 'rgba(22, 196, 127, 0.15)',
            color: 'var(--primary-green)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            margin: '0 auto 20px auto',
          }}>
            <ShieldCheck size={36} />
          </div>

          <h2 style={{ fontSize: '24px', fontWeight: '800', color: 'var(--primary-navy)', marginBottom: '8px' }}>
            Registration Confirmed!
          </h2>
          <p style={{ fontSize: '14px', color: 'var(--text-muted)', marginBottom: '24px' }}>
            Parent portal account activated and learner profiles enrolled in the central database.
          </p>

          <div style={{
            background: '#F8FAFC',
            border: '1px solid var(--card-border)',
            borderRadius: '16px',
            padding: '20px',
            textAlign: 'left',
            marginBottom: '24px',
          }}>
            <div style={{ display: 'flex', gap: '12px', alignItems: 'flex-start' }}>
              <Mail size={24} style={{ color: 'var(--primary-green)', flexShrink: 0, marginTop: '2px' }} />
              <div>
                <div style={{ fontWeight: '700', fontSize: '14px', color: 'var(--primary-navy)', marginBottom: '4px' }}>
                  Confidential Credential Delivery Notice
                </div>
                <div style={{ fontSize: '13px', color: 'var(--secondary-navy)', lineHeight: 1.5 }}>
                  All official student numbers, institutional login emails, and access keys have been encrypted and sent directly to your registered parent email inbox.
                </div>
                <div style={{ fontSize: '12px', color: 'var(--text-muted)', marginTop: '8px', fontStyle: 'italic' }}>
                  📬 Please check your email to view your login credentials and sign in.
                </div>
              </div>
            </div>
          </div>

          <button onClick={onBackToLogin} className="btn btn-primary" style={{ padding: '12px 28px' }}>
            Proceed to Sign In
          </button>
        </div>
      ) : (
        <form onSubmit={handleRegister} className="glass-card animate-fade-in" style={{ padding: '36px', backgroundColor: '#FFFFFF' }}>
          <div style={{ marginBottom: '24px', borderBottom: '1px solid var(--card-border)', paddingBottom: '16px' }}>
            <span className="badge badge-green" style={{ marginBottom: '8px' }}>Approved Applicants</span>
            <h2 style={{ fontSize: '24px', fontWeight: '800', color: 'var(--primary-navy)' }}>
              Complete Registration
            </h2>
            <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
              Enter your official token from your admission acceptance email
            </p>
          </div>

          {error && (
            <div style={{ background: '#FEE2E2', border: '1px solid #FECACA', color: 'var(--danger-red)', padding: '12px', borderRadius: '10px', fontSize: '13px', display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '20px' }}>
              <AlertCircle size={18} />
              <span>{error}</span>
            </div>
          )}

          <div className="form-group">
            <label className="form-label">Registration Token (e.g. REG-TT-XXXXX) *</label>
            <div style={{ position: 'relative' }}>
              <input
                type="text"
                className="form-control"
                style={{ paddingLeft: '38px', fontWeight: 'bold', letterSpacing: '1px' }}
                placeholder="REG-TT-12345"
                value={token}
                onChange={(e) => setToken(e.target.value)}
                required
              />
              <KeyRound size={16} style={{ position: 'absolute', left: '12px', top: '12px', color: 'var(--text-muted)' }} />
            </div>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
            <div className="form-group">
              <label className="form-label">Parent First Name</label>
              <input
                type="text"
                className="form-control"
                placeholder="e.g. Sibusiso"
                value={parentName}
                onChange={(e) => handleStringChange(e.target.value, setParentName, 'Parent First Name')}
              />
            </div>
            <div className="form-group">
              <label className="form-label">Parent Surname</label>
              <input
                type="text"
                className="form-control"
                placeholder="e.g. Makola"
                value={parentSurname}
                onChange={(e) => handleStringChange(e.target.value, setParentSurname, 'Parent Surname')}
              />
            </div>
          </div>

          <div className="form-group">
            <label className="form-label">Parent Email Address *</label>
            <div style={{ position: 'relative' }}>
              <input
                type="email"
                className="form-control"
                style={{ paddingLeft: '38px' }}
                placeholder="parent@example.com"
                value={parentEmail}
                onChange={(e) => setParentEmail(e.target.value)}
                required
              />
              <Mail size={16} style={{ position: 'absolute', left: '12px', top: '12px', color: 'var(--text-muted)' }} />
            </div>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
            <div className="form-group" style={{ position: 'relative' }}>
              <label className="form-label">Create Parent Password *</label>
              <div style={{ position: 'relative' }}>
                <input
                  type={showPassword ? 'text' : 'password'}
                  className="form-control"
                  style={{ paddingLeft: '38px', paddingRight: '38px' }}
                  placeholder="••••••••••••"
                  value={parentPassword}
                  onChange={(e) => setParentPassword(e.target.value)}
                  required
                />
                <Lock size={16} style={{ position: 'absolute', left: '12px', top: '12px', color: 'var(--text-muted)' }} />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  style={{ position: 'absolute', right: '12px', top: '10px', background: 'none', border: 'none', cursor: 'pointer', color: 'var(--text-muted)' }}
                >
                  {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
                </button>
              </div>
            </div>

            <div className="form-group">
              <label className="form-label">Confirm Password *</label>
              <div style={{ position: 'relative' }}>
                <input
                  type="password"
                  className="form-control"
                  style={{ paddingLeft: '38px' }}
                  placeholder="••••••••••••"
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.target.value)}
                  required
                />
                <Lock size={16} style={{ position: 'absolute', left: '12px', top: '12px', color: 'var(--text-muted)' }} />
              </div>
            </div>
          </div>

          <div style={{ marginTop: '8px', marginBottom: '24px', padding: '14px', background: '#F8FAFC', borderRadius: '10px', border: '1px solid var(--card-border)' }}>
            <div style={{ fontSize: '12px', fontWeight: '700', color: 'var(--primary-navy)', marginBottom: '8px', display: 'flex', alignItems: 'center', gap: '6px' }}>
              <UserCheck size={14} color="var(--primary-green)" />
              Learner Details (For Student ID Registration)
            </div>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px' }}>
              <input
                type="text"
                className="form-control"
                placeholder="Learner First Name"
                value={learnerName}
                onChange={(e) => handleStringChange(e.target.value, setLearnerName, 'Learner First Name')}
              />
              <input
                type="text"
                className="form-control"
                placeholder="Learner Surname"
                value={learnerSurname}
                onChange={(e) => handleStringChange(e.target.value, setLearnerSurname, 'Learner Surname')}
              />
            </div>
            <div style={{ marginTop: '10px' }}>
              <input
                type="text"
                maxLength={13}
                className="form-control"
                placeholder="Learner SA ID Number (13 Digits)"
                value={learnerIdNumber}
                onChange={(e) => handleNumberChange(e.target.value, setLearnerIdNumber, 'Learner SA ID')}
              />
            </div>
          </div>

          <button
            type="submit"
            className="btn btn-primary"
            style={{ width: '100%', padding: '14px', fontSize: '15px' }}
            disabled={isLoading}
          >
            {isLoading ? 'Activating Credentials & Enrolling...' : 'Verify Token & Activate Account'}
          </button>
        </form>
      )}
    </div>
  );
};
