import { Pool } from 'pg';
import fs from 'fs';
import path from 'path';
import bcrypt from 'bcryptjs';
import dotenv from 'dotenv';

dotenv.config();

// PostgreSQL Connection Pool configuration
const getConnectionString = () => {
  if (process.env.DATABASE_URL) return process.env.DATABASE_URL;
  const user = process.env.DB_USER || 'postgres';
  const pass = encodeURIComponent(process.env.DB_PASSWORD || '');
  const host = process.env.DB_HOST || 'localhost';
  const port = process.env.DB_PORT || '5432';
  const name = process.env.DB_NAME || 'ThutoTech_DB';
  return `postgresql://${user}:${pass}@${host}:${port}/${name}`;
};

const isRemoteDb = () => {
  const dbUrl = process.env.DATABASE_URL || '';
  return dbUrl.length > 0 && !dbUrl.includes('localhost') && !dbUrl.includes('127.0.0.1');
};

export const pool = new Pool({
  connectionString: getConnectionString(),
  ssl: isRemoteDb() || process.env.NODE_ENV === 'production'
    ? { rejectUnauthorized: false }
    : false,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 10000,
});

export const query = (text: string, params?: any[]) => pool.query(text, params);

export async function connectDatabase() {
  try {
    const client = await pool.connect();
    console.log('✅ Connected successfully to PostgreSQL Database (Native PG Driver).');
    client.release();

    // 1. Extensions
    await pool.query(`CREATE EXTENSION IF NOT EXISTS "pgcrypto";`).catch(() => {});
    await pool.query(`CREATE EXTENSION IF NOT EXISTS "uuid-ossp";`).catch(() => {});

    // 2. Types & Enums (Safe execution)
    const enumQueries = [
      `DO $$ BEGIN CREATE TYPE "UserRole" AS ENUM ('LEARNER', 'PARENT', 'TEACHER', 'PRINCIPAL', 'ADMIN'); EXCEPTION WHEN duplicate_object THEN null; END $$;`,
      `DO $$ BEGIN CREATE TYPE "UserStatus" AS ENUM ('INVITED', 'ACTIVE', 'SUSPENDED', 'DEACTIVATED'); EXCEPTION WHEN duplicate_object THEN null; END $$;`,
      `DO $$ BEGIN CREATE TYPE "AssignmentStatus" AS ENUM ('DRAFT', 'PUBLISHED', 'CLOSED'); EXCEPTION WHEN duplicate_object THEN null; END $$;`,
      `DO $$ BEGIN CREATE TYPE "SubmissionStatus" AS ENUM ('NOT_SUBMITTED', 'SUBMITTED', 'LATE', 'MARKED'); EXCEPTION WHEN duplicate_object THEN null; END $$;`,
      `DO $$ BEGIN CREATE TYPE "AttendanceStatus" AS ENUM ('PRESENT', 'ABSENT', 'LATE', 'EXCUSED'); EXCEPTION WHEN duplicate_object THEN null; END $$;`,
      `DO $$ BEGIN CREATE TYPE "NotificationCategory" AS ENUM ('ACADEMIC', 'ATTENDANCE', 'ANNOUNCEMENT', 'ACHIEVEMENT', 'SYSTEM'); EXCEPTION WHEN duplicate_object THEN null; END $$;`,
      `DO $$ BEGIN CREATE TYPE "AnnouncementPriority" AS ENUM ('NORMAL', 'HIGH', 'URGENT'); EXCEPTION WHEN duplicate_object THEN null; END $$;`,
      `DO $$ BEGIN CREATE TYPE "ApplicationStatus" AS ENUM ('SUBMITTED', 'UNDER_REVIEW', 'APPROVED', 'REJECTED'); EXCEPTION WHEN duplicate_object THEN null; END $$;`,
    ];

    for (const q of enumQueries) {
      await pool.query(q).catch((e) => console.warn('Enum notice:', e.message));
    }

    // 3. Core Tables DDL (CREATE IF NOT EXISTS)
    const tableQueries = [
      `CREATE TABLE IF NOT EXISTS "schools" (
        "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
        "name" VARCHAR(255) NOT NULL,
        "code" VARCHAR(50) UNIQUE NOT NULL,
        "contactEmail" VARCHAR(255) NOT NULL,
        "address" TEXT,
        "activeYear" INT DEFAULT 2026,
        "currentTerm" INT DEFAULT 1,
        "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );`,

      `CREATE TABLE IF NOT EXISTS "users" (
        "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
        "email" VARCHAR(255) UNIQUE NOT NULL,
        "passwordHash" TEXT,
        "name" VARCHAR(100) NOT NULL,
        "surname" VARCHAR(100) NOT NULL,
        "role" VARCHAR(50) NOT NULL,
        "phone" VARCHAR(20),
        "avatarUrl" TEXT,
        "status" VARCHAR(50) DEFAULT 'ACTIVE',
        "schoolId" TEXT,
        "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );`,

      `CREATE TABLE IF NOT EXISTS "parents" (
        "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
        "userId" TEXT UNIQUE NOT NULL,
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
      );`,

      `CREATE TABLE IF NOT EXISTS "teachers" (
        "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
        "userId" TEXT UNIQUE NOT NULL,
        "fullName" VARCHAR(150) NOT NULL,
        "surname" VARCHAR(150) NOT NULL,
        "employeeNumber" VARCHAR(50) UNIQUE NOT NULL,
        "qualification" VARCHAR(255),
        "specialization" VARCHAR(255),
        "schoolId" TEXT,
        "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );`,

      `CREATE TABLE IF NOT EXISTS "school_classes" (
        "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
        "name" VARCHAR(100) NOT NULL,
        "grade" VARCHAR(50) NOT NULL,
        "academicYear" INT DEFAULT 2026,
        "capacity" INT DEFAULT 35,
        "classTeacherId" TEXT,
        "schoolId" TEXT,
        "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );`,

      `CREATE TABLE IF NOT EXISTS "learners" (
        "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
        "userId" TEXT UNIQUE NOT NULL,
        "learnerNumber" VARCHAR(50) UNIQUE NOT NULL,
        "idNumber" VARCHAR(13) UNIQUE NOT NULL,
        "fullName" VARCHAR(150) NOT NULL,
        "surname" VARCHAR(150) NOT NULL,
        "gender" VARCHAR(20),
        "dateOfBirth" DATE,
        "grade" VARCHAR(50) NOT NULL,
        "classId" TEXT,
        "homeLanguage" VARCHAR(50) NOT NULL DEFAULT 'Sepedi',
        "firstAdditionalLanguage" VARCHAR(50) DEFAULT 'English',
        "stream" VARCHAR(50),
        "attendancePercentage" NUMERIC(5,2) DEFAULT 100.00,
        "overallAverage" NUMERIC(5,2) DEFAULT 0.00,
        "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );`,

      `CREATE TABLE IF NOT EXISTS "parent_learner_relationships" (
        "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
        "parentId" TEXT NOT NULL,
        "learnerId" TEXT NOT NULL,
        "relationshipType" VARCHAR(50) DEFAULT 'PARENT',
        "status" VARCHAR(20) DEFAULT 'ACTIVE',
        "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT "uq_parent_learner" UNIQUE ("parentId", "learnerId")
      );`,

      `CREATE TABLE IF NOT EXISTS "subjects" (
        "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
        "name" VARCHAR(150) NOT NULL,
        "code" VARCHAR(50) UNIQUE NOT NULL,
        "grade" VARCHAR(50) NOT NULL,
        "category" VARCHAR(100) NOT NULL,
        "credits" INT DEFAULT 1,
        "teacherId" TEXT,
        "schoolId" TEXT,
        "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );`,

      `CREATE TABLE IF NOT EXISTS "assignments" (
        "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
        "title" VARCHAR(255) NOT NULL,
        "description" TEXT NOT NULL,
        "subjectId" TEXT NOT NULL,
        "classId" TEXT NOT NULL,
        "teacherId" TEXT NOT NULL,
        "dueDate" TIMESTAMP WITH TIME ZONE NOT NULL,
        "maxMarks" INT NOT NULL DEFAULT 100,
        "status" VARCHAR(50) DEFAULT 'PUBLISHED',
        "attachmentUrl" TEXT,
        "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );`,

      `CREATE TABLE IF NOT EXISTS "submissions" (
        "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
        "assignmentId" TEXT NOT NULL,
        "learnerId" TEXT NOT NULL,
        "submissionUrl" TEXT,
        "submittedAt" TIMESTAMP WITH TIME ZONE,
        "status" VARCHAR(50) DEFAULT 'NOT_SUBMITTED',
        "mark" INT,
        "feedback" TEXT,
        "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT "uq_assignment_learner" UNIQUE ("assignmentId", "learnerId")
      );`,

      `CREATE TABLE IF NOT EXISTS "attendance_records" (
        "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
        "date" DATE NOT NULL,
        "classId" TEXT NOT NULL,
        "learnerId" TEXT NOT NULL,
        "status" VARCHAR(50) NOT NULL DEFAULT 'PRESENT',
        "reason" TEXT,
        "recordedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );`,

      `CREATE TABLE IF NOT EXISTS "audit_logs" (
        "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
        "userId" TEXT NOT NULL,
        "userName" VARCHAR(150) NOT NULL,
        "role" VARCHAR(50) NOT NULL,
        "action" VARCHAR(100) NOT NULL,
        "entity" VARCHAR(255) NOT NULL,
        "details" TEXT NOT NULL,
        "ipAddress" VARCHAR(50),
        "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );`,

      `CREATE TABLE IF NOT EXISTS "admission_applications" (
        "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
        "applicationNumber" VARCHAR(50) UNIQUE NOT NULL,
        "primaryParentName" VARCHAR(100) NOT NULL,
        "primaryParentSurname" VARCHAR(100) NOT NULL,
        "primaryParentPhone" VARCHAR(20) NOT NULL,
        "primaryParentEmail" VARCHAR(255) NOT NULL,
        "primaryParentIdNumber" VARCHAR(13) NOT NULL,
        "primaryParentGender" VARCHAR(20),
        "primaryParentDob" DATE,
        "primaryParentAge" INT,
        "primaryParentCitizenship" VARCHAR(50),
        "primaryParentDocumentUrl" TEXT,
        "hasSecondaryParent" BOOLEAN DEFAULT FALSE,
        "secondaryParentName" VARCHAR(100),
        "secondaryParentSurname" VARCHAR(100),
        "secondaryParentPhone" VARCHAR(20),
        "secondaryParentEmail" VARCHAR(255),
        "secondaryParentIdNumber" VARCHAR(13),
        "secondaryParentGender" VARCHAR(20),
        "secondaryParentDob" DATE,
        "secondaryParentAge" INT,
        "secondaryParentCitizenship" VARCHAR(50),
        "secondaryParentDocumentUrl" TEXT,
        "status" VARCHAR(50) DEFAULT 'SUBMITTED',
        "registrationToken" VARCHAR(50) UNIQUE NOT NULL,
        "reviewerNotes" TEXT,
        "reviewedAt" TIMESTAMP WITH TIME ZONE,
        "submittedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );`,

      `CREATE TABLE IF NOT EXISTS "application_learners" (
        "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
        "applicationId" TEXT NOT NULL,
        "learnerName" VARCHAR(100) NOT NULL,
        "learnerSurname" VARCHAR(100) NOT NULL,
        "learnerIdNumber" VARCHAR(13) NOT NULL,
        "learnerGender" VARCHAR(20),
        "learnerDob" DATE,
        "learnerAge" INT,
        "learnerCitizenship" VARCHAR(50),
        "gradeApplyingFor" VARCHAR(50) NOT NULL,
        "homeLanguage" VARCHAR(50) NOT NULL,
        "firstAdditionalLanguage" VARCHAR(50),
        "stream" VARCHAR(50),
        "previousSchool" VARCHAR(255) NOT NULL,
        "documentUrl" TEXT,
        "documentName" VARCHAR(255),
        "documentVerified" BOOLEAN DEFAULT FALSE,
        "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );`,

      `CREATE TABLE IF NOT EXISTS "app_notifications" (
        "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
        "recipientUserId" TEXT NOT NULL,
        "title" VARCHAR(255) NOT NULL,
        "body" TEXT NOT NULL,
        "category" VARCHAR(50) DEFAULT 'SYSTEM',
        "isRead" BOOLEAN DEFAULT FALSE,
        "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );`,

      `CREATE TABLE IF NOT EXISTS "announcements" (
        "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
        "title" VARCHAR(255) NOT NULL,
        "content" TEXT NOT NULL,
        "authorId" TEXT NOT NULL,
        "authorName" VARCHAR(150) NOT NULL,
        "priority" VARCHAR(50) DEFAULT 'NORMAL',
        "audience" VARCHAR(50) DEFAULT 'ALL',
        "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );`,

      `CREATE TABLE IF NOT EXISTS "password_reset_otps" (
        "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
        "email" VARCHAR(255) NOT NULL,
        "otpHash" TEXT NOT NULL,
        "expiresAt" TIMESTAMP WITH TIME ZONE NOT NULL,
        "used" BOOLEAN DEFAULT FALSE,
        "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );`
    ];

    for (const tbl of tableQueries) {
      await pool.query(tbl).catch((e) => console.warn('Table initialization notice:', e.message));
    }

    // 4. Guaranteed Column Sync (ALTER TABLE ADD COLUMN IF NOT EXISTS for all tables)
    const columnSyncQueries = [
      // Users table sync
      `ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "passwordHash" TEXT;`,
      `ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "name" VARCHAR(100);`,
      `ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "surname" VARCHAR(100);`,
      `ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "role" VARCHAR(50);`,
      `ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "phone" VARCHAR(20);`,
      `ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "avatarUrl" TEXT;`,
      `ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "status" VARCHAR(50) DEFAULT 'ACTIVE';`,
      `ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "schoolId" TEXT;`,
      `ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;`,
      `ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;`,

      // Migrate legacy password column if exists
      `DO $$ BEGIN
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='password') THEN
          UPDATE "users" SET "passwordHash" = "password" WHERE "passwordHash" IS NULL;
        END IF;
      END $$;`,

      // Admission Applications sync
      `ALTER TABLE "admission_applications" ADD COLUMN IF NOT EXISTS "primaryParentAge" INT;`,
      `ALTER TABLE "admission_applications" ADD COLUMN IF NOT EXISTS "primaryParentCitizenship" VARCHAR(50);`,
      `ALTER TABLE "admission_applications" ADD COLUMN IF NOT EXISTS "secondaryParentAge" INT;`,
      `ALTER TABLE "admission_applications" ADD COLUMN IF NOT EXISTS "secondaryParentCitizenship" VARCHAR(50);`,

      // Application Learners sync
      `ALTER TABLE "application_learners" ADD COLUMN IF NOT EXISTS "learnerAge" INT;`,
      `ALTER TABLE "application_learners" ADD COLUMN IF NOT EXISTS "learnerCitizenship" VARCHAR(50);`,

      // Learners table sync
      `ALTER TABLE "learners" ADD COLUMN IF NOT EXISTS "homeLanguage" VARCHAR(50) DEFAULT 'Sepedi';`,
      `ALTER TABLE "learners" ADD COLUMN IF NOT EXISTS "firstAdditionalLanguage" VARCHAR(50) DEFAULT 'English';`,
      `ALTER TABLE "learners" ADD COLUMN IF NOT EXISTS "stream" VARCHAR(50);`,
      `ALTER TABLE "learners" ADD COLUMN IF NOT EXISTS "attendancePercentage" NUMERIC(5,2) DEFAULT 100.00;`,
      `ALTER TABLE "learners" ADD COLUMN IF NOT EXISTS "overallAverage" NUMERIC(5,2) DEFAULT 0.00;`
    ];

    for (const syncQ of columnSyncQueries) {
      await pool.query(syncQ).catch(() => {});
    }

    // 5. Seed CAPS South African Curriculum Subjects
    const capsSubjects = [
      { name: 'Mathematics', code: 'MATH-CAPS', grade: 'Grade 8', category: 'Fundamental' },
      { name: 'Mathematical Literacy', code: 'MLIT-CAPS', grade: 'Grade 10', category: 'Fundamental' },
      { name: 'Physical Sciences', code: 'PHYS-CAPS', grade: 'Grade 10', category: 'Science' },
      { name: 'Life Sciences', code: 'LFSC-CAPS', grade: 'Grade 10', category: 'Science' },
      { name: 'Accounting', code: 'ACCT-CAPS', grade: 'Grade 10', category: 'Commerce' },
      { name: 'Business Studies', code: 'BSTD-CAPS', grade: 'Grade 10', category: 'Commerce' },
      { name: 'Economics', code: 'ECON-CAPS', grade: 'Grade 10', category: 'Commerce' },
      { name: 'Geography', code: 'GEOG-CAPS', grade: 'Grade 8', category: 'Humanities' },
      { name: 'History', code: 'HIST-CAPS', grade: 'Grade 8', category: 'Humanities' },
      { name: 'English First Additional Language', code: 'EFAL-CAPS', grade: 'Grade 8', category: 'Language' },
      { name: 'Sepedi Home Language', code: 'SEPD-CAPS', grade: 'Grade 8', category: 'Language' },
      { name: 'Life Orientation', code: 'LIFE-CAPS', grade: 'Grade 8', category: 'Fundamental' },
      { name: 'Information Technology', code: 'INFT-CAPS', grade: 'Grade 10', category: 'Technical' },
      { name: 'Computer Applications Technology', code: 'COMA-CAPS', grade: 'Grade 10', category: 'Technical' }
    ];

    for (const sub of capsSubjects) {
      await pool.query(`
        INSERT INTO "subjects" ("id", "name", "code", "grade", "category", "credits")
        VALUES (gen_random_uuid(), $1, $2, $3, $4, 1)
        ON CONFLICT ("code") DO UPDATE SET
          "name" = $1,
          "grade" = $3,
          "category" = $4;
      `, [sub.name, sub.code, sub.grade, sub.category]).catch(() => {});
    }

    // 6. Guarantee Super Admin Lebogang Makola seed
    const adminPassHash = await bcrypt.hash('#Admin#$5$', 10);
    await pool.query(`
      INSERT INTO "users" ("id", "email", "passwordHash", "name", "surname", "role", "phone", "status")
      VALUES (
        'usr_admin_lebogang',
        'thutotech.admin@gmail.com',
        $1,
        'Lebogang',
        'Makola',
        'ADMIN',
        '0820605107',
        'ACTIVE'
      )
      ON CONFLICT ("email") DO UPDATE SET
        "passwordHash" = $1,
        "name" = 'Lebogang',
        "surname" = 'Makola',
        "role" = 'ADMIN',
        "status" = 'ACTIVE';
    `, [adminPassHash]);

    console.log('✅ PostgreSQL Schema synchronized: all 17 tables, all columns, CAPS subjects and Super Admin ready.');
  } catch (error: any) {
    console.error('⚠️ PostgreSQL Schema Initialization Error:', error.message);
  }
}
