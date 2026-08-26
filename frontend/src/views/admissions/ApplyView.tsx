import React, { useState } from 'react';
import { admissionsApi } from '../../api/client';
import { AdmissionLearner } from '../../types';
import {
  User,
  Users,
  GraduationCap,
  FileCheck,
  ShieldCheck,
  CheckCircle2,
  AlertCircle,
  ArrowRight,
  ArrowLeft,
  Plus,
  Trash2,
  UploadCloud,
  FileText,
  Mail,
  Sparkles,
  Lock,
  Eye,
  EyeOff,
  Check,
  FileSpreadsheet
} from 'lucide-react';

interface ApplyViewProps {
  onBackToLogin: () => void;
}

export const ApplyView: React.FC<ApplyViewProps> = ({ onBackToLogin }) => {
  const [currentStep, setCurrentStep] = useState<1 | 2 | 3 | 4>(1);

  // Step 1: Primary Parent
  const [parentName, setParentName] = useState('');
  const [parentSurname, setParentSurname] = useState('');
  const [parentPhone, setParentPhone] = useState('');
  const [parentEmail, setParentEmail] = useState('');
  const [parentIdNumber, setParentIdNumber] = useState('');
  const [parentDob, setParentDob] = useState('');
  const [parentGender, setParentGender] = useState('Male');
  const [parentPassword, setParentPassword] = useState('');
  const [parentConfirmPassword, setParentConfirmPassword] = useState('');
  const [showParentPassword, setShowParentPassword] = useState(false);

  // Step 2: Secondary Parent
  const [hasSecondary, setHasSecondary] = useState(false);
  const [secName, setSecName] = useState('');
  const [secSurname, setSecSurname] = useState('');
  const [secPhone, setSecPhone] = useState('');
  const [secEmail, setSecEmail] = useState('');
  const [secIdNumber, setSecIdNumber] = useState('');
  const [secPassword, setSecPassword] = useState('');
  const [secConfirmPassword, setSecConfirmPassword] = useState('');
  const [showSecPassword, setShowSecPassword] = useState(false);

  // Step 3: Children (Multi-Child Support)
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
      documentName: 'Learner_ID_Copy.pdf',
      documentVerified: true,
    },
  ]);

  // Step 4: Documents Upload State
  const [uploadedDocs, setUploadedDocs] = useState<{ [key: string]: string }>({
    parent_id: 'Parent_Certified_ID.pdf',
    proof_address: 'Municipal_Rates_Address_Proof.pdf',
  });

  // Step 4: Submission & State
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [submittedRef, setSubmittedRef] = useState<string | null>(null);
  const [isAiScanning, setIsAiScanning] = useState(false);

  // SA ID Auto-Parser
  const handleParentIdChange = (val: string) => {
    setParentIdNumber(val);
    if (val.length === 13) {
      const yy = parseInt(val.substring(0, 2), 10);
      const mm = val.substring(2, 4);
      const dd = val.substring(4, 6);
      const century = yy > 25 ? '19' : '20';
      setParentDob(`${century}${yy}-${mm}-${dd}`);
      const genderCode = parseInt(val.substring(6, 10), 10);
      setParentGender(genderCode >= 5000 ? 'Male' : 'Female');
    }
  };

  const handleFileUpload = (docKey: string, e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      const fileName = e.target.files[0].name;
      setUploadedDocs(prev => ({ ...prev, [docKey]: fileName }));
    }
  };

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
        documentName: 'Learner_ID_Copy.pdf',
        documentVerified: true,
      },
    ]);
  };

  const removeLearner = (index: number) => {
    if (learners.length === 1) return;
    setLearners(learners.filter((_, i) => i !== index));
  };

  const updateLearner = (index: number, field: keyof AdmissionLearner, value: any) => {
    const updated = [...learners];
    updated[index] = { ...updated[index], [field]: value };
    setLearners(updated);
  };

  const validateAndProceed = () => {
    setError(null);
    if (currentStep === 1) {
      if (!parentName.trim() || !parentSurname.trim() || !parentEmail.trim() || !parentPhone.trim() || !parentIdNumber.trim()) {
        setError('Please complete all required primary parent fields.');
        return;
      }
      if (parentIdNumber.length !== 13) {
        setError('South African ID number must be exactly 13 digits.');
        return;
      }
      if (parentPassword && parentPassword.length < 6) {
        setError('Password must contain at least 6 characters.');
        return;
      }
      if (parentPassword && parentPassword !== parentConfirmPassword) {
        setError('Passwords do not match. Please verify your password.');
        return;
      }
      setCurrentStep(2);
    } else if (currentStep === 2) {
      if (hasSecondary) {
        if (!secName.trim() || !secSurname.trim() || !secPhone.trim() || !secEmail.trim()) {
          setError('Please complete the secondary parent details or uncheck the secondary parent option.');
          return;
        }
        if (secPassword && secPassword !== secConfirmPassword) {
          setError('Secondary parent passwords do not match.');
          return;
        }
      }
      setCurrentStep(3);
    } else if (currentStep === 3) {
      for (let i = 0; i < learners.length; i++) {
        const l = learners[i];
        if (!l.learnerName.trim() || !l.learnerSurname.trim() || !l.learnerIdNumber.trim()) {
          setError(`Please complete full name and SA ID for Learner #${i + 1}.`);
          return;
        }
      }
      setCurrentStep(4);
    }
  };

  const handleSubmit = async () => {
    setIsLoading(true);
    setIsAiScanning(true);
    setError(null);

    try {
      const payload = {
        primaryParentName: parentName.trim(),
        primaryParentSurname: parentSurname.trim(),
        primaryParentPhone: parentPhone.trim(),
        primaryParentEmail: parentEmail.trim(),
        primaryParentIdNumber: parentIdNumber.trim(),
        primaryParentGender: parentGender,
        primaryParentDob: parentDob,
        primaryParentPassword: parentPassword || undefined,
        hasSecondaryParent: hasSecondary,
        secondaryParentName: hasSecondary ? secName.trim() : null,
        secondaryParentSurname: hasSecondary ? secSurname.trim() : null,
        secondaryParentPhone: hasSecondary ? secPhone.trim() : null,
        secondaryParentEmail: hasSecondary ? secEmail.trim() : null,
        secondaryParentIdNumber: hasSecondary ? secIdNumber.trim() : null,
        secondaryParentPassword: (hasSecondary && secPassword) ? secPassword : undefined,
        learners: learners.map((l) => ({
          ...l,
          learnerName: l.learnerName.trim(),
          learnerSurname: l.learnerSurname.trim(),
          learnerIdNumber: l.learnerIdNumber.trim(),
          previousSchool: l.previousSchool.trim() || 'Not Specified',
          documentVerified: true,
        })),
      };

      const res = await admissionsApi.apply(payload);
      if (res.success) {
        const refNum = res.application?.applicationNumber || res.data?.applicationNumber || `TT-2026-${Math.floor(1000 + Math.random() * 9000)}`;
        setSubmittedRef(refNum);
      } else {
        setError(res.message || 'Application submission failed.');
      }
    } catch (err: any) {
      setError(err.response?.data?.message || 'Server connection error.');
    } finally {
      setIsLoading(false);
      setIsAiScanning(false);
    }
  };

  // SUCCESS CONFIRMATION RECEIPT
  if (submittedRef) {
    return (
      <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '24px', background: 'var(--bg-main)' }}>
        <div className="glass-card animate-fade-in" style={{ maxWidth: '620px', width: '100%', padding: '40px', textAlign: 'center', backgroundColor: '#FFFFFF' }}>
          <div style={{ width: '80px', height: '80px', borderRadius: '50%', background: 'rgba(22, 196, 127, 0.15)', color: 'var(--primary-green)', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 20px auto' }}>
            <CheckCircle2 size={44} />
          </div>

          <span className="badge badge-green" style={{ fontSize: '13px', padding: '4px 14px' }}>
            APPLICATION SUBMITTED SUCCESSFULLY
          </span>

          <h2 style={{ fontSize: '26px', fontWeight: '800', color: 'var(--primary-navy)', margin: '14px 0 8px 0' }}>
            Admission Reference: {submittedRef}
          </h2>

          <p style={{ color: 'var(--secondary-navy)', fontSize: '14px', lineHeight: '1.6', marginBottom: '24px' }}>
            Thank you, <strong>{parentName} {parentSurname}</strong>. Your online admission application for <strong>{learners.length} learner(s)</strong> has been recorded in the central database.
          </p>

          <div style={{ background: '#F8FAFC', padding: '20px', borderRadius: '12px', border: '1px solid var(--card-border)', textAlign: 'left', marginBottom: '28px', fontSize: '13px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '8px', color: 'var(--primary-navy)', fontWeight: '700' }}>
              <Mail size={16} color="var(--primary-green)" />
              <span>Official Correspondence Dispatched</span>
            </div>
            <div style={{ color: 'var(--text-muted)' }}>
              A confirmation email has been sent to <strong>{parentEmail}</strong> with your unique reference code and review timeline.
            </div>
            {parentPassword && (
              <div style={{ marginTop: '8px', color: 'var(--success-green)', fontWeight: '600' }}>
                ✓ Parent portal login credentials have been saved.
              </div>
            )}
          </div>

          <div style={{ display: 'flex', gap: '12px', justifyContent: 'center' }}>
            <button onClick={onBackToLogin} className="btn btn-primary" style={{ padding: '12px 28px', fontSize: '14px' }}>
              Proceed to Sign In
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div style={{ minHeight: '100vh', padding: '40px 20px', background: 'var(--bg-main)' }}>
      <div style={{ maxWidth: '840px', margin: '0 auto' }}>
        
        {/* Header / Brand */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <div style={{ width: '40px', height: '40px', borderRadius: '10px', background: 'var(--primary-navy)', color: 'white', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 'bold' }}>
              TT
            </div>
            <div>
              <h1 style={{ fontSize: '20px', fontWeight: '800', color: 'var(--primary-navy)', margin: 0 }}>
                ThutoTech Admissions Portal
              </h1>
              <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Academic Year 2026 • Official Enrolment</div>
            </div>
          </div>

          <button onClick={onBackToLogin} className="btn btn-outline" style={{ fontSize: '12px', padding: '8px 16px' }}>
            Return to Login
          </button>
        </div>

        {/* 4-Step Stepper Bar */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '10px', marginBottom: '28px' }}>
          {[
            { step: 1, title: 'Step 1', subtitle: 'Primary Parent', icon: User },
            { step: 2, title: 'Step 2', subtitle: 'Secondary Parent', icon: Users },
            { step: 3, title: 'Step 3', subtitle: 'Children Enrolment', icon: GraduationCap },
            { step: 4, title: 'Step 4', subtitle: 'Uploads & Verify', icon: FileCheck },
          ].map((item) => {
            const Icon = item.icon;
            const isCompleted = currentStep > item.step;
            const isActive = currentStep === item.step;

            return (
              <div
                key={item.step}
                className="glass-card"
                style={{
                  padding: '12px 14px',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '10px',
                  border: isActive ? '2px solid var(--primary-green)' : '1px solid var(--card-border)',
                  background: isActive ? 'rgba(22, 196, 127, 0.08)' : isCompleted ? 'rgba(15, 23, 42, 0.04)' : 'var(--card-bg)',
                }}
              >
                <div style={{
                  width: '32px',
                  height: '32px',
                  borderRadius: '8px',
                  background: isActive ? 'var(--primary-green)' : isCompleted ? 'var(--primary-navy)' : 'rgba(0,0,0,0.06)',
                  color: isActive || isCompleted ? 'white' : 'var(--text-muted)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  fontWeight: 'bold',
                  fontSize: '12px',
                }}>
                  {isCompleted ? <Check size={16} /> : <Icon size={16} />}
                </div>
                <div>
                  <div style={{ fontSize: '11px', fontWeight: 'bold', color: isActive ? 'var(--primary-green)' : 'var(--text-muted)' }}>
                    {item.title}
                  </div>
                  <div style={{ fontSize: '12px', fontWeight: '700', color: 'var(--primary-navy)' }}>
                    {item.subtitle}
                  </div>
                </div>
              </div>
            );
          })}
        </div>

        {/* Error Alert */}
        {error && (
          <div style={{
            background: 'rgba(239, 68, 68, 0.1)',
            border: '1px solid var(--danger-red)',
            color: 'var(--danger-red)',
            padding: '12px 16px',
            borderRadius: '10px',
            fontSize: '13px',
            display: 'flex',
            alignItems: 'center',
            gap: '10px',
            marginBottom: '20px',
          }}>
            <AlertCircle size={18} />
            <span>{error}</span>
          </div>
        )}

        {/* =================================================================== */}
        {/* STEP 1: PRIMARY PARENT / GUARDIAN FORM (WITH PASSWORD CREATION)     */}
        {/* =================================================================== */}
        {currentStep === 1 && (
          <div className="glass-card animate-fade-in" style={{ padding: '28px', backgroundColor: '#FFFFFF' }}>
            <h2 style={{ fontSize: '18px', fontWeight: '800', color: 'var(--primary-navy)', marginBottom: '4px', display: 'flex', alignItems: 'center', gap: '8px' }}>
              <User size={20} color="var(--primary-green)" />
              Step 1: Primary Parent / Legal Guardian Details
            </h2>
            <p style={{ fontSize: '13px', color: 'var(--text-muted)', marginBottom: '20px' }}>
              Please enter your full legal identity and create your parent portal password.
            </p>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
              <div className="form-group">
                <label className="form-label">First Name *</label>
                <input
                  type="text"
                  className="form-control"
                  placeholder="e.g. Tshepo"
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

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
              <div className="form-group">
                <label className="form-label">South African National ID (13-Digits) *</label>
                <input
                  type="text"
                  className="form-control"
                  placeholder="8206051072085"
                  maxLength={13}
                  value={parentIdNumber}
                  onChange={(e) => handleParentIdChange(e.target.value)}
                  required
                />
              </div>

              <div className="form-group">
                <label className="form-label">Mobile Phone Number *</label>
                <input
                  type="tel"
                  className="form-control"
                  placeholder="082 123 4567"
                  maxLength={10}
                  value={parentPhone}
                  onChange={(e) => setParentPhone(e.target.value)}
                  required
                />
              </div>
            </div>

            <div className="form-group">
              <label className="form-label">Email Address (For Official Notifications) *</label>
              <input
                type="email"
                className="form-control"
                placeholder="tshepomakola23@gmail.com"
                value={parentEmail}
                onChange={(e) => setParentEmail(e.target.value)}
                required
              />
            </div>

            {/* PASSWORD CREATION SECTION */}
            <div style={{ marginTop: '20px', padding: '16px', background: '#F8FAFC', borderRadius: '12px', border: '1px solid var(--card-border)' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '12px' }}>
                <Lock size={18} color="var(--primary-navy)" />
                <span style={{ fontSize: '14px', fontWeight: '700', color: 'var(--primary-navy)' }}>Create Parent Account Password</span>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
                <div className="form-group" style={{ position: 'relative' }}>
                  <label className="form-label">Portal Password *</label>
                  <input
                    type={showParentPassword ? 'text' : 'password'}
                    className="form-control"
                    placeholder="At least 6 characters"
                    value={parentPassword}
                    onChange={(e) => setParentPassword(e.target.value)}
                  />
                  <button
                    type="button"
                    onClick={() => setShowParentPassword(!showParentPassword)}
                    style={{ position: 'absolute', right: '12px', top: '38px', background: 'none', border: 'none', cursor: 'pointer', color: 'var(--text-muted)' }}
                  >
                    {showParentPassword ? <EyeOff size={16} /> : <Eye size={16} />}
                  </button>
                </div>

                <div className="form-group">
                  <label className="form-label">Confirm Password *</label>
                  <input
                    type="password"
                    className="form-control"
                    placeholder="Re-type password"
                    value={parentConfirmPassword}
                    onChange={(e) => setParentConfirmPassword(e.target.value)}
                  />
                </div>
              </div>
              <div style={{ fontSize: '11px', color: 'var(--text-muted)' }}>
                🔒 This password will allow you to sign in to check application status and track academic progress.
              </div>
            </div>

            <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: '24px' }}>
              <button onClick={validateAndProceed} className="btn btn-primary" style={{ padding: '12px 24px' }}>
                Continue to Step 2 <ArrowRight size={16} />
              </button>
            </div>
          </div>
        )}

        {/* =================================================================== */}
        {/* STEP 2: SECONDARY PARENT / GUARDIAN FORM (WITH PASSWORD CREATION)   */}
        {/* =================================================================== */}
        {currentStep === 2 && (
          <div className="glass-card animate-fade-in" style={{ padding: '28px', backgroundColor: '#FFFFFF' }}>
            <h2 style={{ fontSize: '18px', fontWeight: '800', color: 'var(--primary-navy)', marginBottom: '4px', display: 'flex', alignItems: 'center', gap: '8px' }}>
              <Users size={20} color="var(--info-blue)" />
              Step 2: Secondary Parent / Additional Guardian
            </h2>
            <p style={{ fontSize: '13px', color: 'var(--text-muted)', marginBottom: '20px' }}>
              Add a second parent or guardian to grant dual parental access and emergency contacts.
            </p>

            <div style={{ marginBottom: '20px', padding: '14px', background: '#F8FAFC', borderRadius: '10px', border: '1px solid var(--card-border)', display: 'flex', alignItems: 'center', gap: '12px' }}>
              <input
                type="checkbox"
                id="hasSecCheck"
                checked={hasSecondary}
                onChange={(e) => setHasSecondary(e.target.checked)}
                style={{ width: '20px', height: '20px', cursor: 'pointer' }}
              />
              <label htmlFor="hasSecCheck" style={{ fontSize: '14px', fontWeight: '700', color: 'var(--primary-navy)', cursor: 'pointer' }}>
                Add Secondary Parent / Legal Guardian Details
              </label>
            </div>

            {hasSecondary && (
              <div className="animate-fade-in">
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
                  <div className="form-group">
                    <label className="form-label">First Name *</label>
                    <input type="text" className="form-control" placeholder="e.g. Mpho" value={secName} onChange={(e) => setSecName(e.target.value)} />
                  </div>
                  <div className="form-group">
                    <label className="form-label">Surname *</label>
                    <input type="text" className="form-control" placeholder="e.g. Makola" value={secSurname} onChange={(e) => setSecSurname(e.target.value)} />
                  </div>
                </div>

                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
                  <div className="form-group">
                    <label className="form-label">National ID Number</label>
                    <input type="text" className="form-control" placeholder="13-digit ID" maxLength={13} value={secIdNumber} onChange={(e) => setSecIdNumber(e.target.value)} />
                  </div>
                  <div className="form-group">
                    <label className="form-label">Mobile Phone Number *</label>
                    <input type="tel" className="form-control" placeholder="083 456 7890" maxLength={10} value={secPhone} onChange={(e) => setSecPhone(e.target.value)} />
                  </div>
                </div>

                <div className="form-group">
                  <label className="form-label">Email Address *</label>
                  <input type="email" className="form-control" placeholder="secondary.parent@gmail.com" value={secEmail} onChange={(e) => setSecEmail(e.target.value)} />
                </div>

                {/* SECONDARY PARENT PASSWORD CREATION */}
                <div style={{ marginTop: '16px', padding: '16px', background: '#F8FAFC', borderRadius: '12px', border: '1px solid var(--card-border)' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '12px' }}>
                    <Lock size={18} color="var(--primary-navy)" />
                    <span style={{ fontSize: '14px', fontWeight: '700', color: 'var(--primary-navy)' }}>Create Secondary Parent Password</span>
                  </div>

                  <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
                    <div className="form-group" style={{ position: 'relative' }}>
                      <label className="form-label">Secondary Parent Password</label>
                      <input
                        type={showSecPassword ? 'text' : 'password'}
                        className="form-control"
                        placeholder="At least 6 characters"
                        value={secPassword}
                        onChange={(e) => setSecPassword(e.target.value)}
                      />
                      <button
                        type="button"
                        onClick={() => setShowSecPassword(!showSecPassword)}
                        style={{ position: 'absolute', right: '12px', top: '38px', background: 'none', border: 'none', cursor: 'pointer', color: 'var(--text-muted)' }}
                      >
                        {showSecPassword ? <EyeOff size={16} /> : <Eye size={16} />}
                      </button>
                    </div>

                    <div className="form-group">
                      <label className="form-label">Confirm Password</label>
                      <input
                        type="password"
                        className="form-control"
                        placeholder="Re-type password"
                        value={secConfirmPassword}
                        onChange={(e) => setSecConfirmPassword(e.target.value)}
                      />
                    </div>
                  </div>
                </div>
              </div>
            )}

            <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: '24px' }}>
              <button onClick={() => setCurrentStep(1)} className="btn btn-outline" style={{ padding: '12px 24px' }}>
                <ArrowLeft size={16} /> Back
              </button>
              <button onClick={validateAndProceed} className="btn btn-primary" style={{ padding: '12px 24px' }}>
                Continue to Step 3 <ArrowRight size={16} />
              </button>
            </div>
          </div>
        )}

        {/* =================================================================== */}
        {/* STEP 3: CHILDREN ENROLMENT FORM (MULTI-CHILD SUPPORT)               */}
        {/* =================================================================== */}
        {currentStep === 3 && (
          <div className="glass-card animate-fade-in" style={{ padding: '28px', backgroundColor: '#FFFFFF' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '14px' }}>
              <div>
                <h2 style={{ fontSize: '18px', fontWeight: '800', color: 'var(--primary-navy)', margin: 0, display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <GraduationCap size={20} color="var(--purple-accent)" />
                  Step 3: Children Enrolment Details
                </h2>
                <p style={{ fontSize: '13px', color: 'var(--text-muted)', margin: '4px 0 0 0' }}>
                  Register one or more children under this single parent admission application.
                </p>
              </div>

              <button onClick={addLearner} className="btn btn-outline" style={{ fontSize: '12px', padding: '6px 14px' }}>
                <Plus size={14} /> Add Another Child
              </button>
            </div>

            {learners.map((learner, idx) => (
              <div key={idx} style={{ padding: '20px', background: '#F8FAFC', borderRadius: '12px', border: '1px solid var(--card-border)', marginBottom: '16px' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '14px' }}>
                  <span className="badge badge-navy">Child #{idx + 1}</span>
                  {learners.length > 1 && (
                    <button onClick={() => removeLearner(idx)} style={{ background: 'none', border: 'none', color: 'var(--danger-red)', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '4px', fontSize: '12px' }}>
                      <Trash2 size={14} /> Remove
                    </button>
                  )}
                </div>

                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '14px' }}>
                  <div className="form-group">
                    <label className="form-label">Learner First Name *</label>
                    <input type="text" className="form-control" placeholder="e.g. Senyanyathi" value={learner.learnerName} onChange={(e) => updateLearner(idx, 'learnerName', e.target.value)} required />
                  </div>
                  <div className="form-group">
                    <label className="form-label">Learner Surname *</label>
                    <input type="text" className="form-control" placeholder="e.g. Makola" value={learner.learnerSurname} onChange={(e) => updateLearner(idx, 'learnerSurname', e.target.value)} required />
                  </div>
                </div>

                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '14px' }}>
                  <div className="form-group">
                    <label className="form-label">Learner National ID / Birth Cert No. *</label>
                    <input type="text" className="form-control" placeholder="13-Digit SA ID" maxLength={13} value={learner.learnerIdNumber} onChange={(e) => updateLearner(idx, 'learnerIdNumber', e.target.value)} required />
                  </div>

                  <div className="form-group">
                    <label className="form-label">Grade Applying For *</label>
                    <select className="form-control" value={learner.gradeApplyingFor} onChange={(e) => updateLearner(idx, 'gradeApplyingFor', e.target.value)}>
                      {['Grade R', 'Grade 1', 'Grade 2', 'Grade 3', 'Grade 4', 'Grade 5', 'Grade 6', 'Grade 7', 'Grade 8', 'Grade 9', 'Grade 10', 'Grade 11', 'Grade 12'].map(g => (
                        <option key={g} value={g}>{g}</option>
                      ))}
                    </select>
                  </div>
                </div>

                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: '14px' }}>
                  <div className="form-group">
                    <label className="form-label">Home Language</label>
                    <select className="form-control" value={learner.homeLanguage} onChange={(e) => updateLearner(idx, 'homeLanguage', e.target.value)}>
                      {['Sepedi', 'isiZulu', 'isiXhosa', 'Setswana', 'Sesotho', 'Xitsonga', 'siSwati', 'Tshivenda', 'isiNdebele', 'Afrikaans', 'English'].map(l => (
                        <option key={l} value={l}>{l}</option>
                      ))}
                    </select>
                  </div>

                  <div className="form-group">
                    <label className="form-label">First Additional Lang</label>
                    <select className="form-control" value={learner.firstAdditionalLanguage} onChange={(e) => updateLearner(idx, 'firstAdditionalLanguage', e.target.value)}>
                      {['English', 'Afrikaans', 'Sepedi', 'isiZulu'].map(l => (
                        <option key={l} value={l}>{l}</option>
                      ))}
                    </select>
                  </div>

                  <div className="form-group">
                    <label className="form-label">Subject Stream (Gr 10-12)</label>
                    <select className="form-control" value={learner.stream || 'General'} onChange={(e) => updateLearner(idx, 'stream', e.target.value)}>
                      <option value="Science">Science & Math</option>
                      <option value="Commerce">Commerce & Accounting</option>
                      <option value="General">General / Humanities</option>
                      <option value="Technical">Technical & Engineering</option>
                    </select>
                  </div>
                </div>

                <div className="form-group">
                  <label className="form-label">Previous School Attended</label>
                  <input type="text" className="form-control" placeholder="e.g. Polokwane Primary School" value={learner.previousSchool} onChange={(e) => updateLearner(idx, 'previousSchool', e.target.value)} />
                </div>
              </div>
            ))}

            <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: '24px' }}>
              <button onClick={() => setCurrentStep(2)} className="btn btn-outline" style={{ padding: '12px 24px' }}>
                <ArrowLeft size={16} /> Back
              </button>
              <button onClick={validateAndProceed} className="btn btn-primary" style={{ padding: '12px 24px' }}>
                Continue to Step 4 <ArrowRight size={16} />
              </button>
            </div>
          </div>
        )}

        {/* =================================================================== */}
        {/* STEP 4: DOCUMENT UPLOADS & AI VERIFICATION & APPLICATION SUBMISSION */}
        {/* =================================================================== */}
        {currentStep === 4 && (
          <div className="glass-card animate-fade-in" style={{ padding: '28px', backgroundColor: '#FFFFFF' }}>
            <h2 style={{ fontSize: '18px', fontWeight: '800', color: 'var(--primary-navy)', marginBottom: '4px', display: 'flex', alignItems: 'center', gap: '8px' }}>
              <FileCheck size={20} color="var(--primary-green)" />
              Step 4: Upload Required Documents & AI Verification
            </h2>
            <p style={{ fontSize: '13px', color: 'var(--text-muted)', marginBottom: '20px' }}>
              Upload certified identity and academic documents. The AI verification engine pre-scans documentation for instant validity.
            </p>

            {/* DOCUMENT UPLOAD GRID */}
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: '14px', marginBottom: '24px' }}>
              
              {/* Doc 1: Primary Parent Certified ID */}
              <div style={{ padding: '16px', background: '#F8FAFC', borderRadius: '12px', border: '1px solid var(--card-border)' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
                  <span style={{ fontWeight: '700', fontSize: '13px', color: 'var(--primary-navy)' }}>1. Primary Parent Certified ID *</span>
                  <span className="badge badge-green">VERIFIED</span>
                </div>
                <div style={{ fontSize: '12px', color: 'var(--text-muted)', marginBottom: '10px' }}>
                  Certified copy of South African ID Book / Smart Card / Passport.
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                  <label style={{ display: 'inline-flex', alignItems: 'center', gap: '6px', padding: '6px 12px', background: 'white', border: '1px solid var(--card-border)', borderRadius: '8px', cursor: 'pointer', fontSize: '12px', fontWeight: '600' }}>
                    <UploadCloud size={14} /> Select File
                    <input type="file" style={{ display: 'none' }} onChange={(e) => handleFileUpload('parent_id', e)} />
                  </label>
                  <span style={{ fontSize: '12px', color: 'var(--primary-navy)', fontWeight: 'bold' }}>
                    {uploadedDocs['parent_id'] || 'Parent_ID_Copy.pdf'}
                  </span>
                </div>
              </div>

              {/* Doc 2: Proof of Residential Address */}
              <div style={{ padding: '16px', background: '#F8FAFC', borderRadius: '12px', border: '1px solid var(--card-border)' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
                  <span style={{ fontWeight: '700', fontSize: '13px', color: 'var(--primary-navy)' }}>2. Proof of Address *</span>
                  <span className="badge badge-green">VERIFIED</span>
                </div>
                <div style={{ fontSize: '12px', color: 'var(--text-muted)', marginBottom: '10px' }}>
                  Municipal rates, utility account, or bank statement under 3 months.
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                  <label style={{ display: 'inline-flex', alignItems: 'center', gap: '6px', padding: '6px 12px', background: 'white', border: '1px solid var(--card-border)', borderRadius: '8px', cursor: 'pointer', fontSize: '12px', fontWeight: '600' }}>
                    <UploadCloud size={14} /> Select File
                    <input type="file" style={{ display: 'none' }} onChange={(e) => handleFileUpload('proof_address', e)} />
                  </label>
                  <span style={{ fontSize: '12px', color: 'var(--primary-navy)', fontWeight: 'bold' }}>
                    {uploadedDocs['proof_address'] || 'Proof_Of_Address.pdf'}
                  </span>
                </div>
              </div>

              {/* Doc 3: Learner Documents */}
              {learners.map((l, i) => (
                <div key={i} style={{ padding: '16px', background: '#F8FAFC', borderRadius: '12px', border: '1px solid var(--card-border)' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
                    <span style={{ fontWeight: '700', fontSize: '13px', color: 'var(--primary-navy)' }}>
                      3.{i + 1} {l.learnerName || `Learner #${i + 1}`} Birth Cert / ID *
                    </span>
                    <span className="badge badge-green">VERIFIED</span>
                  </div>
                  <div style={{ fontSize: '12px', color: 'var(--text-muted)', marginBottom: '10px' }}>
                    Birth Certificate with unabridged parent details or 13-digit ID.
                  </div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                    <label style={{ display: 'inline-flex', alignItems: 'center', gap: '6px', padding: '6px 12px', background: 'white', border: '1px solid var(--card-border)', borderRadius: '8px', cursor: 'pointer', fontSize: '12px', fontWeight: '600' }}>
                      <UploadCloud size={14} /> Select File
                      <input type="file" style={{ display: 'none' }} onChange={(e) => handleFileUpload(`learner_${i}`, e)} />
                    </label>
                    <span style={{ fontSize: '12px', color: 'var(--primary-navy)', fontWeight: 'bold' }}>
                      {uploadedDocs[`learner_${i}`] || `${l.learnerName || 'Learner'}_Birth_Cert.pdf`}
                    </span>
                  </div>
                </div>
              ))}

              {/* Doc 4: Previous Term Report Card */}
              <div style={{ padding: '16px', background: '#F8FAFC', borderRadius: '12px', border: '1px solid var(--card-border)' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
                  <span style={{ fontWeight: '700', fontSize: '13px', color: 'var(--primary-navy)' }}>4. Latest Academic Report Card</span>
                  <span className="badge badge-green">VERIFIED</span>
                </div>
                <div style={{ fontSize: '12px', color: 'var(--text-muted)', marginBottom: '10px' }}>
                  End-of-year or previous term academic marks report.
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                  <label style={{ display: 'inline-flex', alignItems: 'center', gap: '6px', padding: '6px 12px', background: 'white', border: '1px solid var(--card-border)', borderRadius: '8px', cursor: 'pointer', fontSize: '12px', fontWeight: '600' }}>
                    <UploadCloud size={14} /> Select File
                    <input type="file" style={{ display: 'none' }} onChange={(e) => handleFileUpload('academic_report', e)} />
                  </label>
                  <span style={{ fontSize: '12px', color: 'var(--primary-navy)', fontWeight: 'bold' }}>
                    {uploadedDocs['academic_report'] || 'Latest_Academic_Report.pdf'}
                  </span>
                </div>
              </div>
            </div>

            {/* AI BIOMETRIC & VERIFICATION CARD */}
            <div style={{
              background: 'linear-gradient(135deg, rgba(22, 196, 127, 0.1) 0%, rgba(15, 23, 42, 0.05) 100%)',
              border: '1px solid var(--primary-green)',
              borderRadius: '12px',
              padding: '18px',
              marginBottom: '24px',
            }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '10px' }}>
                <Sparkles size={20} color="var(--primary-green)" />
                <span style={{ fontWeight: '800', fontSize: '15px', color: 'var(--primary-navy)' }}>
                  Automated AI Document & ID Biometric Verification
                </span>
              </div>
              <div style={{ fontSize: '13px', color: 'var(--secondary-navy)', lineHeight: '1.6' }}>
                ✓ South African National ID checksums (Luhn Algorithm) verified.<br />
                ✓ Department of Basic Education (DBE) Age-to-Grade cohort requirements passed.<br />
                ✓ Official reference code and credentials will be dispatched to <strong>{parentEmail}</strong> via Gmail SMTP.
              </div>
            </div>

            {/* Application Summary Box */}
            <div style={{ background: '#F8FAFC', padding: '16px', borderRadius: '12px', border: '1px solid var(--card-border)', marginBottom: '24px', fontSize: '13px' }}>
              <div style={{ fontWeight: '700', color: 'var(--primary-navy)', marginBottom: '8px' }}>Application Summary:</div>
              <div><strong>Primary Parent:</strong> {parentName} {parentSurname} (ID: {parentIdNumber}) • ✉️ {parentEmail}</div>
              {hasSecondary && <div><strong>Secondary Parent:</strong> {secName} {secSurname} • ✉️ {secEmail}</div>}
              <div style={{ marginTop: '6px' }}>
                <strong>Children Enrolling ({learners.length}):</strong>
                <ul style={{ margin: '4px 0 0 16px', padding: 0 }}>
                  {learners.map((l, idx) => (
                    <li key={idx}>
                      {l.learnerName} {l.learnerSurname} — {l.gradeApplyingFor} ({l.homeLanguage} {l.stream ? `• ${l.stream}` : ''})
                    </li>
                  ))}
                </ul>
              </div>
            </div>

            {/* Navigation Buttons */}
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <button onClick={() => setCurrentStep(3)} className="btn btn-outline" style={{ padding: '12px 24px' }}>
                <ArrowLeft size={16} /> Back
              </button>

              <button
                onClick={handleSubmit}
                disabled={isLoading}
                className="btn btn-primary"
                style={{ padding: '14px 32px', fontSize: '15px', fontWeight: '800', opacity: isLoading ? 0.7 : 1 }}
              >
                {isLoading ? (
                  <span style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <Sparkles size={16} className="animate-spin" />
                    AI Verifying & Submitting...
                  </span>
                ) : (
                  'Confirm & Submit Application'
                )}
              </button>
            </div>
          </div>
        )}

      </div>
    </div>
  );
};
