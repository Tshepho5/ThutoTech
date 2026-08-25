import React, { useState } from 'react';
import { User } from '../../types';
import { StatCard } from '../../components/StatCard';
import {
  Users,
  BookOpen,
  CheckCircle2,
  ShieldCheck,
  Mail,
  Award,
  CreditCard,
  MessageSquare,
  Calendar
} from 'lucide-react';

interface ParentDashboardProps {
  currentUser: User;
}

export const ParentDashboard: React.FC<ParentDashboardProps> = ({ currentUser }) => {
  const [activeTab, setActiveTab] = useState<'ACADEMICS' | 'ATTENDANCE' | 'FINANCE' | 'COMMUNICATION'>('ACADEMICS');

  return (
    <div style={{ maxWidth: '1300px', margin: '32px auto', padding: '0 20px' }}>
      {/* Header */}
      <div style={{ marginBottom: '24px' }}>
        <span className="badge badge-green">VERIFIED PARENT / GUARDIAN PORTAL</span>
        <h2 style={{ fontSize: '24px', fontWeight: '800', color: 'var(--primary-navy)', marginTop: '4px' }}>
          Welcome, {currentUser.name} {currentUser.surname}
        </h2>
        <div style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
          Real-Time Academic Progress, Attendance Monitoring & School Notices
        </div>
      </div>

      {/* Telemetry Stats */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '16px', marginBottom: '28px' }}>
        <StatCard title="Enrolled Children" value="1 Active" subtitle="Grade 10A (Science)" icon={Users} color="var(--primary-green)" />
        <StatCard title="Attendance Average" value="98.0%" subtitle="Threshold: 85% requirement" icon={CheckCircle2} color="var(--info-blue)" />
        <StatCard title="Academic Progress" value="84.5%" subtitle="CAPS Level 7 Aggregate" icon={Award} color="var(--primary-green)" />
        <StatCard title="School Fees" value="R 0.00" subtitle="Account in Good Standing" icon={CreditCard} color="var(--purple-accent)" />
      </div>

      {/* Module Navigation */}
      <div style={{ display: 'flex', gap: '8px', borderBottom: '1px solid var(--card-border)', marginBottom: '20px' }}>
        {[
          { key: 'ACADEMICS', label: 'Academic Mark Sheet', icon: Award },
          { key: 'ATTENDANCE', label: 'Attendance Sentinel', icon: CheckCircle2 },
          { key: 'FINANCE', label: 'Fees & Statements', icon: CreditCard },
          { key: 'COMMUNICATION', label: 'Direct School Messages', icon: MessageSquare },
        ].map((mod) => {
          const Icon = mod.icon;
          const isActive = activeTab === mod.key;
          return (
            <button
              key={mod.key}
              onClick={() => setActiveTab(mod.key as any)}
              style={{
                background: 'none',
                border: 'none',
                borderBottom: isActive ? '3px solid var(--primary-green)' : '3px solid transparent',
                color: isActive ? 'var(--primary-navy)' : 'var(--text-muted)',
                padding: '10px 16px',
                fontFamily: 'var(--font-heading)',
                fontSize: '13px',
                fontWeight: isActive ? '700' : '500',
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                gap: '8px',
              }}
            >
              <Icon size={16} color={isActive ? 'var(--primary-green)' : 'var(--text-muted)'} />
              <span>{mod.label}</span>
            </button>
          );
        })}
      </div>

      {/* MODULE 1: ACADEMIC MARKS */}
      {activeTab === 'ACADEMICS' && (
        <div className="glass-card animate-fade-in" style={{ padding: '24px', backgroundColor: '#FFFFFF' }}>
          <h3 style={{ fontSize: '18px', color: 'var(--primary-navy)', marginBottom: '16px' }}>Term 1 CAPS Performance Breakdown</h3>
          <div style={{ overflowX: 'auto' }}>
            <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '13px' }}>
              <thead>
                <tr style={{ borderBottom: '2px solid var(--card-border)', textAlign: 'left' }}>
                  <th style={{ padding: '10px', color: 'var(--primary-navy)' }}>Subject</th>
                  <th style={{ padding: '10px', color: 'var(--primary-navy)' }}>Educator</th>
                  <th style={{ padding: '10px', color: 'var(--primary-navy)' }}>Term Score</th>
                  <th style={{ padding: '10px', color: 'var(--primary-navy)' }}>CAPS Achievement</th>
                </tr>
              </thead>
              <tbody>
                <tr style={{ borderBottom: '1px solid var(--card-border)' }}>
                  <td style={{ padding: '12px 10px', fontWeight: 'bold' }}>Mathematics</td>
                  <td style={{ padding: '12px 10px', color: 'var(--text-muted)' }}>Mr. S. Dlamini</td>
                  <td style={{ padding: '12px 10px', fontWeight: 'bold' }}>92%</td>
                  <td style={{ padding: '12px 10px' }}><span className="badge badge-green">Level 7 (Outstanding)</span></td>
                </tr>
                <tr style={{ borderBottom: '1px solid var(--card-border)' }}>
                  <td style={{ padding: '12px 10px', fontWeight: 'bold' }}>Physical Sciences</td>
                  <td style={{ padding: '12px 10px', color: 'var(--text-muted)' }}>Mr. S. Dlamini</td>
                  <td style={{ padding: '12px 10px', fontWeight: 'bold' }}>88%</td>
                  <td style={{ padding: '12px 10px' }}><span className="badge badge-green">Level 7 (Outstanding)</span></td>
                </tr>
                <tr style={{ borderBottom: '1px solid var(--card-border)' }}>
                  <td style={{ padding: '12px 10px', fontWeight: 'bold' }}>English FAL</td>
                  <td style={{ padding: '12px 10px', color: 'var(--text-muted)' }}>Mrs. K. Sithole</td>
                  <td style={{ padding: '12px 10px', fontWeight: 'bold' }}>81%</td>
                  <td style={{ padding: '12px 10px' }}><span className="badge badge-green">Level 7 (Outstanding)</span></td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* MODULE 2: ATTENDANCE SENTINEL */}
      {activeTab === 'ATTENDANCE' && (
        <div className="glass-card animate-fade-in" style={{ padding: '24px', backgroundColor: '#FFFFFF' }}>
          <h3 style={{ fontSize: '18px', color: 'var(--primary-navy)', marginBottom: '14px' }}>Automated Attendance Sentinel</h3>
          <div style={{ padding: '16px', background: '#F8FAFC', borderRadius: '12px', border: '1px solid var(--card-border)', display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '14px' }}>
            <div>
              <div style={{ fontWeight: '700', fontSize: '15px', color: 'var(--primary-navy)' }}>Official Enrolment Attendance</div>
              <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>98 out of 100 school days attended (No unexcused absences)</div>
            </div>
            <span className="badge badge-green">COMPLIANT (98%)</span>
          </div>
        </div>
      )}

      {/* MODULE 3: FINANCE */}
      {activeTab === 'FINANCE' && (
        <div className="glass-card animate-fade-in" style={{ padding: '24px', backgroundColor: '#FFFFFF' }}>
          <h3 style={{ fontSize: '18px', color: 'var(--primary-navy)', marginBottom: '14px' }}>Financial & Fee Statement</h3>
          <div style={{ padding: '16px', background: '#F8FAFC', borderRadius: '12px', border: '1px solid var(--card-border)', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <div>
              <div style={{ fontWeight: '700', fontSize: '15px', color: 'var(--primary-navy)' }}>2026 Annual Tuition & Technology Levies</div>
              <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Status: Paid in Full • Balance Outstanding: R 0.00</div>
            </div>
            <span className="badge badge-green">PAID IN FULL</span>
          </div>
        </div>
      )}

      {/* MODULE 4: COMMUNICATION */}
      {activeTab === 'COMMUNICATION' && (
        <div className="glass-card animate-fade-in" style={{ padding: '24px', backgroundColor: '#FFFFFF' }}>
          <h3 style={{ fontSize: '18px', color: 'var(--primary-navy)', marginBottom: '14px' }}>Institutional Communication Hub</h3>
          <div style={{ padding: '16px', background: '#F8FAFC', borderRadius: '12px', border: '1px solid var(--card-border)', display: 'flex', gap: '12px' }}>
            <Mail size={22} color="var(--primary-green)" style={{ flexShrink: 0 }} />
            <div>
              <div style={{ fontWeight: '700', fontSize: '14px', color: 'var(--primary-navy)' }}>Direct Email & SMS Synchronization Active</div>
              <div style={{ fontSize: '12px', color: 'var(--text-muted)', marginTop: '2px' }}>
                All notices, admission documents, and teacher messages are delivered directly to <strong>{currentUser.email}</strong>.
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
