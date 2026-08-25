import React, { useState } from 'react';
import { admissionsApi } from '../../api/client';
import { AdmissionLearner } from '../../types';
import { UserPlus, Plus, Trash2, ShieldCheck, Mail, AlertCircle, ArrowLeft } from 'lucide-react';

interface ApplyViewProps {
  onBackToLogin: () => void;
}

export const ApplyView: React.FC<ApplyViewProps> = ({ onBackToLogin }) => {
  // Parent 1 Details
  const [parentName, setParentName] = useState('');
  const [parentSurname, setParentSurname] = useState('');
  const [parentPhone, setParentPhone] = useState('');
  const [parentEmail, setParentEmail] = useState('');
  const [parentIdNumber, setParentIdNumber] = useState('');

  // Parent 2 Details
  const [hasSecondary, setHasSecondary] = useState(false);
  const [secName, setSecName] = useState('');
  const [secSurname, setSecSurname] = useState('');
  const [secPhone, setSecPhone] = useState('');
  const [secEmail, setSecEmail] = useState('');
  const [secIdNumber, setSecIdNumber] = useState('');

  // Children List
  const [learners, setLearners] = useState<AdmissionLearner[]>([
    {
      learnerName: '',
      learnerSurname: '',
      learnerIdNumber: '',
      gradeApplyingFor: 'Grade 8',
      homeLanguage: 'Sepedi',
      firstAdditionalLanguage: 'English',
      stream: undefined,
      previousSchool: '',
      documentVerified: true,
    },
  ]);

  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [submittedRef, setSubmittedRef] = useState<string | null>(null);

  const addLearner = () => {
    setLearners([
      ...learners,
      {
        learnerName: '',
        learnerSurname: '',
        learnerIdNumber: '',
        gradeApplyingFor: 'Grade 8',
        homeLanguage: 'Sepedi',
        firstAdditionalLanguage: 'English',
        previousSchool: '',
        documentVerified: true,
      },
    ]);
  };

  const removeLearner = (index: number) => {
    if (learners.length <= 1) return;
    setLearners(learners.filter((_, i) => i !== index));
  };

  const updateLearner = (index: number, field: keyof AdmissionLearner, value: any) => {
    const updated = [...learners];
    updated[index] = { ...updated[index], [field]: value };
    setLearners(updated);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    if (!parentName.trim() || !parentSurname.trim() || !parentEmail.trim() || !parentIdNumber.trim()) {
      setError('Please provide all required primary parent details.');
      return;
    }

    for (let i = 0; i < learners.length; i++) {
      const l = learners[i];
      if (!l.learnerName.trim() || !l.learnerSurname.trim() || !l.learnerIdNumber.trim()) {
        setError(`Please provide full name and SA ID number for Learner #${i + 1}.`);
        return;
      }
    }

    setIsLoading(true);
    try {
      const payload = {
        primaryParentName: parentName.trim(),
        primaryParentSurname: parentSurname.trim(),
        primaryParentPhone: parentPhone.trim(),
        primaryParentEmail: parentEmail.trim(),
        primaryParentIdNumber: parentIdNumber.trim(),
        hasSecondaryParent: hasSecondary,
        secondaryParentName: hasSecondary ? secName.trim() : null,
        secondaryParentSurname: hasSecondary ? secSurname.trim() : null,
        secondaryParentPhone: hasSecondary ? secPhone.trim() : null,
        secondaryParentEmail: hasSecondary ? secEmail.trim() : null,
        secondaryParentIdNumber: hasSecondary ? secIdNumber.trim() : null,
        learners: learners.map((l) => ({
          ...l,
          learnerName: l.learnerName.trim(),
          learnerSurname: l.learnerSurname.trim(),
          learnerIdNumber: l.learnerIdNumber.trim(),
          previousSchool: l.previousSchool.trim() || 'Not Specified',
        })),
      };

      const res = await admissionsApi.apply(payload);
      if (res.success && res.application) {
        setSubmittedRef(res.application.applicationNumber);
      } else {
        setError(res.message || 'Unable to submit application.');
      }
    } catch (err: any) {
      setError(err.response?.data?.message || 'Server connection error.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div style={{ maxWidth: '900px', margin: '32px auto', padding: '0 20px' }}>
      <button onClick={onBackToLogin} className="btn btn-outline" style={{ marginBottom: '20px', fontSize: '13px' }}>
        <ArrowLeft size={16} /> Back to Sign In
      </button>

      {submittedRef ? (
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

          <div style={{
            display: 'inline-block',
            background: 'rgba(11, 25, 44, 0.08)',
            padding: '6px 16px',
            borderRadius: '8px',
            fontWeight: '800',
            fontSize: '14px',
            color: 'var(--primary-navy)',
            marginBottom: '16px',
          }}>
            Application Reference: {submittedRef}
          </div>

          <h2 style={{ fontSize: '24px', fontWeight: '800', color: 'var(--primary-navy)', marginBottom: '12px' }}>
            Application Submitted & Protected
          </h2>

          <div style={{
            maxWidth: '560px',
            margin: '0 auto 24px auto',
            background: '#F8FAFC',
            border: '1px solid var(--card-border)',
            borderRadius: '16px',
            padding: '20px',
            textAlign: 'left',
          }}>
            <div style={{ display: 'flex', gap: '12px', alignItems: 'flex-start' }}>
              <Mail size={24} style={{ color: 'var(--primary-green)', flexShrink: 0, marginTop: '2px' }} />
              <div>
                <div style={{ fontWeight: '700', fontSize: '14px', color: 'var(--primary-navy)', marginBottom: '4px' }}>
                  Confidential Email Delivery
                </div>
                <div style={{ fontSize: '13px', color: 'var(--secondary-navy)', lineHeight: 1.5 }}>
                  To protect your identity and privacy, all admission outcomes, registration tokens, and login credentials have been securely transmitted to your registered email address.
                </div>
                <div style={{ fontSize: '12px', color: 'var(--text-muted)', marginTop: '8px', fontStyle: 'italic' }}>
                  📬 Please check your email inbox (and spam/junk folder) for your official notification.
                </div>
              </div>
            </div>
          </div>

          <button onClick={onBackToLogin} className="btn btn-primary" style={{ padding: '12px 28px' }}>
            Return to Sign In
          </button>
        </div>
      ) : (
        <form onSubmit={handleSubmit} className="glass-card animate-fade-in" style={{ padding: '36px', backgroundColor: '#FFFFFF' }}>
          <div style={{ marginBottom: '24px', borderBottom: '1px solid var(--card-border)', paddingBottom: '16px' }}>
            <span className="badge badge-green" style={{ marginBottom: '8px' }}>2026 Academic Year</span>
            <h2 style={{ fontSize: '24px', fontWeight: '800', color: 'var(--primary-navy)' }}>
              Online Admission Application
            </h2>
            <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
              Official South African CAPS Curriculum Enrolment with Multi-Child Support
            </p>
          </div>

          {error && (
            <div style={{ background: '#FEE2E2', border: '1px solid #FECACA', color: 'var(--danger-red)', padding: '12px', borderRadius: '10px', fontSize: '13px', display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '20px' }}>
              <AlertCircle size={18} />
              <span>{error}</span>
            </div>
          )}

          {/* Section 1: Primary Parent */}
          <div style={{ marginBottom: '28px' }}>
            <h3 style={{ fontSize: '16px', fontWeight: '700', color: 'var(--primary-navy)', marginBottom: '14px', display: 'flex', alignItems: 'center', gap: '8px' }}>
              <UserPlus size={18} color="var(--primary-green)" />
              1. Primary Parent / Guardian Details
            </h3>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '14px' }}>
              <div className="form-group">
                <label className="form-label">First Name *</label>
                <input
                  type="text"
                  className="form-control"
                  placeholder="e.g. Sibusiso"
                  value={parentName}
                  onChange={(e) => setParentName(e.target.value)}
                  required
                />
              </div>

              <div className="form-group">
                <label className="form-label">Surname *</label>
                <input
                  type="text"
                  className="form-control"
                  placeholder="e.g. Makola"
                  value={parentSurname}
                  onChange={(e) => setParentSurname(e.target.value)}
                  required
                />
              </div>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '14px' }}>
              <div className="form-group">
                <label className="form-label">Email Address (For Official Notices) *</label>
                <input
                  type="email"
                  className="form-control"
                  placeholder="parent@example.com"
                  value={parentEmail}
                  onChange={(e) => setParentEmail(e.target.value)}
                  required
                />
              </div>

              <div className="form-group">
                <label className="form-label">Phone Number *</label>
                <input
                  type="tel"
                  className="form-control"
                  placeholder="082 123 4567"
                  value={parentPhone}
                  onChange={(e) => setParentPhone(e.target.value)}
                  required
                />
              </div>
            </div>

            <div className="form-group">
              <label className="form-label">South African National ID Number (13 Digits) *</label>
              <input
                type="text"
                maxLength={13}
                className="form-control"
                placeholder="e.g. 8206051072085"
                value={parentIdNumber}
                onChange={(e) => setParentIdNumber(e.target.value)}
                required
              />
            </div>

            <div style={{ marginTop: '12px' }}>
              <label style={{ display: 'flex', alignItems: 'center', gap: '8px', cursor: 'pointer', fontSize: '13px', fontWeight: '600' }}>
                <input
                  type="checkbox"
                  checked={hasSecondary}
                  onChange={(e) => setHasSecondary(e.target.checked)}
                />
                Include Secondary Parent / Co-Guardian Details
              </label>
            </div>

            {hasSecondary && (
              <div style={{ marginTop: '14px', padding: '16px', background: '#F8FAFC', borderRadius: '12px', border: '1px solid var(--card-border)' }}>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                  <div className="form-group">
                    <label className="form-label">Secondary First Name</label>
                    <input type="text" className="form-control" value={secName} onChange={(e) => setSecName(e.target.value)} />
                  </div>
                  <div className="form-group">
                    <label className="form-label">Secondary Surname</label>
                    <input type="text" className="form-control" value={secSurname} onChange={(e) => setSecSurname(e.target.value)} />
                  </div>
                </div>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                  <div className="form-group">
                    <label className="form-label">Secondary Email</label>
                    <input type="email" className="form-control" value={secEmail} onChange={(e) => setSecEmail(e.target.value)} />
                  </div>
                  <div className="form-group">
                    <label className="form-label">Secondary Phone</label>
                    <input type="tel" className="form-control" value={secPhone} onChange={(e) => setSecPhone(e.target.value)} />
                  </div>
                </div>
              </div>
            )}
          </div>

          {/* Section 2: Children Information */}
          <div style={{ marginBottom: '28px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '14px' }}>
              <h3 style={{ fontSize: '16px', fontWeight: '700', color: 'var(--primary-navy)', display: 'flex', alignItems: 'center', gap: '8px' }}>
                <ShieldCheck size={18} color="var(--primary-green)" />
                2. Enrolling Children ({learners.length})
              </h3>
              <button
                type="button"
                onClick={addLearner}
                className="btn btn-outline"
                style={{ fontSize: '12px', padding: '6px 12px' }}
              >
                <Plus size={14} /> Add Another Child
              </button>
            </div>

            {learners.map((learner, idx) => (
              <div
                key={idx}
                style={{
                  padding: '20px',
                  background: '#F8FAFC',
                  borderRadius: '14px',
                  border: '1px solid var(--card-border)',
                  marginBottom: '16px',
                  position: 'relative',
                }}
              >
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
                  <span className="badge badge-navy">Learner #{idx + 1}</span>
                  {learners.length > 1 && (
                    <button
                      type="button"
                      onClick={() => removeLearner(idx)}
                      style={{ background: 'none', border: 'none', color: 'var(--danger-red)', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '4px', fontSize: '12px' }}
                    >
                      <Trash2 size={14} /> Remove Child
                    </button>
                  )}
                </div>

                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                  <div className="form-group">
                    <label className="form-label">Child First Name *</label>
                    <input
                      type="text"
                      className="form-control"
                      value={learner.learnerName}
                      onChange={(e) => updateLearner(idx, 'learnerName', e.target.value)}
                      required
                    />
                  </div>
                  <div className="form-group">
                    <label className="form-label">Child Surname *</label>
                    <input
                      type="text"
                      className="form-control"
                      value={learner.learnerSurname}
                      onChange={(e) => updateLearner(idx, 'learnerSurname', e.target.value)}
                      required
                    />
                  </div>
                </div>

                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                  <div className="form-group">
                    <label className="form-label">South African ID Number (13 Digits) *</label>
                    <input
                      type="text"
                      maxLength={13}
                      className="form-control"
                      placeholder="e.g. 0905145000088"
                      value={learner.learnerIdNumber}
                      onChange={(e) => updateLearner(idx, 'learnerIdNumber', e.target.value)}
                      required
                    />
                  </div>
                  <div className="form-group">
                    <label className="form-label">Grade Applying For *</label>
                    <select
                      className="form-control"
                      value={learner.gradeApplyingFor}
                      onChange={(e) => updateLearner(idx, 'gradeApplyingFor', e.target.value)}
                    >
                      <option value="Grade 8">Grade 8 (Senior Phase)</option>
                      <option value="Grade 9">Grade 9 (Senior Phase)</option>
                      <option value="Grade 10">Grade 10 (FET Phase)</option>
                      <option value="Grade 11">Grade 11 (FET Phase)</option>
                      <option value="Grade 12">Grade 12 (FET Phase)</option>
                    </select>
                  </div>
                </div>

                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                  <div className="form-group">
                    <label className="form-label">Home Language</label>
                    <select
                      className="form-control"
                      value={learner.homeLanguage}
                      onChange={(e) => updateLearner(idx, 'homeLanguage', e.target.value)}
                    >
                      <option value="Sepedi">Sepedi</option>
                      <option value="English">English</option>
                      <option value="Afrikaans">Afrikaans</option>
                      <option value="isiZulu">isiZulu</option>
                      <option value="isiXhosa">isiXhosa</option>
                      <option value="Setswana">Setswana</option>
                      <option value="Sesotho">Sesotho</option>
                      <option value="Xitsonga">Xitsonga</option>
                      <option value="Tshivenda">Tshivenda</option>
                    </select>
                  </div>
                  <div className="form-group">
                    <label className="form-label">Previous School Attended</label>
                    <input
                      type="text"
                      className="form-control"
                      placeholder="e.g. Polokwane Primary"
                      value={learner.previousSchool}
                      onChange={(e) => updateLearner(idx, 'previousSchool', e.target.value)}
                    />
                  </div>
                </div>

                {['Grade 10', 'Grade 11', 'Grade 12'].includes(learner.gradeApplyingFor) && (
                  <div className="form-group">
                    <label className="form-label">CAPS FET Academic Stream</label>
                    <select
                      className="form-control"
                      value={learner.stream || 'Science'}
                      onChange={(e) => updateLearner(idx, 'stream', e.target.value)}
                    >
                      <option value="Science">Pure Science & Technology (Maths, Physics, Life Sciences)</option>
                      <option value="Commerce">Commerce & Accounting (Maths/Lit, Accounting, Economics)</option>
                      <option value="General">Humanities & Tourism (Geography, History, Tourism)</option>
                    </select>
                  </div>
                )}
              </div>
            ))}
          </div>

          <button
            type="submit"
            className="btn btn-primary"
            style={{ width: '100%', padding: '14px', fontSize: '16px' }}
            disabled={isLoading}
          >
            {isLoading ? 'Submitting Application & Syncing Database...' : 'Submit Application (AI Verification)'}
          </button>
        </form>
      )}
    </div>
  );
};
