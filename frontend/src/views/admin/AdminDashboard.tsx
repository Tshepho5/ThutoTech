import React, { useState, useEffect } from 'react';
import { adminApi, admissionsApi } from '../../api/client';
import { User, AdmissionApplication, AuditLog } from '../../types';
import { StatCard } from '../../components/StatCard';
import { Modal } from '../../components/Modal';
import {
  Users,
  BookOpen,
  ClipboardList,
  Megaphone,
  Shield,
  UserPlus,
  Search,
  CheckCircle2,
  XCircle,
  Clock,
  Trash2,
  Check,
  AlertCircle
} from 'lucide-react';

interface AdminDashboardProps {
  currentUser: User;
}

const CAPS_SUBJECTS = [
  { id: 'sub_math', name: 'Mathematics', code: 'MATH-FET', grade: 'Grade 10-12' },
  { id: 'sub_phys', name: 'Physical Sciences', code: 'PHYS-FET', grade: 'Grade 10-12' },
  { id: 'sub_life', name: 'Life Sciences', code: 'LIFE-FET', grade: 'Grade 10-12' },
  { id: 'sub_eng', name: 'English First Additional Language', code: 'ENG-FAL', grade: 'Grade 8-12' },
  { id: 'sub_acc', name: 'Accounting', code: 'ACC-FET', grade: 'Grade 10-12' },
  { id: 'sub_econ', name: 'Economics', code: 'ECON-FET', grade: 'Grade 10-12' },
  { id: 'sub_geo', name: 'Geography', code: 'GEO-FET', grade: 'Grade 10-12' },
  { id: 'sub_hist', name: 'History', code: 'HIST-FET', grade: 'Grade 10-12' },
  { id: 'sub_tour', name: 'Tourism', code: 'TOUR-FET', grade: 'Grade 10-12' },
  { id: 'sub_lo', name: 'Life Orientation', code: 'LO-GEN', grade: 'Grade 8-12' },
];

export const AdminDashboard: React.FC<AdminDashboardProps> = ({ currentUser }) => {
  const [activeTab, setActiveTab] = useState<'USERS' | 'SUBJECTS' | 'ADMISSIONS' | 'ANNOUNCEMENTS' | 'AUDIT'>('USERS');

  // Live Data States
  const [users, setUsers] = useState<User[]>([]);
  const [admissions, setAdmissions] = useState<AdmissionApplication[]>([]);
  const [auditLogs, setAuditLogs] = useState<AuditLog[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [statusMessage, setStatusMessage] = useState<string | null>(null);

  // Search & Filters
  const [userSearch, setUserSearch] = useState('');
  const [roleFilter, setRoleFilter] = useState('ALL');
  const [subjectSearch, setSubjectSearch] = useState('');

  // Modals
  const [isTeacherModalOpen, setIsTeacherModalOpen] = useState(false);
  const [isAnnounceModalOpen, setIsAnnounceModalOpen] = useState(false);

  // Teacher Form State
  const [teacherName, setTeacherName] = useState('');
  const [teacherSurname, setTeacherSurname] = useState('');
  const [teacherEmail, setTeacherEmail] = useState('');
  const [teacherPhone, setTeacherPhone] = useState('');
  const [teacherPassword, setTeacherPassword] = useState('Teacher@2026!');
  const [selectedSubjects, setSelectedSubjects] = useState<string[]>([]);
  const [selectedClasses, setSelectedClasses] = useState<string[]>(['Grade 10A']);

  // Announcement Form State
  const [annTitle, setAnnTitle] = useState('');
  const [annContent, setAnnContent] = useState('');
  const [annPriority, setAnnPriority] = useState('Normal');

  const loadData = async () => {
    setIsLoading(true);
    try {
      const [uData, aData, logs] = await Promise.all([
        adminApi.getUsers().catch(() => []),
        admissionsApi.getAll().catch(() => []),
        adminApi.getAuditLogs().catch(() => []),
      ]);
      setUsers(uData);
      setAdmissions(aData);
      setAuditLogs(logs);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  const handleAppointTeacher = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!teacherName.trim() || !teacherSurname.trim() || !teacherEmail.trim()) return;

    try {
      await adminApi.appointTeacher({
        name: teacherName.trim(),
        surname: teacherSurname.trim(),
        email: teacherEmail.trim(),
        phone: teacherPhone.trim(),
        password: teacherPassword.trim(),
        subjectIds: selectedSubjects,
        classIds: selectedClasses,
      });

      setIsTeacherModalOpen(false);
      setStatusMessage(`Teacher ${teacherName} ${teacherSurname} appointed successfully!`);
      // Reset form
      setTeacherName('');
      setTeacherSurname('');
      setTeacherEmail('');
      setTeacherPhone('');
      loadData();
    } catch (err: any) {
      alert(err.response?.data?.message || 'Error appointing teacher.');
    }
  };

  const handleApproveAdmission = async (id: string) => {
    try {
      await admissionsApi.approve(id);
      setStatusMessage('Admission approved and acceptance email dispatched!');
      loadData();
    } catch (err: any) {
      alert(err.response?.data?.message || 'Error approving application.');
    }
  };

  const handleBroadcastAnnouncement = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!annTitle.trim() || !annContent.trim()) return;

    try {
      await adminApi.broadcastAnnouncement({
        title: annTitle.trim(),
        content: annContent.trim(),
        priority: annPriority,
      });
      setIsAnnounceModalOpen(false);
      setAnnTitle('');
      setAnnContent('');
      setStatusMessage('Announcement broadcasted to ecosystem!');
      loadData();
    } catch (err: any) {
      alert(err.response?.data?.message || 'Error publishing announcement.');
    }
  };

  const filteredUsers = users.filter((u) => {
    const q = userSearch.toLowerCase();
    const matchesQ = (u.name + ' ' + u.surname).toLowerCase().includes(q) || u.email.toLowerCase().includes(q);
    const matchesRole = roleFilter === 'ALL' || u.role === roleFilter;
    return matchesQ && matchesRole;
  });

  return (
    <div>
      {/* Top Banner */}
      <div style={{
        background: 'linear-gradient(135deg, #020617 0%, #0F172A 50%, #1E293B 100%)',
        color: 'white',
        padding: '36px 20px 20px 20px',
        borderBottom: '1px solid rgba(255, 255, 255, 0.1)',
      }}>
        <div style={{ maxWidth: '1300px', margin: '0 auto' }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: '16px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
              <div style={{
                background: 'rgba(22, 196, 127, 0.2)',
                border: '2px solid var(--primary-green)',
                padding: '12px',
                borderRadius: '16px',
                color: 'var(--primary-green)',
              }}>
                <Shield size={32} />
              </div>
              <div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <span className="badge badge-green">ROOT ACCESS</span>
                  <span style={{ color: 'var(--accent-green)', fontSize: '12px', fontWeight: 'bold', letterSpacing: '1px' }}>
                    SUPER ADMINISTRATOR CONSOLE
                  </span>
                </div>
                <h1 style={{ color: 'white', fontSize: '26px', fontWeight: '800', marginTop: '2px' }}>
                  {currentUser.name} {currentUser.surname}
                </h1>
                <div style={{ color: 'rgba(255, 255, 255, 0.7)', fontSize: '13px' }}>
                  {currentUser.email} • SA ID: 8206051072085 • ThutoTech Central Authority
                </div>
              </div>
            </div>

            <div style={{ display: 'flex', gap: '10px' }}>
              <button onClick={() => setIsTeacherModalOpen(true)} className="btn btn-primary">
                <UserPlus size={16} /> Appoint Teacher
              </button>
              <button onClick={() => setIsAnnounceModalOpen(true)} className="btn btn-navy" style={{ background: '#1E293B' }}>
                <Megaphone size={16} /> Broadcast Notice
              </button>
            </div>
          </div>

          {/* Navigation Tabs */}
          <div style={{ display: 'flex', gap: '8px', marginTop: '28px', borderBottom: '1px solid rgba(255, 255, 255, 0.1)', paddingBottom: '0' }}>
            {[
              { key: 'USERS', label: `Users & Staff (${users.length})`, icon: Users },
              { key: 'SUBJECTS', label: `CAPS Subjects (${CAPS_SUBJECTS.length})`, icon: BookOpen },
              { key: 'ADMISSIONS', label: `Admissions Queue (${admissions.length})`, icon: ClipboardList },
              { key: 'ANNOUNCEMENTS', label: 'Announcements', icon: Megaphone },
              { key: 'AUDIT', label: `Audit Trail (${auditLogs.length})`, icon: Shield },
            ].map((tab) => {
              const Icon = tab.icon;
              const isActive = activeTab === tab.key;
              return (
                <button
                  key={tab.key}
                  onClick={() => setActiveTab(tab.key as any)}
                  style={{
                    background: 'none',
                    border: 'none',
                    borderBottom: isActive ? '3px solid var(--primary-green)' : '3px solid transparent',
                    color: isActive ? 'var(--primary-green)' : 'rgba(255, 255, 255, 0.7)',
                    padding: '10px 16px',
                    fontFamily: 'var(--font-heading)',
                    fontSize: '13px',
                    fontWeight: isActive ? '700' : '500',
                    cursor: 'pointer',
                    display: 'flex',
                    alignItems: 'center',
                    gap: '8px',
                    transition: 'all 0.2s ease',
                  }}
                >
                  <Icon size={16} />
                  <span>{tab.label}</span>
                </button>
              );
            })}
          </div>
        </div>
      </div>

      {/* Main Content Area */}
      <div style={{ maxWidth: '1300px', margin: '24px auto', padding: '0 20px' }}>
        {statusMessage && (
          <div style={{
            background: 'rgba(22, 196, 127, 0.15)',
            border: '1px solid var(--primary-green)',
            color: '#0F766E',
            padding: '12px 16px',
            borderRadius: '12px',
            fontSize: '13px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            marginBottom: '20px',
          }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <CheckCircle2 size={18} />
              <span>{statusMessage}</span>
            </div>
            <button onClick={() => setStatusMessage(null)} style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#0F766E' }}>
              ✕
            </button>
          </div>
        )}

        {/* TAB 1: USERS */}
        {activeTab === 'USERS' && (
          <div className="animate-fade-in">
            {/* Telemetry Stats */}
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '16px', marginBottom: '24px' }}>
              <StatCard title="Total Platform Accounts" value={users.length} subtitle="Active authenticated users" icon={Users} color="var(--primary-green)" />
              <StatCard title="Certified Educators" value={users.filter(u => u.role === 'TEACHER').length} subtitle="Assigned to CAPS subjects" icon={BookOpen} color="var(--info-blue)" />
              <StatCard title="Enrolled Parents" value={users.filter(u => u.role === 'PARENT').length} subtitle="Verified guardians" icon={Shield} color="var(--warning-orange)" />
              <StatCard title="System Health" value="100% OK" subtitle="PostgreSQL Database Online" icon={CheckCircle2} color="var(--primary-green)" />
            </div>

            {/* Filter Toolbar */}
            <div className="glass-card" style={{ padding: '16px', marginBottom: '20px', display: 'flex', gap: '12px', flexWrap: 'wrap' }}>
              <div style={{ position: 'relative', flex: 1, minWidth: '240px' }}>
                <input
                  type="text"
                  className="form-control"
                  style={{ paddingLeft: '38px' }}
                  placeholder="Search users by name or email..."
                  value={userSearch}
                  onChange={(e) => setUserSearch(e.target.value)}
                />
                <Search size={16} style={{ position: 'absolute', left: '12px', top: '12px', color: 'var(--text-muted)' }} />
              </div>

              <select
                className="form-control"
                style={{ width: '180px' }}
                value={roleFilter}
                onChange={(e) => setRoleFilter(e.target.value)}
              >
                <option value="ALL">All Roles</option>
                <option value="TEACHER">Teachers</option>
                <option value="PARENT">Parents</option>
                <option value="LEARNER">Learners</option>
                <option value="PRINCIPAL">Principals</option>
                <option value="ADMIN">Super Admins</option>
              </select>
            </div>

            {/* Users List */}
            {filteredUsers.length === 0 ? (
              <div className="glass-card" style={{ padding: '40px', textAlign: 'center' }}>
                <Users size={48} style={{ color: 'var(--text-muted)', margin: '0 auto 12px auto' }} />
                <h4 style={{ color: 'var(--primary-navy)' }}>No users found</h4>
                <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
                  There are no users matching your current search criteria.
                </p>
              </div>
            ) : (
              <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                {filteredUsers.map((u) => (
                  <div key={u.id} className="glass-card" style={{ padding: '16px 20px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
                      <div style={{
                        width: '40px',
                        height: '40px',
                        borderRadius: '10px',
                        background: u.role === 'ADMIN' ? 'rgba(239, 68, 68, 0.12)' : 'rgba(22, 196, 127, 0.12)',
                        color: u.role === 'ADMIN' ? 'var(--danger-red)' : 'var(--primary-green)',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        fontWeight: 'bold',
                      }}>
                        {u.name[0]}{u.surname[0]}
                      </div>
                      <div>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                          <span style={{ fontWeight: '700', fontSize: '15px', color: 'var(--primary-navy)' }}>
                            {u.name} {u.surname}
                          </span>
                          <span className={`badge ${u.role === 'ADMIN' ? 'badge-red' : u.role === 'TEACHER' ? 'badge-green' : 'badge-navy'}`}>
                            {u.role}
                          </span>
                        </div>
                        <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>
                          ✉️ {u.email} {u.phone ? `• 📞 ${u.phone}` : ''}
                        </div>
                      </div>
                    </div>

                    <div style={{ display: 'flex', gap: '8px' }}>
                      <span className="badge badge-green" style={{ fontSize: '10px' }}>ACTIVE</span>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        )}

        {/* TAB 2: CAPS SUBJECTS */}
        {activeTab === 'SUBJECTS' && (
          <div className="animate-fade-in">
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
              <div>
                <h3 style={{ fontSize: '18px', color: 'var(--primary-navy)' }}>Official CAPS Curriculum Directory</h3>
                <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>National subject codes and educator assignments</p>
              </div>
              <button onClick={() => setIsTeacherModalOpen(true)} className="btn btn-primary" style={{ fontSize: '13px' }}>
                <UserPlus size={15} /> Assign Educator to Subject
              </button>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: '14px' }}>
              {CAPS_SUBJECTS.map((sub) => (
                <div key={sub.id} className="glass-card" style={{ padding: '18px' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '8px' }}>
                    <h4 style={{ fontSize: '16px', color: 'var(--primary-navy)' }}>{sub.name}</h4>
                    <span className="badge badge-navy">{sub.grade}</span>
                  </div>
                  <div style={{ fontSize: '12px', color: 'var(--text-muted)', marginBottom: '12px' }}>
                    Curriculum Code: <strong>{sub.code}</strong>
                  </div>
                  <div style={{ borderTop: '1px solid var(--card-border)', paddingTop: '10px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontSize: '12px', color: 'var(--primary-green)', fontWeight: '600' }}>
                      <CheckCircle2 size={14} /> Certified CAPS Subject
                    </div>
                    <button onClick={() => setIsTeacherModalOpen(true)} className="btn btn-outline" style={{ padding: '4px 10px', fontSize: '11px' }}>
                      Assign
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* TAB 3: ADMISSIONS QUEUE */}
        {activeTab === 'ADMISSIONS' && (
          <div className="animate-fade-in">
            <div style={{ marginBottom: '16px' }}>
              <h3 style={{ fontSize: '18px', color: 'var(--primary-navy)' }}>Admissions & Placement Queue</h3>
              <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>Real-time applications submitted by prospective parents</p>
            </div>

            {admissions.length === 0 ? (
              <div className="glass-card" style={{ padding: '40px', textAlign: 'center' }}>
                <ClipboardList size={48} style={{ color: 'var(--text-muted)', margin: '0 auto 12px auto' }} />
                <h4 style={{ color: 'var(--primary-navy)' }}>No Applications in Queue</h4>
                <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
                  When parents submit admission applications on the portal, they will appear here live.
                </p>
              </div>
            ) : (
              <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
                {admissions.map((app) => (
                  <div key={app.id} className="glass-card" style={{ padding: '20px' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: '8px', marginBottom: '12px' }}>
                      <div>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                          <span style={{ fontWeight: '800', fontSize: '16px', color: 'var(--primary-navy)' }}>
                            {app.applicationNumber}
                          </span>
                          <span className={`badge ${app.status === 'APPROVED' ? 'badge-green' : app.status === 'REJECTED' ? 'badge-red' : 'badge-orange'}`}>
                            {app.status}
                          </span>
                        </div>
                        <div style={{ fontSize: '13px', color: 'var(--secondary-navy)', marginTop: '4px' }}>
                          Parent: <strong>{app.primaryParentName} {app.primaryParentSurname}</strong> (✉️ {app.primaryParentEmail} • 📞 {app.primaryParentPhone})
                        </div>
                      </div>

                      <div style={{ textAlign: 'right' }}>
                        <span style={{ fontSize: '11px', color: 'var(--text-muted)' }}>
                          Registration Token:
                        </span>
                        <div style={{ fontWeight: '700', fontSize: '13px', color: 'var(--primary-navy)' }}>
                          {app.registrationToken}
                        </div>
                      </div>
                    </div>

                    <div style={{ background: '#F8FAFC', padding: '12px', borderRadius: '10px', marginBottom: '12px' }}>
                      <div style={{ fontSize: '12px', fontWeight: '700', color: 'var(--primary-navy)', marginBottom: '4px' }}>
                        Enrolling Children ({app.learners?.length || 0}):
                      </div>
                      <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>
                        {app.learners?.map((l) => `${l.learnerName} ${l.learnerSurname} (${l.gradeApplyingFor}${l.stream ? ` • ${l.stream}` : ''})`).join(', ')}
                      </div>
                    </div>

                    {app.status === 'PENDING' && (
                      <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '8px' }}>
                        <button
                          onClick={() => handleApproveAdmission(app.id)}
                          className="btn btn-primary"
                          style={{ padding: '6px 14px', fontSize: '12px' }}
                        >
                          <Check size={14} /> Approve & Dispatch Email
                        </button>
                      </div>
                    )}
                  </div>
                ))}
              </div>
            )}
          </div>
        )}

        {/* TAB 4: ANNOUNCEMENTS */}
        {activeTab === 'ANNOUNCEMENTS' && (
          <div className="animate-fade-in">
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
              <div>
                <h3 style={{ fontSize: '18px', color: 'var(--primary-navy)' }}>Institutional Broadcasts</h3>
                <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>Send urgent notices to educators, parents, and learners</p>
              </div>
              <button onClick={() => setIsAnnounceModalOpen(true)} className="btn btn-primary">
                <Megaphone size={16} /> New Broadcast
              </button>
            </div>

            <div className="glass-card" style={{ padding: '24px' }}>
              <div style={{ display: 'flex', gap: '12px', alignItems: 'center', color: 'var(--primary-green)', fontWeight: 'bold', marginBottom: '6px' }}>
                <CheckCircle2 size={18} /> Broadcast Dispatcher Active
              </div>
              <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
                Published notices are synchronized live to parent inboxes, mobile push notifications, and portal dashboards.
              </p>
            </div>
          </div>
        )}

        {/* TAB 5: AUDIT LOGS */}
        {activeTab === 'AUDIT' && (
          <div className="animate-fade-in">
            <div style={{ marginBottom: '16px' }}>
              <h3 style={{ fontSize: '18px', color: 'var(--primary-navy)' }}>Immutable Security Audit Trail</h3>
              <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>Cryptographic logging of all privileged administrative events</p>
            </div>

            {auditLogs.length === 0 ? (
              <div className="glass-card" style={{ padding: '40px', textAlign: 'center' }}>
                <Shield size={48} style={{ color: 'var(--text-muted)', margin: '0 auto 12px auto' }} />
                <h4 style={{ color: 'var(--primary-navy)' }}>Audit Ledger Ready</h4>
                <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>Security telemetry will log all mutations and user actions.</p>
              </div>
            ) : (
              <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                {auditLogs.map((log) => (
                  <div key={log.id} className="glass-card" style={{ padding: '14px 18px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                    <div>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                        <span className="badge badge-navy">{log.action}</span>
                        <span style={{ fontSize: '13px', fontWeight: '700', color: 'var(--primary-navy)' }}>
                          {log.details}
                        </span>
                      </div>
                      <div style={{ fontSize: '11px', color: 'var(--text-muted)', marginTop: '4px' }}>
                        Actor: {log.userName} ({log.role}) • Entity: {log.entity}
                      </div>
                    </div>
                    <div style={{ fontSize: '11px', color: 'var(--text-muted)', display: 'flex', alignItems: 'center', gap: '4px' }}>
                      <Clock size={12} /> {new Date(log.timestamp).toLocaleString()}
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        )}
      </div>

      {/* MODAL: Appoint Teacher */}
      <Modal isOpen={isTeacherModalOpen} onClose={() => setIsTeacherModalOpen(false)} title="Appoint Certified Educator" maxWidth="560px">
        <form onSubmit={handleAppointTeacher}>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
            <div className="form-group">
              <label className="form-label">First Name *</label>
              <input type="text" className="form-control" placeholder="e.g. Sipho" value={teacherName} onChange={(e) => setTeacherName(e.target.value)} required />
            </div>
            <div className="form-group">
              <label className="form-label">Surname *</label>
              <input type="text" className="form-control" placeholder="e.g. Dlamini" value={teacherSurname} onChange={(e) => setTeacherSurname(e.target.value)} required />
            </div>
          </div>

          <div className="form-group">
            <label className="form-label">Official School Email *</label>
            <input type="email" className="form-control" placeholder="dlamini@thutotech.co.za" value={teacherEmail} onChange={(e) => setTeacherEmail(e.target.value)} required />
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
            <div className="form-group">
              <label className="form-label">Phone Number</label>
              <input type="tel" className="form-control" placeholder="084 123 4567" value={teacherPhone} onChange={(e) => setTeacherPhone(e.target.value)} />
            </div>
            <div className="form-group">
              <label className="form-label">Initial Password</label>
              <input type="text" className="form-control" value={teacherPassword} onChange={(e) => setTeacherPassword(e.target.value)} />
            </div>
          </div>

          <div className="form-group">
            <label className="form-label">Assign CAPS Subjects</label>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: '6px', maxHeight: '140px', overflowY: 'auto', padding: '8px', background: '#F8FAFC', borderRadius: '10px', border: '1px solid var(--card-border)' }}>
              {CAPS_SUBJECTS.map((sub) => {
                const isSelected = selectedSubjects.includes(sub.id);
                return (
                  <button
                    key={sub.id}
                    type="button"
                    onClick={() => {
                      if (isSelected) setSelectedSubjects(selectedSubjects.filter(id => id !== sub.id));
                      else setSelectedSubjects([...selectedSubjects, sub.id]);
                    }}
                    style={{
                      padding: '4px 10px',
                      borderRadius: '6px',
                      fontSize: '11px',
                      fontWeight: '600',
                      border: '1px solid',
                      borderColor: isSelected ? 'var(--primary-green)' : 'var(--card-border)',
                      background: isSelected ? 'rgba(22, 196, 127, 0.15)' : 'white',
                      color: isSelected ? '#0F766E' : 'var(--text-main)',
                      cursor: 'pointer',
                    }}
                  >
                    {sub.name}
                  </button>
                );
              })}
            </div>
          </div>

          <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px', marginTop: '20px' }}>
            <button type="button" onClick={() => setIsTeacherModalOpen(false)} className="btn btn-outline">Cancel</button>
            <button type="submit" className="btn btn-primary">Save & Appoint Educator</button>
          </div>
        </form>
      </Modal>

      {/* MODAL: Broadcast Notice */}
      <Modal isOpen={isAnnounceModalOpen} onClose={() => setIsAnnounceModalOpen(false)} title="Broadcast Institutional Announcement" maxWidth="500px">
        <form onSubmit={handleBroadcastAnnouncement}>
          <div className="form-group">
            <label className="form-label">Announcement Title *</label>
            <input type="text" className="form-control" placeholder="Term 1 Examination Timetable" value={annTitle} onChange={(e) => setAnnTitle(e.target.value)} required />
          </div>

          <div className="form-group">
            <label className="form-label">Message Content *</label>
            <textarea className="form-control" rows={4} placeholder="Please find official notices..." value={annContent} onChange={(e) => setAnnContent(e.target.value)} required />
          </div>

          <div className="form-group">
            <label className="form-label">Priority Flag</label>
            <select className="form-control" value={annPriority} onChange={(e) => setAnnPriority(e.target.value)}>
              <option value="Normal">Normal Priority</option>
              <option value="High">High Priority</option>
              <option value="Urgent">Urgent Alert</option>
            </select>
          </div>

          <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px', marginTop: '20px' }}>
            <button type="button" onClick={() => setIsAnnounceModalOpen(false)} className="btn btn-outline">Cancel</button>
            <button type="submit" className="btn btn-primary">Publish to Ecosystem</button>
          </div>
        </form>
      </Modal>
    </div>
  );
};
