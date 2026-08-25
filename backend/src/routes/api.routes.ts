import { Router } from 'express';
import { AdmissionsController } from '../controllers/admissions.controller';
import { AuthController } from '../controllers/auth.controller';
import { AcademicsController } from '../controllers/academics.controller';
import { AdminController } from '../controllers/admin.controller';
import { validateAdmissionApplication, validateRegistration } from '../middleware/validation.middleware';
import { authenticateToken, requireRole, verifyParentChildAccess } from '../middleware/auth.middleware';
import { UserRole } from '@prisma/client';

export const apiRouter = Router();

// --- ADMISSIONS & ONBOARDING ---
apiRouter.post('/admissions/apply', validateAdmissionApplication, AdmissionsController.apply);
apiRouter.get('/admissions', authenticateToken, requireRole([UserRole.ADMIN, UserRole.PRINCIPAL]), AdmissionsController.getApplications);
apiRouter.post('/admissions/:id/approve', authenticateToken, requireRole([UserRole.ADMIN, UserRole.PRINCIPAL]), AdmissionsController.approveApplication);
apiRouter.post('/auth/register', validateRegistration, AdmissionsController.register);

// --- AUTHENTICATION ---
apiRouter.post('/auth/login', AuthController.login);
apiRouter.get('/auth/me', authenticateToken, AuthController.me);

// --- LEARNER PORTAL ---
apiRouter.get('/learner/dashboard', authenticateToken, requireRole([UserRole.LEARNER]), AcademicsController.getLearnerDashboard);
apiRouter.post('/learner/submissions', authenticateToken, requireRole([UserRole.LEARNER]), AcademicsController.submitAssignment);

// --- PARENT PORTAL ---
apiRouter.get('/parent/children', authenticateToken, requireRole([UserRole.PARENT]), AcademicsController.getParentChildren);

// --- TEACHER PORTAL ---
apiRouter.post('/teacher/assignments', authenticateToken, requireRole([UserRole.TEACHER, UserRole.ADMIN]), AcademicsController.createAssignment);
apiRouter.post('/teacher/submissions/grade', authenticateToken, requireRole([UserRole.TEACHER, UserRole.ADMIN]), AcademicsController.gradeSubmission);
apiRouter.post('/teacher/attendance', authenticateToken, requireRole([UserRole.TEACHER, UserRole.ADMIN]), AcademicsController.recordAttendance);

// --- PRINCIPAL & ANNOUNCEMENTS ---
apiRouter.post('/principal/announcements', authenticateToken, requireRole([UserRole.PRINCIPAL, UserRole.ADMIN]), AcademicsController.publishAnnouncement);

// --- ADMIN CONSOLE ---
apiRouter.get('/admin/users', authenticateToken, requireRole([UserRole.ADMIN]), AdminController.getUsers);
apiRouter.get('/admin/audit-logs', authenticateToken, requireRole([UserRole.ADMIN]), AdminController.getAuditLogs);
apiRouter.get('/admin/system-health', authenticateToken, requireRole([UserRole.ADMIN]), AdminController.getSystemHealth);
