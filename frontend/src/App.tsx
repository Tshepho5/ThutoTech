import React, { useState, useEffect } from 'react';
import { User } from './types';
import { authApi } from './api/client';
import { Navbar } from './components/Navbar';
import { AppDownloadModal } from './components/AppDownloadModal';
import { LoginView } from './views/auth/LoginView';
import { ForgotPasswordView } from './views/auth/ForgotPasswordView';
import { ApplyView } from './views/admissions/ApplyView';
import { RegisterView } from './views/admissions/RegisterView';
import { AdminDashboard } from './views/admin/AdminDashboard';
import { TeacherDashboard } from './views/teacher/TeacherDashboard';
import { ParentDashboard } from './views/parent/ParentDashboard';
import { LearnerDashboard } from './views/learner/LearnerDashboard';

export const App: React.FC = () => {
  const [currentUser, setCurrentUser] = useState<User | null>(null);
  const [currentView, setCurrentView] = useState<'LOGIN' | 'FORGOT' | 'APPLY' | 'REGISTER'>('LOGIN');
  const [isDownloadModalOpen, setIsDownloadModalOpen] = useState(false);

  useEffect(() => {
    // Check saved session on load
    const user = authApi.getCurrentUser();
    if (user) {
      setCurrentUser(user);
    }
  }, []);

  const handleLoginSuccess = (user: User) => {
    setCurrentUser(user);
  };

  const handleLogout = () => {
    setCurrentUser(null);
    setCurrentView('LOGIN');
  };

  const renderDashboard = () => {
    if (!currentUser) return null;
    switch (currentUser.role) {
      case 'ADMIN':
        return <AdminDashboard currentUser={currentUser} onLogout={handleLogout} />;
      case 'PRINCIPAL':
        return <AdminDashboard currentUser={currentUser} onLogout={handleLogout} />;
      case 'TEACHER':
        return <TeacherDashboard currentUser={currentUser} />;
      case 'PARENT':
        return <ParentDashboard currentUser={currentUser} />;
      case 'LEARNER':
        return <LearnerDashboard currentUser={currentUser} />;
      default:
        return <AdminDashboard currentUser={currentUser} />;
    }
  };

  if (currentUser && (currentUser.role === 'ADMIN' || currentUser.role === 'PRINCIPAL')) {
    return (
      <div style={{ minHeight: '100vh', backgroundColor: 'var(--bg-main)', position: 'relative' }}>
        <div className="app-watermark-overlay" aria-hidden="true" />
        <div style={{ position: 'relative', zIndex: 1 }}>
          <AdminDashboard currentUser={currentUser} onLogout={handleLogout} />
        </div>
        <AppDownloadModal
          isOpen={isDownloadModalOpen}
          onClose={() => setIsDownloadModalOpen(false)}
        />
      </div>
    );
  }

  return (
    <div style={{ minHeight: '100vh', display: 'flex', flexDirection: 'column', backgroundColor: 'var(--bg-main)', position: 'relative' }}>
      <div className="app-watermark-overlay" aria-hidden="true" />
      <div style={{ position: 'relative', zIndex: 1, display: 'flex', flexDirection: 'column', minHeight: '100vh' }}>
        <Navbar
          user={currentUser}
          onLogout={handleLogout}
          onOpenDownload={() => setIsDownloadModalOpen(true)}
          onNavigateTab={(tab) => {
            if (tab === 'apply') setCurrentView('APPLY');
            else if (tab === 'register') setCurrentView('REGISTER');
            else setCurrentView('LOGIN');
          }}
        />

      <main style={{ flex: 1 }}>
        {currentUser ? (
          renderDashboard()
        ) : (
          <>
            {currentView === 'LOGIN' && (
              <LoginView
                onLoginSuccess={handleLoginSuccess}
                onNavigateApply={() => setCurrentView('APPLY')}
                onNavigateRegister={() => setCurrentView('REGISTER')}
                onNavigateForgotPassword={() => setCurrentView('FORGOT')}
                onOpenDownload={() => setIsDownloadModalOpen(true)}
              />
            )}
            {currentView === 'FORGOT' && (
              <ForgotPasswordView onBackToLogin={() => setCurrentView('LOGIN')} />
            )}
            {currentView === 'APPLY' && (
              <ApplyView onBackToLogin={() => setCurrentView('LOGIN')} />
            )}
            {currentView === 'REGISTER' && (
              <RegisterView onBackToLogin={() => setCurrentView('LOGIN')} />
            )}
          </>
        )}
      </main>

      <AppDownloadModal
        isOpen={isDownloadModalOpen}
        onClose={() => setIsDownloadModalOpen(false)}
      />

      <footer style={{
        background: 'var(--primary-navy)',
        color: 'rgba(255,255,255,0.6)',
        padding: '24px 20px',
        textAlign: 'center',
        fontSize: '12px',
        borderTop: '1px solid rgba(255,255,255,0.08)',
      }}>
        <div style={{ maxWidth: '1200px', margin: '0 auto', display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '12px' }}>
          <div>
            <strong style={{ color: 'white' }}>ThutoTech Digital School Ecosystem</strong> • LEARN • CONNECT • EMPOWER
          </div>
          <div>
            CAPS Curriculum Standards • South African National Database
          </div>
        </div>
      </footer>
      </div>
    </div>
  );
};
