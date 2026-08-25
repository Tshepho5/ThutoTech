import React, { useState } from 'react';
import { User } from '../../types';
import { StatCard } from '../../components/StatCard';
import { Modal } from '../../components/Modal';
import { BookOpen, CheckSquare, Plus, FileText, CheckCircle2 } from 'lucide-react';

interface TeacherDashboardProps {
  currentUser: User;
}

export const TeacherDashboard: React.FC<TeacherDashboardProps> = ({ currentUser }) => {
  const [isAssignmentModalOpen, setIsAssignmentModalOpen] = useState(false);
  const [title, setTitle] = useState('');
  const [desc, setDesc] = useState('');
  const [subject, setSubject] = useState('Mathematics');
  const [targetClass, setTargetClass] = useState('Grade 10A');
  const [dueDate, setDueDate] = useState('');
  const [maxMarks, setMaxMarks] = useState('100');
  const [statusMsg, setStatusMsg] = useState<string | null>(null);

  const handleCreateAssignment = (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim()) return;
    setStatusMsg(`Assignment "${title}" published to ${targetClass} (${subject})!`);
    setIsAssignmentModalOpen(false);
    setTitle('');
    setDesc('');
  };

  return (
    <div style={{ maxWidth: '1200px', margin: '32px auto', padding: '0 20px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px', flexWrap: 'wrap', gap: '12px' }}>
        <div>
          <span className="badge badge-green">CERTIFIED EDUCATOR CONSOLE</span>
          <h2 style={{ fontSize: '24px', fontWeight: '800', color: 'var(--primary-navy)', marginTop: '4px' }}>
            Welcome, {currentUser.name} {currentUser.surname}
          </h2>
          <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
            Curriculum Delivery, Gradebook & Class Attendance
          </p>
        </div>

        <button onClick={() => setIsAssignmentModalOpen(true)} className="btn btn-primary">
          <Plus size={16} /> Create New Assignment
        </button>
      </div>

      {statusMsg && (
        <div style={{ background: 'rgba(22, 196, 127, 0.15)', border: '1px solid var(--primary-green)', color: '#0F766E', padding: '12px 16px', borderRadius: '12px', fontSize: '13px', display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '20px' }}>
          <CheckCircle2 size={18} />
          <span>{statusMsg}</span>
        </div>
      )}

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', gap: '16px', marginBottom: '28px' }}>
        <StatCard title="Assigned Subjects" value="2" subtitle="Mathematics, Physical Sciences" icon={BookOpen} color="var(--primary-green)" />
        <StatCard title="Enrolled Learners" value="38" subtitle="Grade 10A, Grade 11A" icon={CheckSquare} color="var(--info-blue)" />
        <StatCard title="Class Attendance" value="98.5%" subtitle="Weekly aggregate average" icon={CheckCircle2} color="var(--primary-green)" />
      </div>

      <div className="glass-card" style={{ padding: '24px', backgroundColor: '#FFFFFF' }}>
        <h3 style={{ fontSize: '18px', color: 'var(--primary-navy)', marginBottom: '14px', display: 'flex', alignItems: 'center', gap: '8px' }}>
          <FileText size={20} color="var(--primary-green)" />
          Recent Class Assignments
        </h3>

        <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
          <div style={{ padding: '14px', background: '#F8FAFC', borderRadius: '12px', border: '1px solid var(--card-border)', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div>
              <div style={{ fontWeight: '700', fontSize: '15px', color: 'var(--primary-navy)' }}>
                Term 1 Analytical Geometry Task
              </div>
              <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>
                Mathematics • Grade 10A • Max Marks: 50
              </div>
            </div>
            <span className="badge badge-green">PUBLISHED</span>
          </div>

          <div style={{ padding: '14px', background: '#F8FAFC', borderRadius: '12px', border: '1px solid var(--card-border)', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div>
              <div style={{ fontWeight: '700', fontSize: '15px', color: 'var(--primary-navy)' }}>
                Mechanics & Vector Forces Lab Experiment
              </div>
              <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>
                Physical Sciences • Grade 11A • Max Marks: 100
              </div>
            </div>
            <span className="badge badge-green">PUBLISHED</span>
          </div>
        </div>
      </div>

      <Modal isOpen={isAssignmentModalOpen} onClose={() => setIsAssignmentModalOpen(false)} title="Create New Class Assignment" maxWidth="500px">
        <form onSubmit={handleCreateAssignment}>
          <div className="form-group">
            <label className="form-label">Assignment Title *</label>
            <input type="text" className="form-control" placeholder="e.g. Algebraic Functions Investigation" value={title} onChange={(e) => setTitle(e.target.value)} required />
          </div>

          <div className="form-group">
            <label className="form-label">Description / Instructions</label>
            <textarea className="form-control" rows={3} placeholder="Provide instructions for learners..." value={desc} onChange={(e) => setDesc(e.target.value)} />
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
            <div className="form-group">
              <label className="form-label">Subject</label>
              <select className="form-control" value={subject} onChange={(e) => setSubject(e.target.value)}>
                <option value="Mathematics">Mathematics</option>
                <option value="Physical Sciences">Physical Sciences</option>
                <option value="Life Sciences">Life Sciences</option>
              </select>
            </div>
            <div className="form-group">
              <label className="form-label">Target Class</label>
              <select className="form-control" value={targetClass} onChange={(e) => setTargetClass(e.target.value)}>
                <option value="Grade 10A">Grade 10A</option>
                <option value="Grade 11A">Grade 11A</option>
                <option value="Grade 12A">Grade 12A</option>
              </select>
            </div>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
            <div className="form-group">
              <label className="form-label">Due Date</label>
              <input type="date" className="form-control" value={dueDate} onChange={(e) => setDueDate(e.target.value)} />
            </div>
            <div className="form-group">
              <label className="form-label">Total Marks</label>
              <input type="number" className="form-control" value={maxMarks} onChange={(e) => setMaxMarks(e.target.value)} />
            </div>
          </div>

          <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px', marginTop: '20px' }}>
            <button type="button" onClick={() => setIsAssignmentModalOpen(false)} className="btn btn-outline">Cancel</button>
            <button type="submit" className="btn btn-primary">Publish to Class</button>
          </div>
        </form>
      </Modal>
    </div>
  );
};
