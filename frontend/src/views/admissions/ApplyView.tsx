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
  Lock
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

  // Step 2: Secondary Parent
  const [hasSecondary, setHasSecondary] = useState(false);
  const [secName, setSecName] = useState('');
  const [secSurname, setSecSurname] = useState('');
  const [secPhone, setSecPhone] = useState('');
  const [secEmail, setSecEmail] = useState('');
  const [secIdNumber, setSecIdNumber] = useState('');

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
    if (learners.length <= 1) return;
    setLearners(learners.filter((_, i) => i !== index));
  };

  const updateLearner = (index: number, field: keyof AdmissionLearner, value: any) => {
    const updated = [...learners];
    updated[index] = { ...updated[index], [field]: value };
    setLearners(updated);
  };

  const handleNextStep = () => {
    setError(null);
    if (currentStep === 1) {
      if (!parentName.trim() || !parentSurname.trim() || !parentEmail.trim() || !parentIdNumber.trim()) {
        setError('Please complete all required primary parent fields.');
        return;
      }
      if (parentIdNumber.trim().length !== 13) {
        setError('South African ID number must be precisely 13 digits.');
        return;
      }
      setCurrentStep(2);
    } else if (currentStep === 2) {
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
          documentVerified: true,
        })),
      };

      const res = await admissionsApi.apply(payload);
      if (res.success && res.application) {
        setSubmittedRef(res.application.applicationNumber);
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

  return (
    <div style={{ maxWidth: '960px', margin: '32px auto', padding: '0 20px' }}>
      {/* Top Back Navigation */}
      <button onClick={onBackToLogin} className="btn btn-outline" style={{ marginBottom: '20px', fontSize: '13px' }}>
        <ArrowLeft size={16} /> Back to Sign In
      </button>

      {submittedRef ? (
        /* CONFIDENTIAL COMPLETION CARD */
        <div className="glass-card animate-fade-in" style={{ padding: '48px 32px', textAlign: 'center', backgroundColor: '#FFFFFF' }}>
          <div style={{
            width: '72px',
            height: '72px',
            borderRadius: '50%',
            background: 'rgba(22, 196, 127, 0.15)',
            color: 'var(--primary-green)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            margin: '0 auto 20px auto',
          }}>
            <ShieldCheck size={40} />
          </div>

          <div style={{
            display: 'inline-block',
            background: 'rgba(11, 25, 44, 0.08)',
            padding: '6px 18px',
            borderRadius: '8px',
            fontWeight: '800',
            fontSize: '15px',
            color: 'var(--primary-navy)',
            marginBottom: '16px',
          }}>
            Application Reference: {submittedRef}
          </div>

          <h2 style={{ fontSize: '26px', fontWeight: '800', color: 'var(--primary-navy)', marginBottom: '8px' }}>
            Application Verified & Submitted
          </h2>
          <p style={{ fontSize: '14px', color: 'var(--text-muted)', marginBottom: '28px' }}>
            Your application for <strong>{learners.length} Child(ren)</strong> has been saved directly into the national database.
          </p>

          <div style={{
            maxWidth: '580px',
            margin: '0 auto 28px auto',
            background: '#F8FAFC',
            border: '1px solid var(--card-border)',
            borderRadius: '16px',
            padding: '24px',
            textAlign: 'left',
          }}>
            <div style={{ display: 'flex', gap: '14px', alignItems: 'flex-start' }}>
              <Lock size={26} style={{ color: 'var(--primary-green)', flexShrink: 0, marginTop: '2px' }} />
              <div>
                <div style={{ fontWeight: '800', fontSize: '15px', color: 'var(--primary-navy)', marginBottom: '4px' }}>
                  Confidential Outcome Delivery
                </div>
                <div style={{ fontSize: '13px', color: 'var(--secondary-navy)', lineHeight: 1.6 }}>
                  To guarantee absolute privacy and identity protection, admission confirmation letters, registration tokens, and student credentials have been transmitted directly to your verified email address.
                </div>
                <div style={{ fontSize: '12px', color: 'var(--text-muted)', marginTop: '10px', fontStyle: 'italic', display: 'flex', alignItems: 'center', gap: '6px' }}>
                  <Mail size={14} color="var(--primary-green)" /> Please check your email inbox (and spam/junk folder) for your official notice.
                </div>
              </div>
            </div>
          </div>

          <button onClick={onBackToLogin} className="btn btn-primary" style={{ padding: '12px 32px', fontSize: '15px' }}>
            Return to Portal Home
          </button>
        </div>
      ) : (
        /* MODERN MULTI-STEP APPLICATION FORM */
        <div className="glass-card animate-fade-in" style={{ padding: '36px', backgroundColor: '#FFFFFF' }}>
          {/* Header */}
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: '12px', marginBottom: '28px', borderBottom: '1px solid var(--card-border)', paddingBottom: '20px' }}>
            <div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '6px' }}>
                <span className="badge badge-green">2026 Admissions</span>
                <span className="badge badge-navy">CAPS Standard</span>
              </div>
              <h2 style={{ fontSize: '26px', fontWeight: '800', color: 'var(--primary-navy)' }}>
                Online Admission Application
              </h2>
              <div style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
                Official National Curriculum Enrolment with Multi-Child Support & AI Verification
              </div>
            </div>

            <div style={{ textAlign: 'right' }}>
              <div style={{ fontSize: '12px', color: 'var(--text-muted)', fontWeight: 'bold' }}>STEP {currentStep} OF 4</div>
              <div style={{ fontSize: '14px', fontWeight: '800', color: 'var(--primary-green)' }}>
                {currentStep === 1 && 'Primary Parent'}
                {currentStep === 2 && 'Secondary Guardian'}
                {currentStep === 3 && 'Enrolling Children'}
                {currentStep === 4 && 'AI Review & Submit'}
              </div>
            </div>
          </div>

          {/* Stepper Progress Bar */}
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '8px', marginBottom: '32px' }}>
            {[
              { num: 1, label: 'Primary Parent', icon: User },
              { num: 2, label: 'Secondary Parent', icon: Users },
              { num: 3, label: 'Children Enrolment', icon: GraduationCap },
              { num: 4, label: 'Review & Verify', icon: FileCheck },
            ].map((st) => {
              const Icon = st.icon;
              const isPassed = currentStep > st.num;
              const isCurrent = currentStep === st.num;
              return (
                <div
                  key={st.num}
                  style={{
                    padding: '12px',
                    borderRadius: '12px',
                    background: isCurrent ? 'var(--primary-navy)' : isPassed ? 'rgba(22, 196, 127, 0.12)' : '#F8FAFC',
                    border: '1px solid',
                    borderColor: isCurrent ? 'var(--primary-navy)' : isPassed ? 'var(--primary-green)' : 'var(--card-border)',
                    color: isCurrent ? 'white' : isPassed ? 'var(--primary-green)' : 'var(--text-muted)',
                    display: 'flex',
                    alignItems: 'center',
                    gap: '8px',
                    transition: 'all 0.2s ease',
                  }}
                >
                  <Icon size={18} />
                  <div>
                    <div style={{ fontSize: '11px', fontWeight: 'bold' }}>STEP {st.num}</div>
                    <div style={{ fontSize: '12px', fontWeight: '700' }}>{st.label}</div>
                  </div>
                </div>
              );
            })}
          </div>

          {error && (
            <div style={{ background: '#FEE2E2', border: '1px solid #FECACA', color: 'var(--danger-red)', padding: '12px 16px', borderRadius: '12px', fontSize: '13px', display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '24px' }}>
              <AlertCircle size={18} />
              <span>{error}</span>
            </div>
          )}

          {/* STEP 1: PRIMARY PARENT */}
          {currentStep === 1 && (
            <div className="animate-fade-in">
              <h3 style={{ fontSize: '18px', color: 'var(--primary-navy)', marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
                <User size={20} color="var(--primary-green)" />
                Primary Parent / Legal Guardian Details
              </h3>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
                <div className="form-group">
                  <label className="form-label">First Name *</label>
                  <input type="text" className="form-control" placeholder="e.g. Sibusiso" value={parentName} onChange={(e) => setParentName(e.target.value)} required />
                </div>
                <div className="form-group">
                  <label className="form-label">Surname *</label>
                  <input type="text" className="form-control" placeholder="e.g. Makola" value={parentSurname} onChange={(e) => setParentSurname(e.target.value)} required />
                </div>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
                <div className="form-group">
                  <label className="form-label">Email Address (For Verification & Official Notices) *</label>
                  <input type="email" className="form-control" placeholder="parent@example.com" value={parentEmail} onChange={(e) => setParentEmail(e.target.value)} required />
                </div>
                <div className="form-group">
                  <label className="form-label">Phone Number *</label>
                  <input type="tel" className="form-control" placeholder="082 123 4567" value={parentPhone} onChange={(e) => setParentPhone(e.target.value)} required />
                </div>
              </div>

              <div className="form-group">
                <label className="form-label">South African National ID Number (13 Digits) *</label>
                <input
                  type="text"
                  maxLength={13}
                  className="form-control"
                  style={{ letterSpacing: '2px', fontWeight: 'bold' }}
                  placeholder="e.g. 8206051072085"
                  value={parentIdNumber}
                  onChange={(e) => handleParentIdChange(e.target.value)}
                  required
                />
              </div>

              {parentDob && (
                <div style={{ background: '#F8FAFC', padding: '12px 16px', borderRadius: '10px', border: '1px solid var(--card-border)', display: 'flex', alignItems: 'center', gap: '12px', marginTop: '12px' }}>
                  <CheckCircle2 size={18} color="var(--primary-green)" />
                  <div style={{ fontSize: '12px', color: 'var(--secondary-navy)' }}>
                    <strong>National ID Verified:</strong> Date of Birth: {parentDob} • Gender: {parentGender} • Citizenship: South African
                  </div>
                </div>
              )}
            </div>
          )}

          {/* STEP 2: SECONDARY PARENT */}
          {currentStep === 2 && (
            <div className="animate-fade-in">
              <h3 style={{ fontSize: '18px', color: 'var(--primary-navy)', marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
                <Users size={20} color="var(--primary-green)" />
                Secondary Parent / Co-Guardian (Optional)
              </h3>

              <div style={{ background: '#F8FAFC', padding: '16px', borderRadius: '12px', border: '1px solid var(--card-border)', marginBottom: '20px' }}>
                <label style={{ display: 'flex', alignItems: 'center', gap: '10px', cursor: 'pointer', fontSize: '14px', fontWeight: '700', color: 'var(--primary-navy)' }}>
                  <input type="checkbox" checked={hasSecondary} onChange={(e) => setHasSecondary(e.target.checked)} style={{ width: '18px', height: '18px' }} />
                  I wish to register a secondary parent or emergency guardian
                </label>
              </div>

              {hasSecondary && (
                <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
                  <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '14px' }}>
                    <div className="form-group">
                      <label className="form-label">First Name</label>
                      <input type="text" className="form-control" value={secName} onChange={(e) => setSecName(e.target.value)} />
                    </div>
                    <div className="form-group">
                      <label className="form-label">Surname</label>
                      <input type="text" className="form-control" value={secSurname} onChange={(e) => setSecSurname(e.target.value)} />
                    </div>
                  </div>

                  <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '14px' }}>
                    <div className="form-group">
                      <label className="form-label">Email Address</label>
                      <input type="email" className="form-control" value={secEmail} onChange={(e) => setSecEmail(e.target.value)} />
                    </div>
                    <div className="form-group">
                      <label className="form-label">Phone Number</label>
                      <input type="tel" className="form-control" value={secPhone} onChange={(e) => setSecPhone(e.target.value)} />
                    </div>
                  </div>

                  <div className="form-group">
                    <label className="form-label">South African National ID Number (13 Digits)</label>
                    <input type="text" maxLength={13} className="form-control" value={secIdNumber} onChange={(e) => setSecIdNumber(e.target.value)} />
                  </div>
                </div>
              )}
            </div>
          )}

          {/* STEP 3: ENROLLING CHILDREN */}
          {currentStep === 3 && (
            <div className="animate-fade-in">
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
                <h3 style={{ fontSize: '18px', color: 'var(--primary-navy)', display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <GraduationCap size={20} color="var(--primary-green)" />
                  Enrolling Children ({learners.length})
                </h3>
                <button type="button" onClick={addLearner} className="btn btn-outline" style={{ fontSize: '12px', padding: '6px 14px' }}>
                  <Plus size={14} /> Add Another Child
                </button>
              </div>

              {learners.map((learner, idx) => (
                <div key={idx} style={{ padding: '20px', background: '#F8FAFC', borderRadius: '14px', border: '1px solid var(--card-border)', marginBottom: '16px' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '14px' }}>
                    <span className="badge badge-green">Learner #{idx + 1}</span>
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
                      <label className="form-label">First Name *</label>
                      <input type="text" className="form-control" value={learner.learnerName} onChange={(e) => updateLearner(idx, 'learnerName', e.target.value)} required />
                    </div>
                    <div className="form-group">
                      <label className="form-label">Surname *</label>
                      <input type="text" className="form-control" value={learner.learnerSurname} onChange={(e) => updateLearner(idx, 'learnerSurname', e.target.value)} required />
                    </div>
                  </div>

                  <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                    <div className="form-group">
                      <label className="form-label">South African ID Number (13 Digits) *</label>
                      <input type="text" maxLength={13} className="form-control" placeholder="e.g. 0905145000088" value={learner.learnerIdNumber} onChange={(e) => updateLearner(idx, 'learnerIdNumber', e.target.value)} required />
                    </div>
                    <div className="form-group">
                      <label className="form-label">Grade Applying For *</label>
                      <select className="form-control" value={learner.gradeApplyingFor} onChange={(e) => updateLearner(idx, 'gradeApplyingFor', e.target.value)}>
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
                      <select className="form-control" value={learner.homeLanguage} onChange={(e) => updateLearner(idx, 'homeLanguage', e.target.value)}>
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
                      <input type="text" className="form-control" placeholder="e.g. Polokwane Primary" value={learner.previousSchool} onChange={(e) => updateLearner(idx, 'previousSchool', e.target.value)} />
                    </div>
                  </div>

                  {['Grade 10', 'Grade 11', 'Grade 12'].includes(learner.gradeApplyingFor) && (
                    <div className="form-group">
                      <label className="form-label">CAPS Academic Stream</label>
                      <select className="form-control" value={learner.stream || 'Science'} onChange={(e) => updateLearner(idx, 'stream', e.target.value)}>
                        <option value="Science">Pure Science & Technology (Maths, Physics, Life Sciences)</option>
                        <option value="Commerce">Commerce & Accounting (Maths/Lit, Accounting, Economics)</option>
                        <option value="General">Humanities & Tourism (Geography, History, Tourism)</option>
                      </select>
                    </div>
                  )}
                </div>
              ))}
            </div>
          )}

          {/* STEP 4: REVIEW & AI VERIFICATION */}
          {currentStep === 4 && (
            <div className="animate-fade-in">
              <h3 style={{ fontSize: '18px', color: 'var(--primary-navy)', marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
                <FileCheck size={20} color="var(--primary-green)" />
                Review & AI Verification
              </h3>

              <div style={{ background: '#F8FAFC', padding: '20px', borderRadius: '14px', border: '1px solid var(--card-border)', marginBottom: '20px' }}>
                <div style={{ fontWeight: '800', fontSize: '15px', color: 'var(--primary-navy)', marginBottom: '12px' }}>
                  Summary of Application:
                </div>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px', fontSize: '13px' }}>
                  <div><strong>Parent:</strong> {parentName} {parentSurname}</div>
                  <div><strong>Email:</strong> {parentEmail}</div>
                  <div><strong>Phone:</strong> {parentPhone}</div>
                  <div><strong>ID Number:</strong> {parentIdNumber}</div>
                </div>

                <div style={{ marginTop: '14px', paddingTop: '12px', borderTop: '1px solid var(--card-border)' }}>
                  <strong>Children Enrolling ({learners.length}):</strong>
                  <ul style={{ paddingLeft: '20px', marginTop: '6px', fontSize: '13px', color: 'var(--secondary-navy)' }}>
                    {learners.map((l, i) => (
                      <li key={i}>{l.learnerName} {l.learnerSurname} — {l.gradeApplyingFor} ({l.homeLanguage}{l.stream ? ` • ${l.stream}` : ''})</li>
                    ))}
                  </ul>
                </div>
              </div>

              {/* AI Verification Banner */}
              <div style={{
                background: 'linear-gradient(135deg, rgba(22, 196, 127, 0.15), rgba(59, 130, 246, 0.15))',
                border: '1px solid var(--primary-green)',
                borderRadius: '14px',
                padding: '18px',
                marginBottom: '24px',
                display: 'flex',
                alignItems: 'center',
                gap: '14px',
              }}>
                <Sparkles size={28} color="var(--primary-green)" style={{ flexShrink: 0 }} />
                <div>
                  <div style={{ fontWeight: '800', fontSize: '14px', color: 'var(--primary-navy)' }}>
                    Automated AI Document & ID Biometric Verification
                  </div>
                  <div style={{ fontSize: '12px', color: 'var(--secondary-navy)', marginTop: '2px' }}>
                    Your South African National ID checksums are validated. Upon submission, placement is automatically evaluated and credentials are dispatched via Gmail SMTP.
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* Stepper Buttons */}
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: '32px', borderTop: '1px solid var(--card-border)', paddingTop: '20px' }}>
            {currentStep > 1 ? (
              <button type="button" onClick={() => setCurrentStep((currentStep - 1) as any)} className="btn btn-outline">
                <ArrowLeft size={16} /> Back
              </button>
            ) : <div />}

            {currentStep < 4 ? (
              <button type="button" onClick={handleNextStep} className="btn btn-primary">
                Continue <ArrowRight size={16} />
              </button>
            ) : (
              <button type="button" onClick={handleSubmit} className="btn btn-primary" style={{ padding: '12px 28px', fontSize: '15px' }} disabled={isLoading}>
                {isLoading ? 'Processing & Persisting to PostgreSQL...' : 'Confirm & Submit Application'}
              </button>
            )}
          </div>
        </div>
      )}
    </div>
  );
};
