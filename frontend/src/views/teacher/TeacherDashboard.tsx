import React, { useState } from 'react';
import { User } from '../../types';
import { StatCard } from '../../components/StatCard';
import { Modal } from '../../components/Modal';
import {
  BookOpen,
  CheckSquare,
  Plus,
  FileText,
  CheckCircle2,
  Calendar,
  Award,
  Users,
  Clock,
  Send,
  UserCheck
} from 'lucide-react';

interface TeacherDashboardProps {
  currentUser: User;
}

export const TeacherDashboard: React.FC<TeacherDashboardProps> = ({ currentUser }) => {
  const [activeModule, setActiveModule] = useState<'ASSIGNMENTS' | 'ATTENDANCE' | 'GRADEBOOK' | 'TIMETABLE'>('ASSIGNMENTS');

  // Modals & States
  const [isAssignmentModalOpen, setIsAssignmentModalOpen] = useState(false);
  const [title, setTitle] = useState('');
  const [desc, setDesc] = useState('');
  const [subject, setSubject] = useState('Mathematics');
  const [targetClass, setTargetClass] = useState('Grade 10A');
  const [dueDate, setDueDate] = useState('');
  const [maxMarks, setMaxMarks] = useState('100');
  const [statusMsg, setStatusMsg] = useState<string | null>(null);

  // Attendance Module State
  const [attendanceList, setAttendanceList] = useState([
    { id: '1', name: 'Lerato Makola', studentNo: '20260001', status: 'PRESENT' },
    { id: '2', name: 'Kagiso Molepo', studentNo: '20260002', status: 'PRESENT' },
    { id: '3', name: 'Thabo Mokoena', studentNo: '20260003', status: 'ABSENT' },
    { id: '4', name: 'Nthabiseng Baloyi', studentNo: '20260004', status: 'PRESENT' },
  ]);

  // Gradebook Module State
  const [gradeList, setGradeList] = useState([
    { id: '1', name: 'Lerato Makola', task: 'Analytical Geometry Task', mark: 46, total: 50, symbol: 'Level 7 (92%)' },
    { id: '2', name: 'Kagiso Molepo', task: 'Analytical Geometry Task', mark: 41, total: 50, symbol: 'Level 6 (82%)' },
    { id: '3', name: 'Thabo Mokoena', task: 'Analytical Geometry Task', mark: 35, total: 50, symbol: 'Level 5 (70%)' },
    { id: '4', name: 'Nthabiseng Baloyi', task: 'Analytical Geometry Task', mark: 48, total: 50, symbol: 'Level 7 (96%)' },
  ]);

  const handleCreateAssignment = (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim()) return;
    setStatusMsg(`Assignment "${title}" published to ${targetClass} (${subject})!`);
    setIsAssignmentModalOpen(false);
    setTitle('');
    setDesc('');
  };

  const toggleAttendance = (id: string, status: 'PRESENT' | 'ABSENT' | 'LATE') => {
    setAttendanceList(prev => prev.map(s => s.id === id ? { ...s, status } : s));
  };

  return (
    <div style={{ maxWidth: '1300px', margin: '32px auto', padding: '0 20px' }}>
      {/* Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px', flexWrap: 'wrap', gap: '12px' }}>
        <div>
          <span className="badge badge-green">CERTIFIED EDUCATOR CONSOLE</span>
          <h2 style={{ fontSize: '24px', fontWeight: '800', color: 'var(--primary-navy)', marginTop: '4px' }}>
            Welcome, {currentUser.name} {currentUser.surname}
          </h2>
          <div style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
            Curriculum Delivery, Gradebook & Class Attendance
          </div>
        </div>

        <div style={{ display: 'flex', gap: '10px' }}>
          <button onClick={() => setIsAssignmentModalOpen(true)} className="btn btn-primary">
            <Plus size={16} /> New Assignment
          </button>
        </div>
      </div>

      {statusMsg && (
        <div style={{ background: 'rgba(22, 196, 127, 0.15)', border: '1px solid var(--primary-green)', color: '#0F766E', padding: '12px 16px', borderRadius: '12px', fontSize: '13px', display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '20px' }}>
          <CheckCircle2 size={18} />
          <span>{statusMsg}</span>
        </div>
      )}

      {/* Telemetry Stats */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '16px', marginBottom: '28px' }}>
        <StatCard title="Assigned Subjects" value="2" subtitle="Mathematics, Physical Sciences" icon={BookOpen} color="var(--primary-green)" />
        <StatCard title="Enrolled Learners" value="38" subtitle="Grade 10A, Grade 11A" icon={Users} color="var(--info-blue)" />
        <StatCard title="Class Attendance" value="98.5%" subtitle="Weekly aggregate average" icon={UserCheck} color="var(--primary-green)" />
        <StatCard title="Term Average" value="84.2%" subtitle="CAPS Assessment Score" icon={Award} color="var(--purple-accent)" />
      </div>

      {/* Module Navigation */}
      <div style={{ display: 'flex', gap: '8px', borderBottom: '1px solid var(--card-border)', marginBottom: '20px' }}>
        {[
          { key: 'ASSIGNMENTS', label: 'Assignments Module', icon: FileText },
          { key: 'ATTENDANCE', label: 'Daily Attendance Register', icon: CheckSquare },
          { key: 'GRADEBOOK', label: 'CAPS Gradebook & Marks', icon: Award },
          { key: 'TIMETABLE', label: 'Weekly Schedule', icon: Calendar },
        ].map((mod) => {
          const Icon = mod.icon;
          const isActive = activeModule === mod.key;
          return (
            <button
              key={mod.key}
              onClick={() => setActiveModule(mod.key as any)}
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

      {/* MODULE 1: ASSIGNMENTS */}
      {activeModule === 'ASSIGNMENTS' && (
        <div className="glass-card animate-fade-in" style={{ padding: '24px', backgroundColor: '#FFFFFF' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
            <h3 style={{ fontSize: '18px', color: 'var(--primary-navy)' }}>Active Class Assignments</h3>
            <button onClick={() => setIsAssignmentModalOpen(true)} className="btn btn-outline" style={{ fontSize: '12px' }}>
              <Plus size={14} /> Create Assignment
            </button>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
            <div style={{ padding: '16px', background: '#F8FAFC', borderRadius: '12px', border: '1px solid var(--card-border)', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div>
                <div style={{ fontWeight: '700', fontSize: '15px', color: 'var(--primary-navy)' }}>
                  Term 1 Analytical Geometry Investigation
                </div>
                <div style={{ fontSize: '12px', color: 'var(--text-muted)', marginTop: '2px' }}>
                  Mathematics • Grade 10A • Due: 28 March 2026 • Max Marks: 50
                </div>
              </div>
              <span className="badge badge-green">PUBLISHED</span>
            </div>

            <div style={{ padding: '16px', background: '#F8FAFC', borderRadius: '12px', border: '1px solid var(--card-border)', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div>
                <div style={{ fontWeight: '700', fontSize: '15px', color: 'var(--primary-navy)' }}>
                  Mechanics & Vector Forces Lab Experiment
                </div>
                <div style={{ fontSize: '12px', color: 'var(--text-muted)', marginTop: '2px' }}>
                  Physical Sciences • Grade 11A • Due: 02 April 2026 • Max Marks: 100
                </div>
              </div>
              <span className="badge badge-green">PUBLISHED</span>
            </div>
          </div>
        </div>
      )}

      {/* MODULE 2: ATTENDANCE REGISTER */}
      {activeModule === 'ATTENDANCE' && (
        <div className="glass-card animate-fade-in" style={{ padding: '24px', backgroundColor: '#FFFFFF' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
            <div>
              <h3 style={{ fontSize: '18px', color: 'var(--primary-navy)' }}>Daily Attendance Register</h3>
              <p style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Grade 10A (Pure Science & Technology)</p>
            </div>
            <button
              onClick={() => setStatusMsg('Attendance register saved and notifications synced!')}
              className="btn btn-primary"
              style={{ fontSize: '12px' }}
            >
              <Send size={14} /> Submit & Sync Register
            </button>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
            {attendanceList.map((st) => (
              <div key={st.id} style={{ padding: '14px 18px', background: '#F8FAFC', borderRadius: '12px', border: '1px solid var(--card-border)', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                <div>
                  <div style={{ fontWeight: '700', fontSize: '14px', color: 'var(--primary-navy)' }}>{st.name}</div>
                  <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Student No: {st.studentNo}</div>
                </div>

                <div style={{ display: 'flex', gap: '6px' }}>
                  <button
                    onClick={() => toggleAttendance(st.id, 'PRESENT')}
                    className={`btn ${st.status === 'PRESENT' ? 'btn-primary' : 'btn-outline'}`}
                    style={{ padding: '6px 12px', fontSize: '11px' }}
                  >
                    Present
                  </button>
                  <button
                    onClick={() => toggleAttendance(st.id, 'LATE')}
                    className={`btn ${st.status === 'LATE' ? 'btn-navy' : 'btn-outline'}`}
                    style={{ padding: '6px 12px', fontSize: '11px' }}
                  >
                    Late
                  </button>
                  <button
                    onClick={() => toggleAttendance(st.id, 'ABSENT')}
                    className={`btn ${st.status === 'ABSENT' ? 'btn-danger' : 'btn-outline'}`}
                    style={{ padding: '6px 12px', fontSize: '11px' }}
                  >
                    Absent
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* MODULE 3: GRADEBOOK */}
      {activeModule === 'GRADEBOOK' && (
        <div className="glass-card animate-fade-in" style={{ padding: '24px', backgroundColor: '#FFFFFF' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
            <div>
              <h3 style={{ fontSize: '18px', color: 'var(--primary-navy)' }}>CAPS Gradebook & Mark Ledger</h3>
              <p style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Automated aggregate scoring and level calculation</p>
            </div>
            <button
              onClick={() => setStatusMsg('Marks saved and student report cards updated!')}
              className="btn btn-primary"
              style={{ fontSize: '12px' }}
            >
              <Award size={14} /> Recalculate & Save Marks
            </button>
          </div>

          <div style={{ overflowX: 'auto' }}>
            <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '13px' }}>
              <thead>
                <tr style={{ borderBottom: '2px solid var(--card-border)', textAlign: 'left' }}>
                  <th style={{ padding: '10px', color: 'var(--primary-navy)' }}>Learner Name</th>
                  <th style={{ padding: '10px', color: 'var(--primary-navy)' }}>Assessment Task</th>
                  <th style={{ padding: '10px', color: 'var(--primary-navy)' }}>Score / Total</th>
                  <th style={{ padding: '10px', color: 'var(--primary-navy)' }}>CAPS Rating</th>
                </tr>
              </thead>
              <tbody>
                {gradeList.map((g) => (
                  <tr key={g.id} style={{ borderBottom: '1px solid var(--card-border)' }}>
                    <td style={{ padding: '12px 10px', fontWeight: '700', color: 'var(--primary-navy)' }}>{g.name}</td>
                    <td style={{ padding: '12px 10px', color: 'var(--text-muted)' }}>{g.task}</td>
                    <td style={{ padding: '12px 10px', fontWeight: 'bold' }}>{g.mark} / {g.total}</td>
                    <td style={{ padding: '12px 10px' }}>
                      <span className="badge badge-green">{g.symbol}</span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* MODULE 4: TIMETABLE */}
      {activeModule === 'TIMETABLE' && (
        <div className="glass-card animate-fade-in" style={{ padding: '24px', backgroundColor: '#FFFFFF' }}>
          <h3 style={{ fontSize: '18px', color: 'var(--primary-navy)', marginBottom: '16px' }}>Weekly Teaching Timetable</h3>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '12px' }}>
            {['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'].map((day, idx) => (
              <div key={idx} style={{ padding: '14px', background: '#F8FAFC', borderRadius: '12px', border: '1px solid var(--card-border)' }}>
                <div style={{ fontWeight: '800', color: 'var(--primary-navy)', fontSize: '14px', marginBottom: '8px' }}>{day}</div>
                <div style={{ fontSize: '12px', color: 'var(--primary-green)', fontWeight: '600' }}>08:00 - 09:30</div>
                <div style={{ fontSize: '12px', color: 'var(--primary-navy)', fontWeight: 'bold' }}>Mathematics (Grade 10A)</div>
                <div style={{ fontSize: '11px', color: 'var(--text-muted)', marginTop: '8px' }}>10:00 - 11:30</div>
                <div style={{ fontSize: '12px', color: 'var(--primary-navy)', fontWeight: 'bold' }}>Physical Sciences (Grade 11A)</div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* MODAL: New Assignment */}
      <Modal isOpen={isAssignmentModalOpen} onClose={() => setIsAssignmentModalOpen(false)} title="Create Class Assignment" maxWidth="500px">
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
