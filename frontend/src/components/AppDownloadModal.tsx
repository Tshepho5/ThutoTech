import React from 'react';
import { Modal } from './Modal';
import { Smartphone, Monitor, Globe, Apple, CheckCircle2, Download } from 'lucide-react';

interface AppDownloadModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export const AppDownloadModal: React.FC<AppDownloadModalProps> = ({ isOpen, onClose }) => {
  return (
    <Modal isOpen={isOpen} onClose={onClose} title="Download ThutoTech Multi-Platform App" maxWidth="600px">
      <div>
        <p style={{ fontSize: '13px', color: 'var(--text-muted)', marginBottom: '20px', lineHeight: 1.5 }}>
          Access the ThutoTech Digital School Ecosystem seamlessly across all your personal and institutional devices. Select your operating system below:
        </p>

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '14px', marginBottom: '24px' }}>
          {/* Android APK */}
          <div className="glass-card" style={{ padding: '16px', display: 'flex', flexDirection: 'column', gap: '10px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
              <div style={{ background: 'rgba(22, 196, 127, 0.12)', color: 'var(--primary-green)', padding: '10px', borderRadius: '10px' }}>
                <Smartphone size={22} />
              </div>
              <div>
                <div style={{ fontWeight: '700', fontSize: '14px', color: 'var(--primary-navy)' }}>Android App</div>
                <div style={{ fontSize: '11px', color: 'var(--text-muted)' }}>APK / Play Store</div>
              </div>
            </div>
            <a
              href="https://github.com/Tshepho5/ThutoTechApp/releases"
              target="_blank"
              rel="noreferrer"
              className="btn btn-primary"
              style={{ fontSize: '12px', padding: '8px 12px', marginTop: 'auto' }}
            >
              <Download size={14} /> Download APK (v1.0)
            </a>
          </div>

          {/* Windows Desktop */}
          <div className="glass-card" style={{ padding: '16px', display: 'flex', flexDirection: 'column', gap: '10px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
              <div style={{ background: 'rgba(59, 130, 246, 0.12)', color: 'var(--info-blue)', padding: '10px', borderRadius: '10px' }}>
                <Monitor size={22} />
              </div>
              <div>
                <div style={{ fontWeight: '700', fontSize: '14px', color: 'var(--primary-navy)' }}>Windows PC</div>
                <div style={{ fontSize: '11px', color: 'var(--text-muted)' }}>MSIX / Setup .exe</div>
              </div>
            </div>
            <a
              href="https://github.com/Tshepho5/ThutoTechApp/releases"
              target="_blank"
              rel="noreferrer"
              className="btn btn-navy"
              style={{ fontSize: '12px', padding: '8px 12px', marginTop: 'auto' }}
            >
              <Download size={14} /> Windows Installer
            </a>
          </div>

          {/* iOS / PWA */}
          <div className="glass-card" style={{ padding: '16px', display: 'flex', flexDirection: 'column', gap: '10px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
              <div style={{ background: 'rgba(139, 92, 246, 0.12)', color: 'var(--purple-accent)', padding: '10px', borderRadius: '10px' }}>
                <Apple size={22} />
              </div>
              <div>
                <div style={{ fontWeight: '700', fontSize: '14px', color: 'var(--primary-navy)' }}>Apple iOS</div>
                <div style={{ fontSize: '11px', color: 'var(--text-muted)' }}>Instant PWA WebApp</div>
              </div>
            </div>
            <button
              onClick={() => {
                alert('On Safari iOS: Tap Share ➔ Add to Home Screen to install ThutoTech App.');
              }}
              className="btn btn-outline"
              style={{ fontSize: '12px', padding: '8px 12px', marginTop: 'auto' }}
            >
              Install on iPhone/iPad
            </button>
          </div>

          {/* Web Browser */}
          <div className="glass-card" style={{ padding: '16px', display: 'flex', flexDirection: 'column', gap: '10px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
              <div style={{ background: 'rgba(255, 157, 60, 0.12)', color: 'var(--warning-orange)', padding: '10px', borderRadius: '10px' }}>
                <Globe size={22} />
              </div>
              <div>
                <div style={{ fontWeight: '700', fontSize: '14px', color: 'var(--primary-navy)' }}>Cloud Web</div>
                <div style={{ fontSize: '11px', color: 'var(--text-muted)' }}>Universal Access</div>
              </div>
            </div>
            <button
              onClick={onClose}
              className="btn btn-outline"
              style={{ fontSize: '12px', padding: '8px 12px', marginTop: 'auto' }}
            >
              <CheckCircle2 size={14} style={{ color: 'var(--primary-green)' }} /> Continue on Web
            </button>
          </div>
        </div>

        <div style={{ background: '#F1F5F9', padding: '12px', borderRadius: '10px', display: 'flex', alignItems: 'center', gap: '8px' }}>
          <CheckCircle2 size={16} color="var(--primary-green)" />
          <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>
            All platforms connect live to the national ThutoTech database with cloud encryption.
          </span>
        </div>
      </div>
    </Modal>
  );
};
