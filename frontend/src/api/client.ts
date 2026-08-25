import axios from 'axios';
import { AdmissionApplication, AuditLog, User } from '../types';

const getBaseUrl = () => {
  if (typeof window !== 'undefined') {
    // When served by Express backend on Render or localhost
    return '/api/v1';
  }
  return 'http://localhost:5000/api/v1';
};

export const api = axios.create({
  baseURL: getBaseUrl(),
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 20000,
});

// Attach JWT token automatically
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('thutotech_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export const authApi = {
  login: async (identifier: string, password: string) => {
    const res = await api.post('/auth/login', { email: identifier, password });
    if (res.data.token) {
      localStorage.setItem('thutotech_token', res.data.token);
      localStorage.setItem('thutotech_user', JSON.stringify(res.data.user));
    }
    return res.data;
  },
  me: async () => {
    const res = await api.get('/auth/me');
    return res.data;
  },
  logout: () => {
    localStorage.removeItem('thutotech_token');
    localStorage.removeItem('thutotech_user');
  },
  getCurrentUser: (): User | null => {
    const userStr = localStorage.getItem('thutotech_user');
    if (!userStr) return null;
    try {
      return JSON.parse(userStr);
    } catch {
      return null;
    }
  },
};

export const admissionsApi = {
  apply: async (data: any) => {
    const res = await api.post('/admissions/apply', data);
    return res.data;
  },
  getAll: async (): Promise<AdmissionApplication[]> => {
    const res = await api.get('/admissions');
    return res.data.applications || [];
  },
  approve: async (id: string, notes?: string) => {
    const res = await api.post(`/admissions/${id}/approve`, { notes });
    return res.data;
  },
  register: async (data: {
    registrationToken: string;
    parentName: string;
    parentSurname: string;
    parentEmail: string;
    parentPassword: string;
    learnerName: string;
    learnerSurname: string;
    learnerIdNumber: string;
  }) => {
    const res = await api.post('/auth/register', data);
    return res.data;
  },
};

export const adminApi = {
  getUsers: async (): Promise<User[]> => {
    const res = await api.get('/admin/users');
    return res.data.users || [];
  },
  getAuditLogs: async (): Promise<AuditLog[]> => {
    const res = await api.get('/admin/audit-logs');
    return res.data.auditLogs || [];
  },
  getSystemHealth: async () => {
    const res = await api.get('/admin/system-health');
    return res.data;
  },
  appointTeacher: async (data: {
    name: string;
    surname: string;
    email: string;
    phone: string;
    password?: string;
    subjectIds: string[];
    classIds: string[];
  }) => {
    // Post to backend auth register or dedicated admin teacher creation
    const res = await api.post('/auth/register', {
      registrationToken: 'ADMIN-DIRECT-APPOINT',
      parentName: data.name,
      parentSurname: data.surname,
      parentEmail: data.email,
      parentPassword: data.password || 'Teacher@2026!',
      learnerName: data.name,
      learnerSurname: data.surname,
      learnerIdNumber: '0000000000000',
    });
    return res.data;
  },
  broadcastAnnouncement: async (data: { title: string; content: string; priority: string; targetRole?: string }) => {
    const res = await api.post('/principal/announcements', {
      title: data.title,
      content: data.content,
      audience: data.targetRole || 'ALL',
      priority: data.priority,
    });
    return res.data;
  },
};
