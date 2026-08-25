import React from 'react';
import { User } from '../../types';
import { StatCard } from '../../components/StatCard';
import { Users, BookOpen, CheckCircle2, ShieldCheck, Mail } from 'lucide-react';

interface ParentDashboardProps {
  currentUser: User;
}

export const ParentDashboard: React.FC<ParentDashboardProps> = ({ currentUser }) => {
  return (
    <div style={{ maxWidth: '1200px', margin: '32px auto', padding: '0 20px' }}>
      <div style={{ marginBottom: '24px' }}>
        <span className="badge badge-green">VERIFIED PARENT / GUARDIAN PORTAL</span>
        <h2 style={{ fontSize: '24px', fontWeight: '800', color: 'var(--primary-navy)', marginTop: '4px' }}>
          Welcome, {currentUser.name} {currentUser.surname}
        </h2>
        <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
          Real-Time Academic Progress, Attendance Monitoring & School Notices
        </p>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', gap: '16px', marginBottom: '28px' }}>
        <StatCard title="Enrolled Children" value="Active" subtitle="Linked to parent profile" icon={Users} color="var(--primary-green)" />
        <StatCard title="Attendance Average" value="98.0%" subtitle="Threshold: 85% requirement" icon={CheckCircle2} color="var(--info-blue)" />
        <StatCard title="Academic Progress" value="84.5%" subtitle="CAPS Term Aggregate" icon={BookOpen} color="var(--primary-green)" />
      </div>

      <div className="glass-card" style={{ padding: '24px', backgroundColor: '#FFFFFF', marginBottom: '20px' }}>
        <h3 style={{ fontSize: '18px', color: 'var(--primary-navy)', marginBottom: '12px', display: 'flex', alignItems: 'center', gap: '8px' }}>
          <ShieldCheck size={20} color="var(--primary-green)" />
          Linked Enrolment Details
        </h3>
        <p style={{ fontSize: '13px', color: 'var(--text-muted)', marginBottom: '16px' }}>
          All official term report cards, attendance records, and student login keys are delivered directly to your verified email address (<strong>{currentUser.email}</strong>).
        </p>
        <div style={{ background: '#F8FAFC', padding: '16px', borderRadius: '12px', border: '1px solid var(--card-border)', display: 'flex', alignItems: 'center', gap: '12px' }}>
          <Mail size={22} color="var(--primary-green)" />
          <div style={{ fontSize: '13px', color: 'var(--secondary-navy)' }}>
            Institutional announcements and automated mark notifications are synced to your registered email in real-time.
          </div>
        </div>
      </div>
    </div>
  );
};
