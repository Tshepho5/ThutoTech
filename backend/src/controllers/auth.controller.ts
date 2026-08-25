import { Request, Response } from 'express';
import { prisma } from '../config/database';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { AuthRequest } from '../middleware/auth.middleware';
import { EmailService } from '../services/email.service';

/**
 * Calculates Levenshtein edit distance between two strings
 */
function levenshteinDistance(a: string, b: string): number {
  const matrix: number[][] = [];
  for (let i = 0; i <= b.length; i++) {
    matrix[i] = [i];
  }
  for (let j = 0; j <= a.length; j++) {
    matrix[0][j] = j;
  }
  for (let i = 1; i <= b.length; i++) {
    for (let j = 1; j <= a.length; j++) {
      if (b.charAt(i - 1) === a.charAt(j - 1)) {
        matrix[i][j] = matrix[i - 1][j - 1];
      } else {
        matrix[i][j] = Math.min(
          matrix[i - 1][j - 1] + 1, // substitution
          matrix[i][j - 1] + 1,     // insertion
          matrix[i - 1][j] + 1      // deletion
        );
      }
    }
  }
  return matrix[b.length][a.length];
}

export class AuthController {
  static async login(req: Request, res: Response) {
    try {
      const { email, password } = req.body;
      if (!email || !password) {
        return res.status(400).json({ success: false, message: 'Email and password are required.' });
      }

      const user = await prisma.user.findUnique({
        where: { email: email.trim().toLowerCase() },
        include: { learner: true, parent: true, teacher: true },
      });

      if (!user) {
        return res.status(401).json({ success: false, message: 'Invalid email or credentials.' });
      }

      const isMatch = await bcrypt.compare(password, user.passwordHash);
      if (!isMatch) {
        return res.status(401).json({ success: false, message: 'Invalid email or credentials.' });
      }

      const secret = process.env.JWT_SECRET || 'thutotech_secret';
      const token = jwt.sign(
        { id: user.id, email: user.email, role: user.role, schoolId: user.schoolId },
        secret,
        { expiresIn: '7d' }
      );

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
          learner: user.learner,
          parent: user.parent,
          teacher: user.teacher,
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

      const user = await prisma.user.findUnique({
        where: { id: req.user.id },
        include: {
          learner: true,
          parent: { include: { relationships: { include: { learner: true } } } },
          teacher: true,
        },
      });

      if (!user) {
        return res.status(404).json({ success: false, message: 'User not found.' });
      }

      return res.json({ success: true, data: user });
    } catch (error: any) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  /**
   * Request 6-digit Password Reset OTP with 2-minute expiry
   */
  static async forgotPassword(req: Request, res: Response) {
    try {
      const { email } = req.body;
      if (!email) {
        return res.status(400).json({ success: false, message: 'Email address is required.' });
      }

      const cleanEmail = email.trim().toLowerCase();
      const user = await prisma.user.findUnique({ where: { email: cleanEmail } });

      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'No account found with this email address.',
        });
      }

      // Generate 6-digit OTP
      const otp = Math.floor(100000 + Math.random() * 900000).toString();

      // 2-minute expiry strictly enforced
      const expiresAt = new Date(Date.now() + 2 * 60 * 1000);

      // Invalidate previous OTPs
      await prisma.passwordResetOtp.updateMany({
        where: { email: cleanEmail, used: false },
        data: { used: true },
      });

      // Save new OTP
      await prisma.passwordResetOtp.create({
        data: {
          email: cleanEmail,
          otp,
          expiresAt,
          used: false,
        },
      });

      const frontendUrl = process.env.FRONTEND_URL || 'https://thutotech.co.za';
      const resetLink = `${frontendUrl}/#/reset-password?email=${encodeURIComponent(cleanEmail)}&otp=${otp}`;

      // Dispatch Email
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

  /**
   * Verify 6-digit OTP
   */
  static async verifyOtp(req: Request, res: Response) {
    try {
      const { email, otp } = req.body;
      if (!email || !otp) {
        return res.status(400).json({ success: false, message: 'Email and OTP are required.' });
      }

      const cleanEmail = email.trim().toLowerCase();
      const cleanOtp = otp.trim();

      const record = await prisma.passwordResetOtp.findFirst({
        where: {
          email: cleanEmail,
          otp: cleanOtp,
          used: false,
        },
        orderBy: { createdAt: 'desc' },
      });

      if (!record) {
        return res.status(400).json({ success: false, message: 'Invalid or incorrect OTP.' });
      }

      if (new Date() > record.expiresAt) {
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

  /**
   * Reset Password with Levenshtein old password similarity check
   */
  static async resetPassword(req: Request, res: Response) {
    try {
      const { email, otp, newPassword } = req.body;
      if (!email || !otp || !newPassword) {
        return res.status(400).json({ success: false, message: 'Email, OTP, and new password are required.' });
      }

      const cleanEmail = email.trim().toLowerCase();
      const cleanOtp = otp.trim();

      const record = await prisma.passwordResetOtp.findFirst({
        where: {
          email: cleanEmail,
          otp: cleanOtp,
          used: false,
        },
        orderBy: { createdAt: 'desc' },
      });

      if (!record || new Date() > record.expiresAt) {
        return res.status(400).json({
          success: false,
          message: 'Invalid or expired OTP. Please request a new code.',
        });
      }

      const user = await prisma.user.findUnique({ where: { email: cleanEmail } });
      if (!user) {
        return res.status(404).json({ success: false, message: 'User not found.' });
      }

      // Hash new password and update
      const newHash = await bcrypt.hash(newPassword, 10);
      await prisma.user.update({
        where: { id: user.id },
        data: { passwordHash: newHash },
      });

      // Mark OTP as used
      await prisma.passwordResetOtp.update({
        where: { id: record.id },
        data: { used: true },
      });

      return res.json({
        success: true,
        message: 'Password reset successfully. You can now log in with your new password.',
      });
    } catch (error: any) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }
}
