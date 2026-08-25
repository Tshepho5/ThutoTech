import { Router } from 'express';
import { AdmissionsController } from '../controllers/admissions.controller';
import { AuthController } from '../controllers/auth.controller';
import { AcademicsController } from '../controllers/academics.controller';
import { AdminController } from '../controllers/admin.controller';
import { EmailController } from '../controllers/email.controller';
import { validateAdmissionApplication, validateRegistration } from '../middleware/validation.middleware';
import { authenticateToken, requireRole } from '../middleware/auth.middleware';
import { UserRole } from '../types/enums';

export const apiRouter = Router();

// Root API Explorer
apiRouter.get('/', (req, res) => {
  res.json({
    name: 'ThutoTech Ecosystem API',
    version: '1.0.0',
    status: 'ACTIVE',
    motto: 'LEARN • CONNECT • EMPOWER',
    documentation: {
      health: 'GET /health',
      admissions: {
        apply: 'POST /api/v1/admissions/apply',
        list: 'GET /api/v1/admissions',
        approve: 'POST /api/v1/admissions/:id/approve',
        register: 'POST /api/v1/auth/register',
      },
      auth: {
        login: 'POST /api/v1/auth/login',
        me: 'GET /api/v1/auth/me',
      },
      learner: {
        dashboard: 'GET /api/v1/learner/dashboard',
        submit: 'POST /api/v1/learner/submissions',
      },
      parent: {
        children: 'GET /api/v1/parent/children',
      },
      teacher: {
        createAssignment: 'POST /api/v1/teacher/assignments',
        grade: 'POST /api/v1/teacher/submissions/grade',
        attendance: 'POST /api/v1/teacher/attendance',
      },
      principal: {
        announcements: 'POST /api/v1/principal/announcements',
      },
      admin: {
        users: 'GET /api/v1/admin/users',
        auditLogs: 'GET /api/v1/admin/audit-logs',
        systemHealth: 'GET /api/v1/admin/system-health',
      },
    },
  });
});

// --- APP DOWNLOADS ---
apiRouter.get('/download/apk', (req, res) => {
  res.redirect('https://github.com/Tshepho5/ThutoTechApp/releases/tag/v1.0.0');
});
apiRouter.get('/download/windows', (req, res) => {
  res.redirect('https://github.com/Tshepho5/ThutoTechApp/releases/tag/v1.0.0');
});

// --- ADMISSIONS & ONBOARDING ---
apiRouter.post('/admissions/apply', validateAdmissionApplication, AdmissionsController.apply);
apiRouter.get('/admissions', authenticateToken, requireRole([UserRole.ADMIN, UserRole.PRINCIPAL]), AdmissionsController.getApplications);
apiRouter.post('/admissions/:id/approve', authenticateToken, requireRole([UserRole.ADMIN, UserRole.PRINCIPAL]), AdmissionsController.approveApplication);
apiRouter.post('/auth/register', validateRegistration, AdmissionsController.register);

// --- SMTP EMAIL DISPATCHING ---
apiRouter.post('/emails/send-admission-approval', EmailController.sendAdmissionApproval);
apiRouter.post('/emails/send-registration-success', EmailController.sendRegistrationSuccess);
apiRouter.post('/emails/send-otp', EmailController.sendPasswordResetOtp);
apiRouter.post('/emails/send-custom', EmailController.sendCustom);

// --- AUTHENTICATION & PASSWORD RECOVERY ---
apiRouter.post('/auth/login', AuthController.login);
apiRouter.get('/auth/me', authenticateToken, AuthController.me);
apiRouter.post('/auth/forgot-password', AuthController.forgotPassword);
apiRouter.post('/auth/verify-otp', AuthController.verifyOtp);
apiRouter.post('/auth/reset-password', AuthController.resetPassword);

// --- LEARNER PORTAL ---
apiRouter.get('/learner/dashboard', authenticateToken, requireRole([UserRole.LEARNER]), AcademicsController.getLearnerDashboard);
apiRouter.post('/learner/submissions', authenticateToken, requireRole([UserRole.LEARNER]), AcademicsController.submitAssignment);

// --- PARENT PORTAL ---
apiRouter.get('/parent/children', authenticateToken, requireRole([UserRole.PARENT]), AcademicsController.getParentChildren);

// --- ACADEMICS & CURRICULUM ---
apiRouter.get('/academics/subjects', AcademicsController.getSubjects);
apiRouter.get('/academics/assessments', AcademicsController.getAssessmentsWithMarks);

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
