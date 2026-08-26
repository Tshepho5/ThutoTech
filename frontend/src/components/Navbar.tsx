import React from 'react';
import { User } from '../types';
import { authApi } from '../api/client';
import { GraduationCap, LogOut, Shield, UserCheck, Download } from 'lucide-react';

interface NavbarProps {
  user: User | null;
  onLogout: () => void;
  onOpenDownload: () => void;
  onNavigateTab?: (tab: string) => void;
}

export const Navbar: React.FC<NavbarProps> = ({ user, onLogout, onOpenDownload, onNavigateTab }) => {
  return (
    <header style={{
      background: 'var(--primary-navy)',
      borderBottom: '1px solid rgba(255, 255, 255, 0.1)',
      position: 'sticky',
      top: 0,
      zIndex: 100,
    }}>
      <div style={{
        maxWidth: '1300px',
        margin: '0 auto',
        padding: '12px 20px',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
      }}>
        {/* Brand Logo & Name */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px', cursor: 'pointer' }} onClick={() => onNavigateTab && onNavigateTab('home')}>
          <div style={{
            background: 'var(--primary-green)',
            color: 'white',
            width: '40px',
            height: '40px',
            borderRadius: '10px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            boxShadow: '0 4px 12px rgba(22, 196, 127, 0.4)',
          }}>
            <GraduationCap size={24} />
          </div>
          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
              <span className="navbar-brand-text" style={{ color: 'white', fontSize: '18px', fontWeight: '800', fontFamily: 'var(--font-heading)' }}>
                ThutoTech
              </span>
              <span className="badge badge-green" style={{ fontSize: '10px', padding: '2px 6px' }}>
                ECOSYSTEM
              </span>
            </div>
            <div className="navbar-tagline" style={{ color: 'rgba(255, 255, 255, 0.6)', fontSize: '11px', letterSpacing: '0.04em' }}>
              LEARN • CONNECT • EMPOWER
            </div>
          </div>
        </div>

        {/* User Info & Actions */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <button
            onClick={onOpenDownload}
            className="btn btn-outline"
            style={{ color: 'white', borderColor: 'rgba(255,255,255,0.2)', padding: '6px 12px', fontSize: '13px' }}
          >
            <Download size={15} style={{ color: 'var(--primary-green)' }} />
            <span>Get App</span>
          </button>

          {user ? (
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
              <div style={{ textAlign: 'right' }}>
                <div style={{ color: 'white', fontSize: '13px', fontWeight: '700' }}>
                  {user.name} {user.surname}
                </div>
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'flex-end', gap: '4px' }}>
                  {user.role === 'ADMIN' ? (
                    <span className="badge badge-red" style={{ fontSize: '10px', padding: '1px 6px' }}>
                      <Shield size={10} /> ROOT ADMIN
                    </span>
                  ) : (
                    <span className="badge badge-green" style={{ fontSize: '10px', padding: '1px 6px' }}>
                      <UserCheck size={10} /> {user.role}
                    </span>
                  )}
                </div>
              </div>

              <button
                onClick={() => {
                  authApi.logout();
                  onLogout();
                }}
                className="btn btn-danger"
                style={{ padding: '8px 12px', fontSize: '13px' }}
                title="Sign Out"
              >
                <LogOut size={15} />
                <span>Sign Out</span>
              </button>
            </div>
          ) : (
            <div style={{ display: 'flex', gap: '8px' }}>
              <button onClick={() => onNavigateTab && onNavigateTab('apply')} className="btn btn-primary" style={{ padding: '8px 14px', fontSize: '13px' }}>
                Apply for Admission
              </button>
              <button onClick={() => onNavigateTab && onNavigateTab('register')} className="btn btn-outline" style={{ color: 'white', borderColor: 'rgba(255,255,255,0.2)', padding: '8px 14px', fontSize: '13px' }}>
                Complete Registration
              </button>
            </div>
          )}
        </div>
      </div>
    </header>
  );
};
