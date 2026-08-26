export type UserRole = 'ADMIN' | 'PRINCIPAL' | 'TEACHER' | 'PARENT' | 'LEARNER';

export interface User {
  id: string;
  email: string;
  name: string;
  surname: string;
  role: UserRole;
  phone?: string;
  avatarUrl?: string;
  status: string;
  schoolId?: string;
  createdAt?: string;
}

export interface Learner {
  id: string;
  userId: string;
  learnerNumber?: string;
  idNumber: string;
  fullName: string;
  surname: string;
  grade: string;
  className: string;
  homeLanguage?: string;
  stream?: string;
  attendancePercentage?: number;
  overallAverage?: number;
}

export interface Parent {
  id: string;
  userId: string;
  fullName: string;
  surname: string;
  phone: string;
  email: string;
  hasSecondaryParent?: boolean;
  secondaryParentFullName?: string;
}

export interface Teacher {
  id: string;
  userId: string;
  fullName: string;
  surname: string;
  assignedSubjectIds: string[];
  assignedClassIds: string[];
  schoolId: string;
}

export interface Subject {
  id: string;
  name: string;
  code: string;
  grade: string;
  teacherId?: string;
}

export interface AdmissionLearner {
  learnerName: string;
  learnerSurname: string;
  learnerIdNumber: string;
  learnerGender?: string;
  learnerDob?: string;
  learnerAge?: number;
  learnerCitizenship?: string;
  gradeApplyingFor: string;
  homeLanguage: string;
  firstAdditionalLanguage?: string;
  stream?: string;
  previousSchool: string;
  documentName?: string;
  documentVerified?: boolean;
}

export interface AdmissionApplication {
  id: string;
  applicationNumber: string;
  registrationToken: string;
  primaryParentName: string;
  primaryParentSurname: string;
  primaryParentPhone: string;
  primaryParentEmail: string;
  primaryParentIdNumber: string;
  hasSecondaryParent: boolean;
  secondaryParentName?: string;
  secondaryParentSurname?: string;
  status: 'PENDING' | 'APPROVED' | 'REJECTED';
  documentVerified: boolean;
  learners: AdmissionLearner[];
  createdAt: string;
  reviewerNotes?: string;
}

export interface AuditLog {
  id: string;
  userId: string;
  userName: string;
  role: string;
  action: string;
  entity: string;
  details: string;
  timestamp: string;
}

export interface Announcement {
  id: string;
  title: string;
  content: string;
  authorName: string;
  publishedAt: string;
  priority: 'Normal' | 'High' | 'Urgent';
  audience: string;
}
