-- ==============================================================================
-- THUTOTECH POSTGRESQL DATABASE SCHEMA
-- Compatible with PostgreSQL 14, 15, 16, 17
-- CAPS Curriculum, Admissions, RBAC, Multi-Role Ecosystem & Event Automation
-- ==============================================================================

-- 1. Create Enums
DO $$ BEGIN
    CREATE TYPE "UserRole" AS ENUM ('LEARNER', 'PARENT', 'TEACHER', 'PRINCIPAL', 'ADMIN');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE "UserStatus" AS ENUM ('INVITED', 'ACTIVE', 'SUSPENDED', 'DEACTIVATED');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE "AssignmentStatus" AS ENUM ('DRAFT', 'PUBLISHED', 'CLOSED');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE "SubmissionStatus" AS ENUM ('NOT_SUBMITTED', 'SUBMITTED', 'LATE', 'MARKED');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE "AttendanceStatus" AS ENUM ('PRESENT', 'ABSENT', 'LATE', 'EXCUSED');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE "NotificationCategory" AS ENUM ('ACADEMIC', 'ATTENDANCE', 'ANNOUNCEMENT', 'ACHIEVEMENT', 'SYSTEM');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE "AnnouncementPriority" AS ENUM ('NORMAL', 'HIGH', 'URGENT');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE "ApplicationStatus" AS ENUM ('SUBMITTED', 'UNDER_REVIEW', 'APPROVED', 'REJECTED');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 2. Schools Table
CREATE TABLE IF NOT EXISTS "schools" (
    "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
    "name" VARCHAR(255) NOT NULL,
    "code" VARCHAR(50) UNIQUE NOT NULL,
    "contactEmail" VARCHAR(255) NOT NULL,
    "address" TEXT,
    "activeYear" INT DEFAULT 2026,
    "currentTerm" INT DEFAULT 1,
    "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Users Table
CREATE TABLE IF NOT EXISTS "users" (
    "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
    "email" VARCHAR(255) UNIQUE NOT NULL,
    "passwordHash" TEXT NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "surname" VARCHAR(100) NOT NULL,
    "role" "UserRole" NOT NULL,
    "phone" VARCHAR(20),
    "avatarUrl" TEXT,
    "status" "UserStatus" DEFAULT 'ACTIVE',
    "schoolId" TEXT REFERENCES "schools"("id") ON DELETE SET NULL,
    "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. Parents Table
CREATE TABLE IF NOT EXISTS "parents" (
    "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
    "userId" TEXT UNIQUE NOT NULL REFERENCES "users"("id") ON DELETE CASCADE,
    "fullName" VARCHAR(150) NOT NULL,
    "surname" VARCHAR(150) NOT NULL,
    "phone" VARCHAR(20) NOT NULL,
    "email" VARCHAR(255) NOT NULL,
    "idNumber" VARCHAR(13),
    "hasSecondaryParent" BOOLEAN DEFAULT FALSE,
    "secondaryParentFullName" VARCHAR(150),
    "secondaryParentSurname" VARCHAR(150),
    "secondaryParentPhone" VARCHAR(20),
    "secondaryParentEmail" VARCHAR(255),
    "secondaryParentIdNumber" VARCHAR(13),
    "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. Learners Table
CREATE TABLE IF NOT EXISTS "learners" (
    "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
    "userId" TEXT UNIQUE NOT NULL REFERENCES "users"("id") ON DELETE CASCADE,
    "learnerNumber" VARCHAR(50) UNIQUE, -- e.g. 20260001
    "idNumber" VARCHAR(13) UNIQUE NOT NULL,
    "fullName" VARCHAR(150) NOT NULL,
    "surname" VARCHAR(150) NOT NULL,
    "gender" VARCHAR(20),
    "dateOfBirth" DATE,
    "age" INT,
    "grade" VARCHAR(50) NOT NULL, -- e.g. Grade 10
    "className" VARCHAR(50) NOT NULL, -- e.g. Grade 10A
    "homeLanguage" VARCHAR(50), -- 11 SA Languages
    "firstAdditionalLanguage" VARCHAR(50),
    "stream" VARCHAR(50), -- Science, Commerce, Tourism (Gr 10-12)
    "schoolId" TEXT NOT NULL,
    "attendancePercentage" NUMERIC(5, 2) DEFAULT 100.00,
    "overallAverage" NUMERIC(5, 2) DEFAULT 0.00,
    "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 6. Parent-Learner Relationships Table
CREATE TABLE IF NOT EXISTS "parent_learner_relationships" (
    "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
    "parentId" TEXT NOT NULL REFERENCES "parents"("id") ON DELETE CASCADE,
    "learnerId" TEXT NOT NULL REFERENCES "learners"("id") ON DELETE CASCADE,
    "relationshipType" VARCHAR(50) DEFAULT 'PARENT',
    "status" VARCHAR(20) DEFAULT 'ACTIVE',
    "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE("parentId", "learnerId")
);

-- 7. Teachers Table
CREATE TABLE IF NOT EXISTS "teachers" (
    "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
    "userId" TEXT UNIQUE NOT NULL REFERENCES "users"("id") ON DELETE CASCADE,
    "fullName" VARCHAR(150) NOT NULL,
    "surname" VARCHAR(150) NOT NULL,
    "schoolId" TEXT NOT NULL,
    "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 8. School Classes Table
CREATE TABLE IF NOT EXISTS "school_classes" (
    "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
    "name" VARCHAR(50) NOT NULL,
    "grade" VARCHAR(50) NOT NULL,
    "teacherId" TEXT REFERENCES "teachers"("id") ON DELETE SET NULL,
    "schoolId" TEXT NOT NULL REFERENCES "schools"("id") ON DELETE CASCADE,
    "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 9. Subjects Table
CREATE TABLE IF NOT EXISTS "subjects" (
    "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
    "name" VARCHAR(100) NOT NULL,
    "code" VARCHAR(50) NOT NULL,
    "grade" VARCHAR(50) NOT NULL,
    "stream" VARCHAR(50),
    "schoolId" TEXT NOT NULL REFERENCES "schools"("id") ON DELETE CASCADE,
    "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 10. Class Enrolments
CREATE TABLE IF NOT EXISTS "class_enrolments" (
    "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
    "classId" TEXT NOT NULL REFERENCES "school_classes"("id") ON DELETE CASCADE,
    "learnerId" TEXT NOT NULL REFERENCES "learners"("id") ON DELETE CASCADE,
    "year" INT DEFAULT 2026,
    "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE("classId", "learnerId", "year")
);

-- 11. Teacher Class Assignments
CREATE TABLE IF NOT EXISTS "teacher_class_assignments" (
    "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
    "teacherId" TEXT NOT NULL REFERENCES "teachers"("id") ON DELETE CASCADE,
    "classId" TEXT NOT NULL REFERENCES "school_classes"("id") ON DELETE CASCADE,
    "subjectId" TEXT NOT NULL REFERENCES "subjects"("id") ON DELETE CASCADE,
    "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE("teacherId", "classId", "subjectId")
);

-- 12. Assignments Table
CREATE TABLE IF NOT EXISTS "assignments" (
    "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT NOT NULL,
    "subjectId" TEXT NOT NULL REFERENCES "subjects"("id") ON DELETE CASCADE,
    "classId" TEXT NOT NULL REFERENCES "school_classes"("id") ON DELETE CASCADE,
    "teacherId" TEXT NOT NULL REFERENCES "teachers"("id") ON DELETE CASCADE,
    "dueDate" TIMESTAMP WITH TIME ZONE NOT NULL,
    "maxMarks" NUMERIC(5, 2) DEFAULT 100.00,
    "status" "AssignmentStatus" DEFAULT 'PUBLISHED',
    "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 13. Submissions Table
CREATE TABLE IF NOT EXISTS "submissions" (
    "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
    "assignmentId" TEXT NOT NULL REFERENCES "assignments"("id") ON DELETE CASCADE,
    "learnerId" TEXT NOT NULL REFERENCES "learners"("id") ON DELETE CASCADE,
    "submittedAt" TIMESTAMP WITH TIME ZONE,
    "status" "SubmissionStatus" DEFAULT 'NOT_SUBMITTED',
    "mark" NUMERIC(5, 2),
    "feedback" TEXT,
    "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE("assignmentId", "learnerId")
);

-- 14. Attendance Records Table
CREATE TABLE IF NOT EXISTS "attendance_records" (
    "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
    "date" DATE DEFAULT CURRENT_DATE,
    "classId" TEXT NOT NULL REFERENCES "school_classes"("id") ON DELETE CASCADE,
    "learnerId" TEXT NOT NULL REFERENCES "learners"("id") ON DELETE CASCADE,
    "status" "AttendanceStatus" NOT NULL,
    "reason" TEXT,
    "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 15. Achievements Table
CREATE TABLE IF NOT EXISTS "achievements" (
    "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
    "learnerId" TEXT NOT NULL REFERENCES "learners"("id") ON DELETE CASCADE,
    "title" VARCHAR(150) NOT NULL,
    "description" TEXT NOT NULL,
    "iconName" VARCHAR(50) NOT NULL,
    "category" VARCHAR(50) NOT NULL,
    "awardedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 16. Notifications Table
CREATE TABLE IF NOT EXISTS "notifications" (
    "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
    "recipientUserId" TEXT NOT NULL REFERENCES "users"("id") ON DELETE CASCADE,
    "title" VARCHAR(200) NOT NULL,
    "body" TEXT NOT NULL,
    "isRead" BOOLEAN DEFAULT FALSE,
    "category" "NotificationCategory" NOT NULL,
    "actionLink" TEXT,
    "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 17. Announcements Table
CREATE TABLE IF NOT EXISTS "announcements" (
    "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
    "title" VARCHAR(255) NOT NULL,
    "content" TEXT NOT NULL,
    "authorId" TEXT NOT NULL,
    "authorName" VARCHAR(150) NOT NULL,
    "audience" VARCHAR(50) NOT NULL,
    "priority" "AnnouncementPriority" DEFAULT 'NORMAL',
    "publishedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 18. Audit Logs Table
CREATE TABLE IF NOT EXISTS "audit_logs" (
    "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
    "userId" TEXT NOT NULL REFERENCES "users"("id") ON DELETE CASCADE,
    "userName" VARCHAR(150) NOT NULL,
    "role" VARCHAR(50) NOT NULL,
    "action" VARCHAR(100) NOT NULL,
    "entity" VARCHAR(255) NOT NULL,
    "details" TEXT NOT NULL,
    "ipAddress" VARCHAR(50),
    "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 19. Admission Applications Table
CREATE TABLE IF NOT EXISTS "admission_applications" (
    "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
    "applicationNumber" VARCHAR(50) UNIQUE NOT NULL,
    -- Primary Parent
    "primaryParentName" VARCHAR(100) NOT NULL,
    "primaryParentSurname" VARCHAR(100) NOT NULL,
    "primaryParentPhone" VARCHAR(20) NOT NULL,
    "primaryParentEmail" VARCHAR(255) NOT NULL,
    "primaryParentIdNumber" VARCHAR(13) NOT NULL,
    "primaryParentGender" VARCHAR(20),
    "primaryParentDob" DATE,
    "primaryParentDocumentUrl" TEXT,
    -- Secondary Parent (Optional)
    "hasSecondaryParent" BOOLEAN DEFAULT FALSE,
    "secondaryParentName" VARCHAR(100),
    "secondaryParentSurname" VARCHAR(100),
    "secondaryParentPhone" VARCHAR(20),
    "secondaryParentEmail" VARCHAR(255),
    "secondaryParentIdNumber" VARCHAR(13),
    "secondaryParentGender" VARCHAR(20),
    "secondaryParentDob" DATE,
    "secondaryParentDocumentUrl" TEXT,
    -- Status & Token
    "status" "ApplicationStatus" DEFAULT 'SUBMITTED',
    "registrationToken" VARCHAR(50) UNIQUE NOT NULL,
    "reviewerNotes" TEXT,
    "reviewedAt" TIMESTAMP WITH TIME ZONE,
    "submittedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 19b. Application Learners Table (Multi-Child per Application)
CREATE TABLE IF NOT EXISTS "application_learners" (
    "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
    "applicationId" TEXT NOT NULL REFERENCES "admission_applications"("id") ON DELETE CASCADE,
    "learnerName" VARCHAR(100) NOT NULL,
    "learnerSurname" VARCHAR(100) NOT NULL,
    "learnerIdNumber" VARCHAR(13) NOT NULL,
    "learnerGender" VARCHAR(20),
    "learnerDob" DATE,
    "learnerAge" INT,
    "gradeApplyingFor" VARCHAR(50) NOT NULL,
    "homeLanguage" VARCHAR(50) NOT NULL,
    "firstAdditionalLanguage" VARCHAR(50),
    "stream" VARCHAR(50), -- Science, Commerce, Tourism (if Grade 10-12)
    "previousSchool" VARCHAR(255) NOT NULL,
    "documentUrl" TEXT,
    "documentName" VARCHAR(255),
    "documentVerified" BOOLEAN DEFAULT FALSE,
    "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 20. Automation Rules Table
CREATE TABLE IF NOT EXISTS "automation_rules" (
    "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
    "name" VARCHAR(150) NOT NULL,
    "eventName" VARCHAR(100) NOT NULL,
    "conditionDescription" TEXT NOT NULL,
    "actionDescription" TEXT NOT NULL,
    "isActive" BOOLEAN DEFAULT TRUE,
    "lastRun" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "runCount" INT DEFAULT 0,
    "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for optimal performance
CREATE INDEX IF NOT EXISTS "idx_users_email" ON "users"("email");
CREATE INDEX IF NOT EXISTS "idx_users_role" ON "users"("role");
CREATE INDEX IF NOT EXISTS "idx_learners_idNumber" ON "learners"("idNumber");
CREATE INDEX IF NOT EXISTS "idx_learners_grade" ON "learners"("grade");
CREATE INDEX IF NOT EXISTS "idx_assignments_classId" ON "assignments"("classId");
CREATE INDEX IF NOT EXISTS "idx_attendance_date" ON "attendance_records"("date");
CREATE INDEX IF NOT EXISTS "idx_notifications_recipient" ON "notifications"("recipientUserId");
CREATE INDEX IF NOT EXISTS "idx_audit_logs_user" ON "audit_logs"("userId");
CREATE INDEX IF NOT EXISTS "idx_admissions_appNum" ON "admission_applications"("applicationNumber");
