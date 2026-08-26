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
    await pool.query(`CREATE EXTENSION IF NOT EXISTS "pgcrypto";`);
    await pool.query(`CREATE EXTENSION IF NOT EXISTS "uuid-ossp";`);

    // 2. Types & Enums
    await pool.query(`
      DO $$ BEGIN
        CREATE TYPE "UserRole" AS ENUM ('LEARNER', 'PARENT', 'TEACHER', 'PRINCIPAL', 'ADMIN');
      EXCEPTION WHEN duplicate_object THEN null; END $$;

      DO $$ BEGIN
        CREATE TYPE "UserStatus" AS ENUM ('INVITED', 'ACTIVE', 'SUSPENDED', 'DEACTIVATED');
      EXCEPTION WHEN duplicate_object THEN null; END $$;

      DO $$ BEGIN
        CREATE TYPE "AssignmentStatus" AS ENUM ('DRAFT', 'PUBLISHED', 'CLOSED');
      EXCEPTION WHEN duplicate_object THEN null; END $$;

      DO $$ BEGIN
        CREATE TYPE "SubmissionStatus" AS ENUM ('NOT_SUBMITTED', 'SUBMITTED', 'LATE', 'MARKED');
      EXCEPTION WHEN duplicate_object THEN null; END $$;

      DO $$ BEGIN
        CREATE TYPE "AttendanceStatus" AS ENUM ('PRESENT', 'ABSENT', 'LATE', 'EXCUSED');
      EXCEPTION WHEN duplicate_object THEN null; END $$;

      DO $$ BEGIN
        CREATE TYPE "NotificationCategory" AS ENUM ('ACADEMIC', 'ATTENDANCE', 'ANNOUNCEMENT', 'ACHIEVEMENT', 'SYSTEM');
      EXCEPTION WHEN duplicate_object THEN null; END $$;

      DO $$ BEGIN
        CREATE TYPE "AnnouncementPriority" AS ENUM ('NORMAL', 'HIGH', 'URGENT');
      EXCEPTION WHEN duplicate_object THEN null; END $$;

      DO $$ BEGIN
        CREATE TYPE "ApplicationStatus" AS ENUM ('SUBMITTED', 'UNDER_REVIEW', 'APPROVED', 'REJECTED');
      EXCEPTION WHEN duplicate_object THEN null; END $$;
    `);

    // 3. Core Database Tables DDL
    await pool.query(`
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

      CREATE TABLE IF NOT EXISTS "teachers" (
        "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
        "userId" TEXT UNIQUE NOT NULL REFERENCES "users"("id") ON DELETE CASCADE,
        "fullName" VARCHAR(150) NOT NULL,
        "surname" VARCHAR(150) NOT NULL,
        "employeeNumber" VARCHAR(50) UNIQUE NOT NULL,
        "qualification" VARCHAR(255),
        "specialization" VARCHAR(255),
        "schoolId" TEXT REFERENCES "schools"("id") ON DELETE CASCADE,
        "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );

      CREATE TABLE IF NOT EXISTS "school_classes" (
        "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
        "name" VARCHAR(100) NOT NULL,
        "grade" VARCHAR(50) NOT NULL,
        "academicYear" INT DEFAULT 2026,
        "capacity" INT DEFAULT 35,
        "classTeacherId" TEXT REFERENCES "teachers"("id") ON DELETE SET NULL,
        "schoolId" TEXT REFERENCES "schools"("id") ON DELETE CASCADE,
        "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );

      CREATE TABLE IF NOT EXISTS "learners" (
        "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
        "userId" TEXT UNIQUE NOT NULL REFERENCES "users"("id") ON DELETE CASCADE,
        "learnerNumber" VARCHAR(50) UNIQUE NOT NULL,
        "idNumber" VARCHAR(13) UNIQUE NOT NULL,
        "fullName" VARCHAR(150) NOT NULL,
        "surname" VARCHAR(150) NOT NULL,
        "gender" VARCHAR(20),
        "dateOfBirth" DATE,
        "grade" VARCHAR(50) NOT NULL,
        "classId" TEXT REFERENCES "school_classes"("id") ON DELETE SET NULL,
        "homeLanguage" VARCHAR(50) NOT NULL DEFAULT 'Sepedi',
        "firstAdditionalLanguage" VARCHAR(50) DEFAULT 'English',
        "stream" VARCHAR(50),
        "attendancePercentage" NUMERIC(5,2) DEFAULT 100.00,
        "overallAverage" NUMERIC(5,2) DEFAULT 0.00,
        "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );

      CREATE TABLE IF NOT EXISTS "parent_learner_relationships" (
        "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
        "parentId" TEXT NOT NULL REFERENCES "parents"("id") ON DELETE CASCADE,
        "learnerId" TEXT NOT NULL REFERENCES "learners"("id") ON DELETE CASCADE,
        "relationshipType" VARCHAR(50) DEFAULT 'PARENT',
        "status" VARCHAR(20) DEFAULT 'ACTIVE',
        "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT "uq_parent_learner" UNIQUE ("parentId", "learnerId")
      );

      CREATE TABLE IF NOT EXISTS "subjects" (
        "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
        "name" VARCHAR(150) NOT NULL,
        "code" VARCHAR(50) UNIQUE NOT NULL,
        "grade" VARCHAR(50) NOT NULL,
        "category" VARCHAR(100) NOT NULL,
        "credits" INT DEFAULT 1,
        "teacherId" TEXT REFERENCES "teachers"("id") ON DELETE SET NULL,
        "schoolId" TEXT REFERENCES "schools"("id") ON DELETE CASCADE,
        "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );

      CREATE TABLE IF NOT EXISTS "assignments" (
        "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
        "title" VARCHAR(255) NOT NULL,
        "description" TEXT NOT NULL,
        "subjectId" TEXT NOT NULL REFERENCES "subjects"("id") ON DELETE CASCADE,
        "classId" TEXT NOT NULL REFERENCES "school_classes"("id") ON DELETE CASCADE,
        "teacherId" TEXT NOT NULL REFERENCES "teachers"("id") ON DELETE CASCADE,
        "dueDate" TIMESTAMP WITH TIME ZONE NOT NULL,
        "maxMarks" INT NOT NULL DEFAULT 100,
        "status" "AssignmentStatus" DEFAULT 'PUBLISHED',
        "attachmentUrl" TEXT,
        "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );

      CREATE TABLE IF NOT EXISTS "submissions" (
        "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
        "assignmentId" TEXT NOT NULL REFERENCES "assignments"("id") ON DELETE CASCADE,
        "learnerId" TEXT NOT NULL REFERENCES "learners"("id") ON DELETE CASCADE,
        "submissionUrl" TEXT,
        "submittedAt" TIMESTAMP WITH TIME ZONE,
        "status" "SubmissionStatus" DEFAULT 'NOT_SUBMITTED',
        "mark" INT,
        "feedback" TEXT,
        "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT "uq_assignment_learner" UNIQUE ("assignmentId", "learnerId")
      );

      CREATE TABLE IF NOT EXISTS "attendance_records" (
        "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
        "date" DATE NOT NULL,
        "classId" TEXT NOT NULL REFERENCES "school_classes"("id") ON DELETE CASCADE,
        "learnerId" TEXT NOT NULL REFERENCES "learners"("id") ON DELETE CASCADE,
        "status" "AttendanceStatus" NOT NULL DEFAULT 'PRESENT',
        "reason" TEXT,
        "recordedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );

      CREATE TABLE IF NOT EXISTS "audit_logs" (
        "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
        "userId" TEXT NOT NULL,
        "userName" VARCHAR(150) NOT NULL,
        "role" VARCHAR(50) NOT NULL,
        "action" VARCHAR(100) NOT NULL,
        "entity" VARCHAR(255) NOT NULL,
        "details" TEXT NOT NULL,
        "ipAddress" VARCHAR(50),
        "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );

      CREATE TABLE IF NOT EXISTS "admission_applications" (
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
        "status" "ApplicationStatus" DEFAULT 'SUBMITTED',
        "registrationToken" VARCHAR(50) UNIQUE NOT NULL,
        "reviewerNotes" TEXT,
        "reviewedAt" TIMESTAMP WITH TIME ZONE,
        "submittedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );

      CREATE TABLE IF NOT EXISTS "application_learners" (
        "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
        "applicationId" TEXT NOT NULL REFERENCES "admission_applications"("id") ON DELETE CASCADE,
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
      );

      CREATE TABLE IF NOT EXISTS "app_notifications" (
        "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
        "recipientUserId" TEXT NOT NULL,
        "title" VARCHAR(255) NOT NULL,
        "body" TEXT NOT NULL,
        "category" "NotificationCategory" DEFAULT 'SYSTEM',
        "isRead" BOOLEAN DEFAULT FALSE,
        "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );

      CREATE TABLE IF NOT EXISTS "announcements" (
        "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
        "title" VARCHAR(255) NOT NULL,
        "content" TEXT NOT NULL,
        "authorId" TEXT NOT NULL,
        "authorName" VARCHAR(150) NOT NULL,
        "priority" "AnnouncementPriority" DEFAULT 'NORMAL',
        "audience" VARCHAR(50) DEFAULT 'ALL',
        "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );

      CREATE TABLE IF NOT EXISTS "password_reset_otps" (
        "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
        "email" VARCHAR(255) NOT NULL,
        "otpHash" TEXT NOT NULL,
        "expiresAt" TIMESTAMP WITH TIME ZONE NOT NULL,
        "used" BOOLEAN DEFAULT FALSE,
        "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // 4. Also execute schema.sql if present on filesystem
    const candidates = [
      path.resolve(__dirname, '../../schema.sql'),
      path.resolve(__dirname, '../schema.sql'),
      path.resolve(process.cwd(), 'schema.sql'),
      path.resolve(process.cwd(), 'backend/schema.sql'),
    ];

    for (const p of candidates) {
      if (fs.existsSync(p)) {
        console.log(`📄 Executing schema file from: ${p}`);
        const sqlContent = fs.readFileSync(p, 'utf-8');
        await pool.query(sqlContent);
        break;
      }
    }

    // 5. Guarantee Super Admin Lebogang Makola seed
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

    console.log('✅ PostgreSQL Schema synchronized and Super Admin ready.');
  } catch (error: any) {
    console.error('⚠️ PostgreSQL Schema Initialization Error:', error.message);
  }
}
