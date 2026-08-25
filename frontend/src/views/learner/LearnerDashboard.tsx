import React, { useState } from 'react';
import { User } from '../../types';
import { StatCard } from '../../components/StatCard';
import {
  BookOpen,
  FileText,
  CheckCircle2,
  Award,
  Calendar,
  Clock,
  Download,
  Upload
} from 'lucide-react';

interface LearnerDashboardProps {
  currentUser: User;
}

export const LearnerDashboard: React.FC<LearnerDashboardProps> = ({ currentUser }) => {
  const [activeTab, setActiveTab] = useState<'SUBJECTS' | 'ASSIGNMENTS' | 'TIMETABLE' | 'HONORS'>('SUBJECTS');

  return (
    <div style={{ maxWidth: '1300px', margin: '32px auto', padding: '0 20px' }}>
      {/* Header */}
      <div style={{ marginBottom: '24px' }}>
        <span className="badge badge-green">STUDENT ACADEMIC DESK</span>
        <h2 style={{ fontSize: '24px', fontWeight: '800', color: 'var(--primary-navy)', marginTop: '4px' }}>
          Welcome, {currentUser.name} {currentUser.surname}
        </h2>
        <div style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
          CAPS Curriculum Timetable, Homework Submissions & Learning Hub
        </div>
      </div>

      {/* Telemetry Stats */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '16px', marginBottom: '28px' }}>
        <StatCard title="Enrolled Subjects" value="7" subtitle="CAPS FET Science Stream" icon={BookOpen} color="var(--primary-green)" />
        <StatCard title="Completed Tasks" value="12" subtitle="All homework up to date" icon={CheckCircle2} color="var(--info-blue)" />
        <StatCard title="Academic Merit" value="Level 7" subtitle="Distinction Aggregate" icon={Award} color="var(--primary-green)" />
        <StatCard title="Class Attendance" value="98%" subtitle="Exemplary punctuality" icon={Clock} color="var(--purple-accent)" />
      </div>

      {/* Module Navigation */}
      <div style={{ display: 'flex', gap: '8px', borderBottom: '1px solid var(--card-border)', marginBottom: '20px' }}>
        {[
          { key: 'SUBJECTS', label: 'Enrolled Subjects', icon: BookOpen },
          { key: 'ASSIGNMENTS', label: 'Assignments & Submissions', icon: FileText },
          { key: 'TIMETABLE', label: 'Class Timetable', icon: Calendar },
          { key: 'HONORS', label: 'Term Honors & Reports', icon: Award },
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

      {/* MODULE 1: SUBJECTS */}
      {activeTab === 'SUBJECTS' && (
        <div className="glass-card animate-fade-in" style={{ padding: '24px', backgroundColor: '#FFFFFF' }}>
          <h3 style={{ fontSize: '18px', color: 'var(--primary-navy)', marginBottom: '16px' }}>Enrolled CAPS Curriculum Subjects</h3>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: '14px' }}>
            {[
              { name: 'Mathematics', code: 'MATH-FET', teacher: 'Mr. S. Dlamini' },
              { name: 'Physical Sciences', code: 'PHYS-FET', teacher: 'Mr. S. Dlamini' },
              { name: 'Life Sciences', code: 'LIFE-FET', teacher: 'Dr. N. Baloyi' },
              { name: 'English FAL', code: 'ENG-FAL', teacher: 'Mrs. K. Sithole' },
              { name: 'Sepedi Home Language', code: 'SEP-HL', teacher: 'Mr. M. Phasha' },
              { name: 'Life Orientation', code: 'LO-GEN', teacher: 'Ms. T. Ledwaba' },
              { name: 'Information Technology', code: 'IT-FET', teacher: 'Mr. L. Makola' },
            ].map((sub, idx) => (
              <div key={idx} style={{ padding: '16px', background: '#F8FAFC', borderRadius: '12px', border: '1px solid var(--card-border)' }}>
                <div style={{ fontWeight: '700', fontSize: '15px', color: 'var(--primary-navy)' }}>{sub.name}</div>
                <div style={{ fontSize: '12px', color: 'var(--text-muted)', marginTop: '2px' }}>Code: {sub.code} • Educator: {sub.teacher}</div>
                <div style={{ marginTop: '10px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <span className="badge badge-green" style={{ fontSize: '10px' }}>Active CAPS</span>
                  <button className="btn btn-outline" style={{ padding: '4px 10px', fontSize: '11px' }}>Study Resources</button>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* MODULE 2: ASSIGNMENTS */}
      {activeTab === 'ASSIGNMENTS' && (
        <div className="glass-card animate-fade-in" style={{ padding: '24px', backgroundColor: '#FFFFFF' }}>
          <h3 style={{ fontSize: '18px', color: 'var(--primary-navy)', marginBottom: '16px' }}>Pending & Submitted Assignments</h3>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
            <div style={{ padding: '16px', background: '#F8FAFC', borderRadius: '12px', border: '1px solid var(--card-border)', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div>
                <div style={{ fontWeight: '700', fontSize: '15px', color: 'var(--primary-navy)' }}>Analytical Geometry Task 1</div>
                <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Mathematics • Submitted • Score: 46/50 (92%)</div>
              </div>
              <span className="badge badge-green">MARKED</span>
            </div>

            <div style={{ padding: '16px', background: '#F8FAFC', borderRadius: '12px', border: '1px solid var(--card-border)', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div>
                <div style={{ fontWeight: '700', fontSize: '15px', color: 'var(--primary-navy)' }}>Mechanics & Vector Forces Lab Experiment</div>
                <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Physical Sciences • Due: 02 April 2026</div>
              </div>
              <button className="btn btn-primary" style={{ padding: '6px 14px', fontSize: '12px' }}>
                <Upload size={14} /> Submit Task
              </button>
            </div>
          </div>
        </div>
      )}

      {/* MODULE 3: TIMETABLE */}
      {activeTab === 'TIMETABLE' && (
        <div className="glass-card animate-fade-in" style={{ padding: '24px', backgroundColor: '#FFFFFF' }}>
          <h3 style={{ fontSize: '18px', color: 'var(--primary-navy)', marginBottom: '16px' }}>Daily Period Schedule</h3>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '12px' }}>
            {['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'].map((day, idx) => (
              <div key={idx} style={{ padding: '14px', background: '#F8FAFC', borderRadius: '12px', border: '1px solid var(--card-border)' }}>
                <div style={{ fontWeight: '800', color: 'var(--primary-navy)', fontSize: '14px', marginBottom: '8px' }}>{day}</div>
                <div style={{ fontSize: '11px', color: 'var(--primary-green)', fontWeight: 'bold' }}>Period 1 (08:00)</div>
                <div style={{ fontSize: '12px', fontWeight: 'bold', color: 'var(--primary-navy)' }}>Mathematics</div>
                <div style={{ fontSize: '11px', color: 'var(--info-blue)', fontWeight: 'bold', marginTop: '6px' }}>Period 2 (09:30)</div>
                <div style={{ fontSize: '12px', fontWeight: 'bold', color: 'var(--primary-navy)' }}>Physical Sciences</div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* MODULE 4: HONORS */}
      {activeTab === 'HONORS' && (
        <div className="glass-card animate-fade-in" style={{ padding: '24px', backgroundColor: '#FFFFFF' }}>
          <h3 style={{ fontSize: '18px', color: 'var(--primary-navy)', marginBottom: '14px' }}>Academic Distinctions & Report Cards</h3>
          <div style={{ padding: '16px', background: '#F8FAFC', borderRadius: '12px', border: '1px solid var(--card-border)', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <div>
              <div style={{ fontWeight: '700', fontSize: '15px', color: 'var(--primary-navy)' }}>Term 1 CAPS Official Report Card</div>
              <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Aggregate: 84.5% • Academic Honors Roll</div>
            </div>
            <button className="btn btn-outline" style={{ fontSize: '12px' }}>
              <Download size={14} /> Download PDF
            </button>
          </div>
        </div>
      )}
    </div>
  );
};
