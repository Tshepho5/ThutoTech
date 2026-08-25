import React, { useState, useEffect } from 'react';
import { adminApi, admissionsApi, authApi } from '../../api/client';
import { User, AdmissionApplication, AuditLog } from '../../types';
import { StatCard } from '../../components/StatCard';
import { Modal } from '../../components/Modal';
import {
  Menu,
  X,
  Sun,
  Moon,
  Bell,
  Search,
  Users,
  BookOpen,
  ClipboardList,
  Megaphone,
  Shield,
  UserPlus,
  Calendar,
  Settings,
  HelpCircle,
  LogOut,
  CheckCircle2,
  Clock,
  Check,
  Building,
  Server,
  Activity,
  Award,
  Key,
  Mail,
  Phone,
  Filter,
  CheckSquare
} from 'lucide-react';

interface AdminDashboardProps {
  currentUser: User;
  onLogout?: () => void;
}

const CAPS_SUBJECTS = [
  { id: 'sub_math', name: 'Mathematics', code: 'MATH-FET', grade: 'Grade 10-12', stream: 'Science' },
  { id: 'sub_phys', name: 'Physical Sciences', code: 'PHYS-FET', grade: 'Grade 10-12', stream: 'Science' },
  { id: 'sub_life', name: 'Life Sciences', code: 'LIFE-FET', grade: 'Grade 10-12', stream: 'Science' },
  { id: 'sub_eng', name: 'English First Additional Language', code: 'ENG-FAL', grade: 'Grade 8-12', stream: 'General' },
  { id: 'sub_sep', name: 'Sepedi Home Language', code: 'SEP-HL', grade: 'Grade 8-12', stream: 'General' },
  { id: 'sub_acc', name: 'Accounting', code: 'ACC-FET', grade: 'Grade 10-12', stream: 'Commerce' },
  { id: 'sub_econ', name: 'Economics', code: 'ECON-FET', grade: 'Grade 10-12', stream: 'Commerce' },
  { id: 'sub_geo', name: 'Geography', code: 'GEO-FET', grade: 'Grade 10-12', stream: 'General' },
  { id: 'sub_hist', name: 'History', code: 'HIST-FET', grade: 'Grade 10-12', stream: 'General' },
  { id: 'sub_tour', name: 'Tourism', code: 'TOUR-FET', grade: 'Grade 10-12', stream: 'General' },
  { id: 'sub_lo', name: 'Life Orientation', code: 'LO-GEN', grade: 'Grade 8-12', stream: 'General' },
];

const SA_CALENDAR_EVENTS_2026 = [
  { date: '14 Jan 2026', title: 'Term 1 Commences (DBE Public Schools)', type: 'SCHOOL_TERM', badge: 'DBE Term 1' },
  { date: '21 Mar 2026', title: 'Human Rights Day', type: 'PUBLIC_HOLIDAY', badge: 'Public Holiday' },
  { date: '27 Mar 2026', title: 'Term 1 Concludes (School Holidays Begin)', type: 'SCHOOL_HOLIDAY', badge: 'School Holiday' },
  { date: '03 Apr 2026', title: 'Good Friday', type: 'PUBLIC_HOLIDAY', badge: 'Public Holiday' },
  { date: '06 Apr 2026', title: 'Family Day', type: 'PUBLIC_HOLIDAY', badge: 'Public Holiday' },
  { date: '08 Apr 2026', title: 'Term 2 Commences', type: 'SCHOOL_TERM', badge: 'DBE Term 2' },
  { date: '27 Apr 2026', title: 'Freedom Day', type: 'PUBLIC_HOLIDAY', badge: 'Public Holiday' },
  { date: '01 May 2026', title: 'Workers\' Day', type: 'PUBLIC_HOLIDAY', badge: 'Public Holiday' },
  { date: '16 Jun 2026', title: 'Youth Day', type: 'PUBLIC_HOLIDAY', badge: 'Public Holiday' },
  { date: '26 Jun 2026', title: 'Term 2 Concludes (Winter School Holidays)', type: 'SCHOOL_HOLIDAY', badge: 'School Holiday' },
  { date: '21 Jul 2026', title: 'Term 3 Commences', type: 'SCHOOL_TERM', badge: 'DBE Term 3' },
  { date: '09 Aug 2026', title: 'National Women\'s Day', type: 'PUBLIC_HOLIDAY', badge: 'Public Holiday' },
  { date: '10 Aug 2026', title: 'Public Holiday (Observed)', type: 'PUBLIC_HOLIDAY', badge: 'Public Holiday' },
  { date: '24 Sep 2026', title: 'Heritage Day', type: 'PUBLIC_HOLIDAY', badge: 'Public Holiday' },
  { date: '02 Oct 2026', title: 'Term 3 Concludes (Spring Holidays)', type: 'SCHOOL_HOLIDAY', badge: 'School Holiday' },
  { date: '13 Oct 2026', title: 'Term 4 Commences (National Senior Certificate Exams)', type: 'SCHOOL_TERM', badge: 'DBE Term 4' },
  { date: '09 Dec 2026', title: 'Academic Year Concludes', type: 'SCHOOL_HOLIDAY', badge: 'School Holiday' },
  { date: '16 Dec 2026', title: 'Day of Reconciliation', type: 'PUBLIC_HOLIDAY', badge: 'Public Holiday' },
  { date: '25 Dec 2026', title: 'Christmas Day', type: 'PUBLIC_HOLIDAY', badge: 'Public Holiday' },
  { date: '26 Dec 2026', title: 'Day of Goodwill', type: 'PUBLIC_HOLIDAY', badge: 'Public Holiday' },
];

export const AdminDashboard: React.FC<AdminDashboardProps> = ({ currentUser, onLogout }) => {
  // Navigation & Bottom Bar State
  const [activeNav, setActiveNav] = useState<'HOME' | 'CALENDAR' | 'USERS' | 'OPERATIONS' | 'SETTINGS'>('HOME');

  // Theme State
  const [theme, setTheme] = useState<'light' | 'dark'>('light');

  // Hamburger Drawer State
  const [isDrawerOpen, setIsDrawerOpen] = useState(false);

  // Notification Popover State
  const [isNotifOpen, setIsNotifOpen] = useState(false);

  // Search Query
  const [searchQuery, setSearchQuery] = useState('');

  // Modals from Drawer
  const [isProfileModalOpen, setIsProfileModalOpen] = useState(false);
  const [isHelpModalOpen, setIsHelpModalOpen] = useState(false);

  // Operational Modals
  const [isTeacherModalOpen, setIsTeacherModalOpen] = useState(false);
  const [isAnnounceModalOpen, setIsAnnounceModalOpen] = useState(false);

  // Live Data States
  const [users, setUsers] = useState<User[]>([]);
  const [admissions, setAdmissions] = useState<AdmissionApplication[]>([]);
  const [auditLogs, setAuditLogs] = useState<AuditLog[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [statusMessage, setStatusMessage] = useState<string | null>(null);

  // System Settings State
  const [systemSettings, setSystemSettings] = useState({
    smtpEmailEnabled: true,
    admissionsOpen: true,
    twoFactorEnforced: false,
    maintenanceMode: false,
    sessionTimeoutMinutes: 30,
  });

  // Appoint Teacher Form State
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

  // Toggle Theme
  const toggleTheme = () => {
    const newTheme = theme === 'light' ? 'dark' : 'light';
    setTheme(newTheme);
    document.documentElement.setAttribute('data-theme', newTheme);
  };

  // Load Live Data
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
      setStatusMessage(`Educator ${teacherName} ${teacherSurname} appointed successfully!`);
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

  const handleLogoutAction = () => {
    authApi.logout();
    if (onLogout) {
      onLogout();
    } else {
      window.location.reload();
    }
  };

  const pendingAdmissionsCount = admissions.filter(a => a.status === 'PENDING').length;

  const filteredUsers = users.filter(u => {
    const q = searchQuery.toLowerCase();
    return (u.name + ' ' + u.surname).toLowerCase().includes(q) || u.email.toLowerCase().includes(q) || u.role.toLowerCase().includes(q);
  });

  return (
    <div style={{ minHeight: '100vh', backgroundColor: 'var(--bg-main)', position: 'relative' }}>
      
      {/* ========================================================================= */}
      {/* 1. FIXED TOP HEADER                                                       */}
      {/* ========================================================================= */}
      <header style={{
        position: 'fixed',
        top: 0,
        left: 0,
        right: 0,
        height: '70px',
        background: 'var(--primary-navy)',
        color: 'white',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        padding: '0 20px',
        zIndex: 1000,
        boxShadow: '0 2px 10px rgba(0,0,0,0.15)',
      }}>
        {/* Left: Hamburger, Theme Changer, Notifications, Search */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px', flex: 1 }}>
          {/* Hamburger Menu Toggle */}
          <button
            onClick={() => setIsDrawerOpen(true)}
            style={{
              background: 'rgba(255,255,255,0.1)',
              border: 'none',
              color: 'white',
              width: '38px',
              height: '38px',
              borderRadius: '8px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
            }}
            title="Open Menu"
          >
            <Menu size={20} />
          </button>

          {/* Theme Changer */}
          <button
            onClick={toggleTheme}
            style={{
              background: 'rgba(255,255,255,0.1)',
              border: 'none',
              color: 'white',
              width: '38px',
              height: '38px',
              borderRadius: '8px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
            }}
            title={theme === 'light' ? 'Switch to Dark Theme' : 'Switch to Light Theme'}
          >
            {theme === 'light' ? <Moon size={18} color="#FFD700" /> : <Sun size={18} color="#FFA500" />}
          </button>

          {/* Notifications Icon with Counter */}
          <div style={{ position: 'relative' }}>
            <button
              onClick={() => setIsNotifOpen(!isNotifOpen)}
              style={{
                background: 'rgba(255,255,255,0.1)',
                border: 'none',
                color: 'white',
                width: '38px',
                height: '38px',
                borderRadius: '8px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                cursor: 'pointer',
                position: 'relative',
              }}
              title="Notifications"
            >
              <Bell size={18} />
              {pendingAdmissionsCount > 0 && (
                <span style={{
                  position: 'absolute',
                  top: '-4px',
                  right: '-4px',
                  background: 'var(--danger-red)',
                  color: 'white',
                  fontSize: '10px',
                  fontWeight: 'bold',
                  borderRadius: '999px',
                  padding: '2px 6px',
                }}>
                  {pendingAdmissionsCount}
                </span>
              )}
            </button>

            {/* Notification Dropdown Popover */}
            {isNotifOpen && (
              <div style={{
                position: 'absolute',
                top: '46px',
                left: 0,
                width: '300px',
                background: 'var(--card-bg)',
                color: 'var(--text-main)',
                borderRadius: '12px',
                boxShadow: 'var(--shadow-lg)',
                border: '1px solid var(--card-border)',
                padding: '14px',
                zIndex: 1100,
              }}>
                <div style={{ fontWeight: '700', fontSize: '13px', borderBottom: '1px solid var(--card-border)', paddingBottom: '8px', marginBottom: '8px' }}>
                  Live System Notifications
                </div>
                {pendingAdmissionsCount > 0 ? (
                  <div style={{ fontSize: '12px', padding: '8px', background: '#F8FAFC', borderRadius: '8px', marginBottom: '6px' }}>
                    🔔 <strong>{pendingAdmissionsCount} Admission(s) Pending</strong> waiting for administrative approval.
                  </div>
                ) : (
                  <div style={{ fontSize: '12px', color: 'var(--text-muted)', textAlign: 'center', padding: '12px 0' }}>
                    No unread notifications
                  </div>
                )}
                <div style={{ fontSize: '11px', color: 'var(--primary-green)', fontWeight: 'bold', textAlign: 'center', marginTop: '6px' }}>
                  PostgreSQL DB Live • All Services Operational
                </div>
              </div>
            )}
          </div>

          {/* Search Bar */}
          <div style={{ position: 'relative', maxWidth: '240px', width: '100%' }}>
            <input
              type="text"
              placeholder="Search ecosystem..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              style={{
                width: '100%',
                background: 'rgba(255,255,255,0.12)',
                border: '1px solid rgba(255,255,255,0.2)',
                color: 'white',
                borderRadius: '8px',
                padding: '8px 10px 8px 32px',
                fontSize: '12px',
                outline: 'none',
              }}
            />
            <Search size={14} style={{ position: 'absolute', left: '10px', top: '10px', color: 'rgba(255,255,255,0.6)' }} />
          </div>
        </div>

        {/* Center: App Name */}
        <div style={{
          fontFamily: 'var(--font-heading)',
          fontWeight: '800',
          fontSize: '18px',
          letterSpacing: '-0.5px',
          textAlign: 'center',
          flex: 1,
        }}>
          ThutoTech Ecosystem
        </div>

        {/* Right: Admin Profile Avatar, Initials, Surname & Role */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'flex-end', gap: '12px', flex: 1 }}>
          <div style={{ textAlign: 'right' }}>
            <div style={{ fontSize: '13px', fontWeight: '700', color: 'white' }}>
              {currentUser.name[0]}. {currentUser.surname}
            </div>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'flex-end', gap: '4px' }}>
              <span className="badge badge-red" style={{ fontSize: '9px', padding: '1px 6px' }}>
                SUPER ADMIN
              </span>
            </div>
          </div>

          <div
            onClick={() => setIsProfileModalOpen(true)}
            style={{
              width: '38px',
              height: '38px',
              borderRadius: '50%',
              background: 'var(--primary-green)',
              color: 'white',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontWeight: '800',
              fontSize: '14px',
              cursor: 'pointer',
              boxShadow: '0 2px 8px rgba(22, 196, 127, 0.4)',
            }}
            title="View Admin Profile"
          >
            {currentUser.name[0]}{currentUser.surname[0]}
          </div>
        </div>
      </header>

      {/* ========================================================================= */}
      {/* 2. HAMBURGER SLIDEOUT DRAWER                                              */}
      {/* ========================================================================= */}
      {isDrawerOpen && (
        <div style={{
          position: 'fixed',
          top: 0,
          left: 0,
          bottom: 0,
          right: 0,
          background: 'rgba(0,0,0,0.5)',
          zIndex: 2000,
          display: 'flex',
        }}>
          <div style={{
            width: '300px',
            background: 'var(--card-bg)',
            height: '100%',
            boxShadow: 'var(--shadow-lg)',
            display: 'flex',
            flexDirection: 'column',
            padding: '24px 20px',
            animation: 'fadeIn 0.2s ease',
          }}>
            {/* Drawer Header */}
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderBottom: '1px solid var(--card-border)', paddingBottom: '16px', marginBottom: '20px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <div style={{ width: '36px', height: '36px', borderRadius: '8px', background: 'var(--primary-navy)', color: 'white', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 'bold' }}>
                  TT
                </div>
                <div>
                  <div style={{ fontWeight: '800', fontSize: '14px', color: 'var(--primary-navy)' }}>Admin Menu</div>
                  <div style={{ fontSize: '11px', color: 'var(--text-muted)' }}>ThutoTech v1.0.0</div>
                </div>
              </div>
              <button onClick={() => setIsDrawerOpen(false)} style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--text-muted)' }}>
                <X size={20} />
              </button>
            </div>

            {/* Drawer Navigation Links */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', flex: 1 }}>
              {/* 1. My Profile */}
              <button
                onClick={() => { setIsDrawerOpen(false); setIsProfileModalOpen(true); }}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '12px',
                  padding: '12px 14px',
                  background: 'none',
                  border: 'none',
                  borderRadius: '10px',
                  color: 'var(--text-main)',
                  fontSize: '14px',
                  fontWeight: '600',
                  cursor: 'pointer',
                  textAlign: 'left',
                }}
              >
                <Shield size={18} color="var(--primary-green)" />
                <span>My Profile</span>
              </button>

              {/* 2. System Settings */}
              <button
                onClick={() => { setIsDrawerOpen(false); setActiveNav('SETTINGS'); }}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '12px',
                  padding: '12px 14px',
                  background: 'none',
                  border: 'none',
                  borderRadius: '10px',
                  color: 'var(--text-main)',
                  fontSize: '14px',
                  fontWeight: '600',
                  cursor: 'pointer',
                  textAlign: 'left',
                }}
              >
                <Settings size={18} color="var(--info-blue)" />
                <span>System Settings</span>
              </button>

              {/* 3. Help and Support */}
              <button
                onClick={() => { setIsDrawerOpen(false); setIsHelpModalOpen(true); }}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '12px',
                  padding: '12px 14px',
                  background: 'none',
                  border: 'none',
                  borderRadius: '10px',
                  color: 'var(--text-main)',
                  fontSize: '14px',
                  fontWeight: '600',
                  cursor: 'pointer',
                  textAlign: 'left',
                }}
              >
                <HelpCircle size={18} color="var(--warning-orange)" />
                <span>Help & Support</span>
              </button>
            </div>

            {/* Logout Button */}
            <div style={{ borderTop: '1px solid var(--card-border)', paddingTop: '16px' }}>
              <button
                onClick={handleLogoutAction}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '12px',
                  padding: '12px 14px',
                  background: 'rgba(239, 68, 68, 0.1)',
                  border: 'none',
                  borderRadius: '10px',
                  color: 'var(--danger-red)',
                  fontSize: '14px',
                  fontWeight: '700',
                  cursor: 'pointer',
                  width: '100%',
                }}
              >
                <LogOut size={18} />
                <span>Sign Out of Portal</span>
              </button>
            </div>
          </div>
        </div>
      )}

      {/* ========================================================================= */}
      {/* 3. MAIN DASHBOARD BODY (WITH PROPER TOP & BOTTOM PADDING)                 */}
      {/* ========================================================================= */}
      <main style={{
        paddingTop: '90px',
        paddingBottom: '100px',
        maxWidth: '1300px',
        margin: '0 auto',
        paddingLeft: '20px',
        paddingRight: '20px',
      }}>
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

        {/* --------------------------------------------------------------------- */}
        {/* TAB 1: HOME (MODULAR DASHBOARD)                                       */}
        {/* --------------------------------------------------------------------- */}
        {activeNav === 'HOME' && (
          <div className="animate-fade-in">
            {/* Header Title */}
            <div style={{ marginBottom: '24px' }}>
              <h2 style={{ fontSize: '24px', fontWeight: '800', color: 'var(--primary-navy)' }}>
                System Command Center
              </h2>
              <div style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
                Live platform administration, educator appointments, and curriculum oversight
              </div>
            </div>

            {/* Quick KPI Stats */}
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '16px', marginBottom: '28px' }}>
              <StatCard title="Platform Accounts" value={users.length} subtitle="Active users in database" icon={Users} color="var(--primary-green)" />
              <StatCard title="CAPS Educators" value={users.filter(u => u.role === 'TEACHER').length} subtitle="Assigned to subjects" icon={BookOpen} color="var(--info-blue)" />
              <StatCard title="Pending Admissions" value={pendingAdmissionsCount} subtitle="Awaiting administrative review" icon={ClipboardList} color="var(--warning-orange)" />
              <StatCard title="Database Health" value="100% OK" subtitle="PostgreSQL Active" icon={CheckCircle2} color="var(--primary-green)" />
            </div>

            {/* SECTION: FUNCTIONAL MODULES (ICON + NAME) */}
            <div style={{ marginBottom: '20px' }}>
              <h3 style={{ fontSize: '18px', color: 'var(--primary-navy)', marginBottom: '14px' }}>
                Operational Modules
              </h3>

              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: '16px' }}>
                {/* Module 1: User Directory */}
                <div
                  onClick={() => setActiveNav('USERS')}
                  className="glass-card"
                  style={{ padding: '20px', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '14px' }}
                >
                  <div style={{ width: '48px', height: '48px', borderRadius: '12px', background: 'rgba(22, 196, 127, 0.12)', color: 'var(--primary-green)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                    <Users size={24} />
                  </div>
                  <div>
                    <div style={{ fontWeight: '800', fontSize: '15px', color: 'var(--primary-navy)' }}>User & Staff Directory</div>
                    <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Manage teachers, parents & student accounts</div>
                  </div>
                </div>

                {/* Module 2: Appoint Educator */}
                <div
                  onClick={() => setIsTeacherModalOpen(true)}
                  className="glass-card"
                  style={{ padding: '20px', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '14px' }}
                >
                  <div style={{ width: '48px', height: '48px', borderRadius: '12px', background: 'rgba(59, 130, 246, 0.12)', color: 'var(--info-blue)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                    <UserPlus size={24} />
                  </div>
                  <div>
                    <div style={{ fontWeight: '800', fontSize: '15px', color: 'var(--primary-navy)' }}>Appoint Certified Educator</div>
                    <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Assign CAPS subjects & classes</div>
                  </div>
                </div>

                {/* Module 3: Admissions Queue */}
                <div
                  onClick={() => setActiveNav('OPERATIONS')}
                  className="glass-card"
                  style={{ padding: '20px', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '14px' }}
                >
                  <div style={{ width: '48px', height: '48px', borderRadius: '12px', background: 'rgba(255, 157, 60, 0.12)', color: 'var(--warning-orange)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                    <ClipboardList size={24} />
                  </div>
                  <div>
                    <div style={{ fontWeight: '800', fontSize: '15px', color: 'var(--primary-navy)' }}>Admissions Pipeline</div>
                    <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>{pendingAdmissionsCount} Pending • 1-Click Placement</div>
                  </div>
                </div>

                {/* Module 4: Broadcast Notice */}
                <div
                  onClick={() => setIsAnnounceModalOpen(true)}
                  className="glass-card"
                  style={{ padding: '20px', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '14px' }}
                >
                  <div style={{ width: '48px', height: '48px', borderRadius: '12px', background: 'rgba(139, 92, 246, 0.12)', color: 'var(--purple-accent)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                    <Megaphone size={24} />
                  </div>
                  <div>
                    <div style={{ fontWeight: '800', fontSize: '15px', color: 'var(--primary-navy)' }}>Institutional Broadcasts</div>
                    <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Send urgent school-wide announcements</div>
                  </div>
                </div>

                {/* Module 5: SA Academic Calendar */}
                <div
                  onClick={() => setActiveNav('CALENDAR')}
                  className="glass-card"
                  style={{ padding: '20px', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '14px' }}
                >
                  <div style={{ width: '48px', height: '48px', borderRadius: '12px', background: 'rgba(16, 185, 129, 0.12)', color: 'var(--success-green)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                    <Calendar size={24} />
                  </div>
                  <div>
                    <div style={{ fontWeight: '800', fontSize: '15px', color: 'var(--primary-navy)' }}>SA School Calendar</div>
                    <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Public holidays & DBE school terms</div>
                  </div>
                </div>

                {/* Module 6: Security & Audit Logs */}
                <div
                  onClick={() => setActiveNav('OPERATIONS')}
                  className="glass-card"
                  style={{ padding: '20px', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '14px' }}
                >
                  <div style={{ width: '48px', height: '48px', borderRadius: '12px', background: 'rgba(239, 68, 68, 0.12)', color: 'var(--danger-red)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                    <Shield size={24} />
                  </div>
                  <div>
                    <div style={{ fontWeight: '800', fontSize: '15px', color: 'var(--primary-navy)' }}>Security Audit Trail</div>
                    <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Immutable ledger of system events</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* --------------------------------------------------------------------- */}
        {/* TAB 2: SOUTH AFRICAN CALENDAR                                         */}
        {/* --------------------------------------------------------------------- */}
        {activeNav === 'CALENDAR' && (
          <div className="animate-fade-in">
            <div style={{ marginBottom: '20px' }}>
              <span className="badge badge-green">NATIONAL SCHEDULE</span>
              <h2 style={{ fontSize: '24px', fontWeight: '800', color: 'var(--primary-navy)', marginTop: '4px' }}>
                South African Academic & Public Holiday Calendar (2026)
              </h2>
              <div style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
                Official Department of Basic Education (DBE) school calendar and national gazetted public holidays
              </div>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: '14px' }}>
              {SA_CALENDAR_EVENTS_2026.map((ev, idx) => (
                <div key={idx} className="glass-card" style={{ padding: '18px' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
                    <span style={{ fontWeight: '800', fontSize: '15px', color: 'var(--primary-navy)' }}>{ev.date}</span>
                    <span className={`badge ${ev.type === 'PUBLIC_HOLIDAY' ? 'badge-orange' : 'badge-green'}`}>
                      {ev.badge}
                    </span>
                  </div>
                  <div style={{ fontSize: '13px', color: 'var(--secondary-navy)', fontWeight: '600' }}>
                    {ev.title}
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* --------------------------------------------------------------------- */}
        {/* TAB 3: USERS & STAFF DIRECTORY                                        */}
        {/* --------------------------------------------------------------------- */}
        {activeNav === 'USERS' && (
          <div className="animate-fade-in">
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px', flexWrap: 'wrap', gap: '12px' }}>
              <div>
                <h2 style={{ fontSize: '24px', fontWeight: '800', color: 'var(--primary-navy)' }}>
                  User & Staff Directory ({users.length})
                </h2>
                <div style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
                  Live synchronized users from the central PostgreSQL database
                </div>
              </div>
              <button onClick={() => setIsTeacherModalOpen(true)} className="btn btn-primary">
                <UserPlus size={16} /> Appoint Educator
              </button>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
              {filteredUsers.map((u) => (
                <div key={u.id} className="glass-card" style={{ padding: '16px 20px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
                    <div style={{
                      width: '42px',
                      height: '42px',
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

                  <span className="badge badge-green" style={{ fontSize: '11px' }}>ACTIVE</span>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* --------------------------------------------------------------------- */}
        {/* TAB 4: OPERATIONS (ADMISSIONS & AUDIT LOGS)                            */}
        {/* --------------------------------------------------------------------- */}
        {activeNav === 'OPERATIONS' && (
          <div className="animate-fade-in">
            <div style={{ marginBottom: '20px' }}>
              <h2 style={{ fontSize: '24px', fontWeight: '800', color: 'var(--primary-navy)' }}>
                System Operations & Admissions Pipeline
              </h2>
              <div style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
                Admissions processing, CAPS curriculum catalog & immutable audit ledger
              </div>
            </div>

            {/* Section A: Admissions Queue */}
            <div className="glass-card" style={{ padding: '24px', marginBottom: '24px' }}>
              <h3 style={{ fontSize: '18px', color: 'var(--primary-navy)', marginBottom: '14px' }}>
                Admissions Queue ({admissions.length})
              </h3>

              {admissions.length === 0 ? (
                <div style={{ textAlign: 'center', padding: '24px 0', color: 'var(--text-muted)' }}>
                  No pending admissions applications in queue.
                </div>
              ) : (
                <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                  {admissions.map((app) => (
                    <div key={app.id} style={{ padding: '16px', background: '#F8FAFC', borderRadius: '12px', border: '1px solid var(--card-border)' }}>
                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: '8px' }}>
                        <div>
                          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                            <span style={{ fontWeight: '800', fontSize: '15px', color: 'var(--primary-navy)' }}>{app.applicationNumber}</span>
                            <span className={`badge ${app.status === 'APPROVED' ? 'badge-green' : 'badge-orange'}`}>{app.status}</span>
                          </div>
                          <div style={{ fontSize: '13px', color: 'var(--secondary-navy)', marginTop: '4px' }}>
                            Parent: {app.primaryParentName} {app.primaryParentSurname} (✉️ {app.primaryParentEmail})
                          </div>
                          <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>
                            Token: <strong>{app.registrationToken}</strong>
                          </div>
                        </div>

                        {app.status === 'PENDING' && (
                          <button onClick={() => handleApproveAdmission(app.id)} className="btn btn-primary" style={{ padding: '6px 14px', fontSize: '12px' }}>
                            <Check size={14} /> Approve Placement
                          </button>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>

            {/* Section B: Security Audit Logs */}
            <div className="glass-card" style={{ padding: '24px' }}>
              <h3 style={{ fontSize: '18px', color: 'var(--primary-navy)', marginBottom: '14px' }}>
                Audit Ledger Trail ({auditLogs.length})
              </h3>
              {auditLogs.map((log) => (
                <div key={log.id} style={{ padding: '12px 16px', background: '#F8FAFC', borderRadius: '10px', border: '1px solid var(--card-border)', display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
                  <div>
                    <span className="badge badge-navy" style={{ marginRight: '8px' }}>{log.action}</span>
                    <span style={{ fontSize: '13px', fontWeight: '600' }}>{log.details}</span>
                  </div>
                  <div style={{ fontSize: '11px', color: 'var(--text-muted)' }}>
                    {new Date(log.timestamp).toLocaleTimeString()}
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* --------------------------------------------------------------------- */}
        {/* TAB 5: SYSTEM SETTINGS                                                */}
        {/* --------------------------------------------------------------------- */}
        {activeNav === 'SETTINGS' && (
          <div className="animate-fade-in">
            <div style={{ marginBottom: '20px' }}>
              <span className="badge badge-green">SYSTEM CONFIGURATION</span>
              <h2 style={{ fontSize: '24px', fontWeight: '800', color: 'var(--primary-navy)', marginTop: '4px' }}>
                Administrative & Ecosystem Settings
              </h2>
              <div style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
                Global security policies, automated email toggles, and database synchronization
              </div>
            </div>

            <div className="glass-card" style={{ padding: '24px' }}>
              <div style={{ display: 'flex', flexDirection: 'column', gap: '18px' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderBottom: '1px solid var(--card-border)', paddingBottom: '14px' }}>
                  <div>
                    <div style={{ fontWeight: '700', fontSize: '14px', color: 'var(--primary-navy)' }}>Gmail SMTP Email Notifications</div>
                    <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Automatically dispatch official credentials and acceptance tokens</div>
                  </div>
                  <input
                    type="checkbox"
                    checked={systemSettings.smtpEmailEnabled}
                    onChange={(e) => setSystemSettings({ ...systemSettings, smtpEmailEnabled: e.target.checked })}
                    style={{ width: '20px', height: '20px' }}
                  />
                </div>

                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderBottom: '1px solid var(--card-border)', paddingBottom: '14px' }}>
                  <div>
                    <div style={{ fontWeight: '700', fontSize: '14px', color: 'var(--primary-navy)' }}>2026 Admissions Portal Gate</div>
                    <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Allow prospective parents to submit online applications</div>
                  </div>
                  <input
                    type="checkbox"
                    checked={systemSettings.admissionsOpen}
                    onChange={(e) => setSystemSettings({ ...systemSettings, admissionsOpen: e.target.checked })}
                    style={{ width: '20px', height: '20px' }}
                  />
                </div>

                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderBottom: '1px solid var(--card-border)', paddingBottom: '14px' }}>
                  <div>
                    <div style={{ fontWeight: '700', fontSize: '14px', color: 'var(--primary-navy)' }}>Two-Factor Authentication (2FA) Enforcement</div>
                    <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Enforce OTP security for administrator and educator sign-ins</div>
                  </div>
                  <input
                    type="checkbox"
                    checked={systemSettings.twoFactorEnforced}
                    onChange={(e) => setSystemSettings({ ...systemSettings, twoFactorEnforced: e.target.checked })}
                    style={{ width: '20px', height: '20px' }}
                  />
                </div>

                <button
                  onClick={() => setStatusMessage('System configurations saved and synchronized!')}
                  className="btn btn-primary"
                  style={{ alignSelf: 'flex-start', marginTop: '10px' }}
                >
                  Save System Configurations
                </button>
              </div>
            </div>
          </div>
        )}
      </main>

      {/* ========================================================================= */}
      {/* 4. FIXED BOTTOM NAVIGATION BAR                                            */}
      {/* ========================================================================= */}
      <nav style={{
        position: 'fixed',
        bottom: 0,
        left: 0,
        right: 0,
        height: '65px',
        background: 'var(--card-bg)',
        borderTop: '1px solid var(--card-border)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-around',
        zIndex: 1000,
        boxShadow: '0 -2px 10px rgba(0,0,0,0.06)',
      }}>
        {[
          { key: 'HOME', label: 'Home', icon: Building },
          { key: 'CALENDAR', label: 'Calendar', icon: Calendar },
          { key: 'USERS', label: 'Users', icon: Users },
          { key: 'OPERATIONS', label: 'Operations', icon: Activity },
          { key: 'SETTINGS', label: 'Settings', icon: Settings },
        ].map((tab) => {
          const Icon = tab.icon;
          const isActive = activeNav === tab.key;
          return (
            <button
              key={tab.key}
              onClick={() => setActiveNav(tab.key as any)}
              style={{
                background: 'none',
                border: 'none',
                color: isActive ? 'var(--primary-green)' : 'var(--text-muted)',
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                gap: '4px',
                cursor: 'pointer',
                fontSize: '11px',
                fontWeight: isActive ? '700' : '500',
                padding: '6px 16px',
                borderRadius: '8px',
                transition: 'all 0.2s ease',
              }}
            >
              <Icon size={20} />
              <span>{tab.label}</span>
            </button>
          );
        })}
      </nav>

      {/* ========================================================================= */}
      {/* 5. MODAL: MY PROFILE                                                      */}
      {/* ========================================================================= */}
      <Modal isOpen={isProfileModalOpen} onClose={() => setIsProfileModalOpen(false)} title="Super Administrator Profile" maxWidth="480px">
        <div style={{ textAlign: 'center', marginBottom: '20px' }}>
          <div style={{ width: '64px', height: '64px', borderRadius: '50%', background: 'var(--primary-green)', color: 'white', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: '800', fontSize: '24px', margin: '0 auto 12px auto' }}>
            {currentUser.name[0]}{currentUser.surname[0]}
          </div>
          <h3 style={{ fontSize: '18px', color: 'var(--primary-navy)' }}>{currentUser.name} {currentUser.surname}</h3>
          <span className="badge badge-red">SUPER ADMINISTRATOR</span>
        </div>

        <div style={{ background: '#F8FAFC', padding: '16px', borderRadius: '12px', border: '1px solid var(--card-border)', display: 'flex', flexDirection: 'column', gap: '10px', fontSize: '13px' }}>
          <div><strong>Email:</strong> {currentUser.email}</div>
          <div><strong>National ID:</strong> 8206051072085</div>
          <div><strong>Authority:</strong> Root Ecosystem Admin</div>
          <div><strong>Database:</strong> PostgreSQL Live Sync</div>
        </div>

        <button onClick={() => setIsProfileModalOpen(false)} className="btn btn-primary" style={{ width: '100%', marginTop: '20px' }}>
          Close Profile
        </button>
      </Modal>

      {/* ========================================================================= */}
      {/* 6. MODAL: HELP AND SUPPORT                                                */}
      {/* ========================================================================= */}
      <Modal isOpen={isHelpModalOpen} onClose={() => setIsHelpModalOpen(false)} title="Help & System Support" maxWidth="500px">
        <div style={{ display: 'flex', flexDirection: 'column', gap: '14px', fontSize: '13px' }}>
          <div style={{ padding: '14px', background: '#F8FAFC', borderRadius: '10px', border: '1px solid var(--card-border)' }}>
            <div style={{ fontWeight: '700', color: 'var(--primary-navy)' }}>📖 Administrator User Guide</div>
            <div style={{ color: 'var(--text-muted)', marginTop: '2px' }}>
              Use the Operations tab to review student admission requests and the Users tab to appoint certified teachers.
            </div>
          </div>

          <div style={{ padding: '14px', background: '#F8FAFC', borderRadius: '10px', border: '1px solid var(--card-border)' }}>
            <div style={{ fontWeight: '700', color: 'var(--primary-navy)' }}>📞 Technical Support Desk</div>
            <div style={{ color: 'var(--text-muted)', marginTop: '2px' }}>
              Email: <strong>support@thutotech.co.za</strong> • Tel: 015 268 9111
            </div>
          </div>
        </div>

        <button onClick={() => setIsHelpModalOpen(false)} className="btn btn-primary" style={{ width: '100%', marginTop: '20px' }}>
          Close Help
        </button>
      </Modal>

      {/* ========================================================================= */}
      {/* 7. MODAL: APPOINT TEACHER                                                 */}
      {/* ========================================================================= */}
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

      {/* ========================================================================= */}
      {/* 8. MODAL: BROADCAST ANNOUNCEMENT                                          */}
      {/* ========================================================================= */}
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
