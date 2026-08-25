import { Request, Response } from 'express';
import { query } from '../config/database';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { UserRole } from '../types/enums';
import { AuthRequest } from '../middleware/auth.middleware';
import { EmailService } from '../services/email.service';
import { v4 as uuidv4 } from 'uuid';

interface LoginAttemptTracker {
  count: number;
  lockedUntil?: Date;
  lastAttempt: Date;
}

const loginAttemptsMap = new Map<string, LoginAttemptTracker>();

export class AuthController {
  static async login(req: Request, res: Response) {
    try {
      const { email, password } = req.body;
      if (!email || !password) {
        return res.status(400).json({ success: false, message: 'Email/Student number and password are required.' });
      }

      const cleanIdentifier = email.trim().toLowerCase();
      const secret = process.env.JWT_SECRET || 'thutotech_secret';

      // 1. Super Admin (Lebogang Makola) Direct Master Verification
      if (cleanIdentifier === 'thutotech.admin@gmail.com' && password === '#Admin#$5$') {
        const token = jwt.sign(
          {
            id: 'usr_admin_lebogang',
            email: 'thutotech.admin@gmail.com',
            role: UserRole.ADMIN,
            name: 'Lebogang',
            surname: 'Makola',
          },
          secret,
          { expiresIn: '7d' }
        );

        return res.json({
          success: true,
          message: 'Super Administrator authenticated successfully.',
          token,
          user: {
            id: 'usr_admin_lebogang',
            email: 'thutotech.admin@gmail.com',
            name: 'Lebogang',
            surname: 'Makola',
            role: 'ADMIN',
            phone: '0820605107',
            status: 'ACTIVE',
          },
        });
      }

      // 2. Check Brute-Force Lockout
      const attemptInfo = loginAttemptsMap.get(cleanIdentifier);
      if (attemptInfo && attemptInfo.lockedUntil && new Date() < attemptInfo.lockedUntil) {
        const remainingSeconds = Math.ceil((attemptInfo.lockedUntil.getTime() - Date.now()) / 1000);
        return res.status(423).json({
          success: false,
          message: `Account is temporarily locked due to excessive failed attempts. Please try again in ${remainingSeconds} seconds.`,
          locked: true,
          remainingSeconds,
        });
      }

      // 3. Find User by email or student/ID number using SQL
      let user: any = null;
      const userRes = await query(`SELECT * FROM "users" WHERE LOWER(email) = LOWER($1) LIMIT 1`, [cleanIdentifier]);
      if (userRes.rows.length > 0) {
        user = userRes.rows[0];
      } else {
        // Search learner by idNumber or learnerNumber
        const learnerRes = await query(
          `SELECT u.* FROM "learners" l JOIN "users" u ON l."userId" = u.id WHERE l."idNumber" = $1 OR l."learnerNumber" = $1 LIMIT 1`,
          [cleanIdentifier]
        );
        if (learnerRes.rows.length > 0) {
          user = learnerRes.rows[0];
        }
      }

      if (!user) {
        return res.status(401).json({ success: false, message: 'Invalid credentials. User not found.' });
      }

      // 4. Verify Password Hash
      const isMatch = await bcrypt.compare(password, user.passwordHash);
      if (!isMatch) {
        const currentCount = (attemptInfo?.count || 0) + 1;
        if (currentCount >= 5) {
          const lockedUntil = new Date(Date.now() + 5 * 60 * 1000);
          loginAttemptsMap.set(cleanIdentifier, {
            count: currentCount,
            lockedUntil,
            lastAttempt: new Date(),
          });

          return res.status(423).json({
            success: false,
            message: 'Account locked for 5 minutes due to 5 consecutive failed login attempts.',
            locked: true,
            remainingSeconds: 300,
          });
        } else {
          loginAttemptsMap.set(cleanIdentifier, {
            count: currentCount,
            lastAttempt: new Date(),
          });
          return res.status(401).json({
            success: false,
            message: `Invalid password. Attempt ${currentCount} of 5.`,
            attemptsRemaining: 5 - currentCount,
          });
        }
      }

      // Reset failed attempts
      loginAttemptsMap.delete(cleanIdentifier);

      // Generate JWT Token
      const token = jwt.sign(
        { id: user.id, email: user.email, role: user.role, schoolId: user.schoolId },
        secret,
        { expiresIn: '7d' }
      );

      // Record Audit Log in SQL
      try {
        await query(`
          INSERT INTO "audit_logs" ("id", "userId", "userName", "role", "action", "entity", "details")
          VALUES ($1, $2, $3, $4, $5, $6, $7)
        `, [uuidv4(), user.id, `${user.name} ${user.surname}`, user.role, 'LOGIN_SUCCESS', 'Session', `User logged in with role: ${user.role}`]);
      } catch (_) {}

      return res.json({
        success: true,
        message: 'Login successful.',
        token,
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          surname: user.surname,
          role: user.role,
          phone: user.phone,
          status: user.status,
        },
      });
    } catch (error: any) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  static async me(req: AuthRequest, res: Response) {
    try {
      if (!req.user) {
        return res.status(401).json({ success: false, message: 'Unauthorized.' });
      }

      const userRes = await query(`SELECT * FROM "users" WHERE id = $1 LIMIT 1`, [req.user.id]);
      if (userRes.rows.length === 0) {
        return res.status(404).json({ success: false, message: 'User not found.' });
      }

      const user = userRes.rows[0];
      return res.json({ success: true, data: user });
    } catch (error: any) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  static async forgotPassword(req: Request, res: Response) {
    try {
      const { email } = req.body;
      if (!email) {
        return res.status(400).json({ success: false, message: 'Email address is required.' });
      }

      const cleanEmail = email.trim().toLowerCase();
      const userRes = await query(`SELECT * FROM "users" WHERE LOWER(email) = LOWER($1) LIMIT 1`, [cleanEmail]);

      if (userRes.rows.length === 0) {
        return res.status(404).json({ success: false, message: 'No account found with this email address.' });
      }

      const user = userRes.rows[0];
      const otp = Math.floor(100000 + Math.random() * 900000).toString();
      const expiresAt = new Date(Date.now() + 2 * 60 * 1000);

      // Invalidate previous OTPs
      await query(`UPDATE "password_reset_otps" SET "used" = TRUE WHERE LOWER("email") = LOWER($1) AND "used" = FALSE`, [cleanEmail]);

      // Save new OTP
      await query(`
        INSERT INTO "password_reset_otps" ("id", "email", "otp", "expiresAt", "used")
        VALUES ($1, $2, $3, $4, FALSE)
      `, [uuidv4(), cleanEmail, otp, expiresAt]);

      const frontendUrl = process.env.FRONTEND_URL || 'https://thutotech.co.za';
      const resetLink = `${frontendUrl}/#/reset-password?email=${encodeURIComponent(cleanEmail)}&otp=${otp}`;

      await EmailService.sendPasswordResetOtpEmail({
        recipientEmail: cleanEmail,
        recipientName: `${user.name} ${user.surname}`,
        otp,
        resetLink,
      });

      return res.json({
        success: true,
        message: 'A 6-digit OTP has been sent to your email. It will expire in 2 minutes.',
        expiresInSeconds: 120,
      });
    } catch (error: any) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  static async verifyOtp(req: Request, res: Response) {
    try {
      const { email, otp } = req.body;
      if (!email || !otp) {
        return res.status(400).json({ success: false, message: 'Email and OTP are required.' });
      }

      const cleanEmail = email.trim().toLowerCase();
      const cleanOtp = otp.trim();

      const otpRes = await query(`
        SELECT * FROM "password_reset_otps"
        WHERE LOWER("email") = LOWER($1) AND "otp" = $2 AND "used" = FALSE
        ORDER BY "createdAt" DESC LIMIT 1
      `, [cleanEmail, cleanOtp]);

      if (otpRes.rows.length === 0) {
        return res.status(400).json({ success: false, message: 'Invalid or incorrect OTP.' });
      }

      const record = otpRes.rows[0];
      if (new Date() > new Date(record.expiresAt)) {
        return res.status(400).json({
          success: false,
          message: 'This OTP has expired (2-minute limit exceeded). Please request a new one.',
          expired: true,
        });
      }

      return res.json({
        success: true,
        message: 'OTP verified successfully. You may now reset your password.',
      });
    } catch (error: any) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  static async resetPassword(req: Request, res: Response) {
    try {
      const { email, otp, newPassword } = req.body;
      if (!email || !otp || !newPassword) {
        return res.status(400).json({ success: false, message: 'Email, OTP, and new password are required.' });
      }

      const cleanEmail = email.trim().toLowerCase();
      const cleanOtp = otp.trim();

      const otpRes = await query(`
        SELECT * FROM "password_reset_otps"
        WHERE LOWER("email") = LOWER($1) AND "otp" = $2 AND "used" = FALSE
        ORDER BY "createdAt" DESC LIMIT 1
      `, [cleanEmail, cleanOtp]);

      if (otpRes.rows.length === 0 || new Date() > new Date(otpRes.rows[0].expiresAt)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid or expired OTP. Please request a new code.',
        });
      }

      const record = otpRes.rows[0];
      const newHash = await bcrypt.hash(newPassword, 10);

      // Update password
      await query(`UPDATE "users" SET "passwordHash" = $1 WHERE LOWER("email") = LOWER($2)`, [newHash, cleanEmail]);

      // Mark OTP as used
      await query(`UPDATE "password_reset_otps" SET "used" = TRUE WHERE "id" = $1`, [record.id]);

      return res.json({
        success: true,
        message: 'Password reset successfully. You can now log in with your new password.',
      });
    } catch (error: any) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }
}
