import React from 'react';
import { LucideIcon } from 'lucide-react';

interface StatCardProps {
  title: string;
  value: string | number;
  subtitle: string;
  icon: LucideIcon;
  color?: string;
  badge?: string;
}

export const StatCard: React.FC<StatCardProps> = ({
  title,
  value,
  subtitle,
  icon: Icon,
  color = 'var(--primary-green)',
  badge,
}) => {
  return (
    <div className="glass-card" style={{ padding: '20px', position: 'relative', overflow: 'hidden' }}>
      <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', marginBottom: '12px' }}>
        <div>
          <span style={{ fontSize: '12px', fontWeight: '700', color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.04em' }}>
            {title}
          </span>
          <div style={{ fontSize: '28px', fontWeight: '800', color: 'var(--primary-navy)', fontFamily: 'var(--font-heading)', marginTop: '4px' }}>
            {value}
          </div>
        </div>

        <div style={{
          width: '44px',
          height: '44px',
          borderRadius: '12px',
          background: `rgba(22, 196, 127, 0.12)`,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          color: color,
        }}>
          <Icon size={22} />
        </div>
      </div>

      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>
          {subtitle}
        </span>
        {badge && (
          <span className="badge badge-green" style={{ fontSize: '10px' }}>
            {badge}
          </span>
        )}
      </div>
    </div>
  );
};
