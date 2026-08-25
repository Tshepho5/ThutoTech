import React from 'react';
import { User } from '../../types';
import { StatCard } from '../../components/StatCard';
import { BookOpen, FileText, CheckCircle2, Award } from 'lucide-react';

interface LearnerDashboardProps {
  currentUser: User;
}

export const LearnerDashboard: React.FC<LearnerDashboardProps> = ({ currentUser }) => {
  return (
    <div style={{ maxWidth: '1200px', margin: '32px auto', padding: '0 20px' }}>
      <div style={{ marginBottom: '24px' }}>
        <span className="badge badge-green">STUDENT ACADEMIC DESK</span>
        <h2 style={{ fontSize: '24px', fontWeight: '800', color: 'var(--primary-navy)', marginTop: '4px' }}>
          Welcome, {currentUser.name} {currentUser.surname}
        </h2>
        <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
          CAPS Curriculum Timetable, Homework Submissions & Learning Hub
        </p>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', gap: '16px', marginBottom: '28px' }}>
        <StatCard title="Enrolled Subjects" value="7" subtitle="CAPS FET Academic Stream" icon={BookOpen} color="var(--primary-green)" />
        <StatCard title="Pending Assignments" value="0" subtitle="All current tasks submitted" icon={CheckCircle2} color="var(--info-blue)" />
        <StatCard title="Academic Merit" value="Level 7" subtitle="Distinction Aggregate" icon={Award} color="var(--primary-green)" />
      </div>

      <div className="glass-card" style={{ padding: '24px', backgroundColor: '#FFFFFF' }}>
        <h3 style={{ fontSize: '18px', color: 'var(--primary-navy)', marginBottom: '14px', display: 'flex', alignItems: 'center', gap: '8px' }}>
          <FileText size={20} color="var(--primary-green)" />
          Active Enrolled CAPS Subjects
        </h3>

        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: '12px' }}>
          {['Mathematics', 'Physical Sciences', 'Life Sciences', 'English FAL', 'Sepedi Home Language', 'Life Orientation', 'Information Technology'].map((sub, i) => (
            <div key={i} style={{ padding: '14px', background: '#F8FAFC', borderRadius: '12px', border: '1px solid var(--card-border)' }}>
              <div style={{ fontWeight: '700', fontSize: '14px', color: 'var(--primary-navy)' }}>{sub}</div>
              <div style={{ fontSize: '11px', color: 'var(--text-muted)', marginTop: '2px' }}>CAPS Standard • Enrolled</div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};
