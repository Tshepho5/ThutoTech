import { Request, Response } from 'express';
import { EmailService } from '../services/email.service';

export class EmailController {
  /**
   * Dispatch Admission Approval Email
   */
  static async sendAdmissionApproval(req: Request, res: Response) {
    try {
      const {
        recipientEmail,
        parentName,
        parentSurname,
        learnerName,
        learnerSurname,
        grade,
        homeLanguage,
        stream,
        applicationNumber,
        registrationToken,
      } = req.body;

      if (!recipientEmail || !parentName || !registrationToken) {
        return res.status(400).json({ success: false, message: 'Missing required email parameters.' });
      }

      const success = await EmailService.sendAdmissionApprovalEmail({
        recipientEmail,
        parentName,
        parentSurname: parentSurname || '',
        learnerName: learnerName || '',
        learnerSurname: learnerSurname || '',
        grade: grade || 'Grade 8',
        homeLanguage: homeLanguage || 'English',
        stream,
        applicationNumber: applicationNumber || 'TT-2026',
        registrationToken,
      });

      return res.json({
        success,
        message: success ? `Admission approval email dispatched via SMTP to ${recipientEmail}` : 'Failed to send email via SMTP',
      });
    } catch (error: any) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  /**
   * Dispatch Registration Success & Learner Credentials Email
   */
  static async sendRegistrationSuccess(req: Request, res: Response) {
    try {
      const {
        recipientEmail,
        parentName,
        parentSurname,
        learnerName,
        learnerSurname,
        learnerNumber,
        learnerEmail,
        generatedPassword,
      } = req.body;

      if (!recipientEmail || !parentName || !learnerNumber || !generatedPassword) {
        return res.status(400).json({ success: false, message: 'Missing required credentials parameters.' });
      }

      const success = await EmailService.sendRegistrationSuccessEmail({
        recipientEmail,
        parentName,
        parentSurname: parentSurname || '',
        learnerName: learnerName || '',
        learnerSurname: learnerSurname || '',
        learnerNumber,
        learnerEmail: learnerEmail || `${learnerNumber}@thutotech.co.za`,
        generatedPassword,
      });

      return res.json({
        success,
        message: success ? `Credentials email dispatched via SMTP to ${recipientEmail}` : 'Failed to send credentials email via SMTP',
      });
    } catch (error: any) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  /**
   * Dispatch Password Reset OTP Email
   */
  static async sendPasswordResetOtp(req: Request, res: Response) {
    try {
      const { recipientEmail, recipientName, otp, resetLink } = req.body;

      if (!recipientEmail || !otp) {
        return res.status(400).json({ success: false, message: 'Recipient email and OTP are required.' });
      }

      const success = await EmailService.sendPasswordResetOtpEmail({
        recipientEmail,
        recipientName: recipientName || 'ThutoTech User',
        otp,
        resetLink: resetLink || `https://thutotech.co.za/#/reset-password?email=${encodeURIComponent(recipientEmail)}&otp=${otp}`,
      });

      return res.json({
        success,
        message: success ? `Password reset OTP email dispatched via SMTP to ${recipientEmail}` : 'Failed to send OTP email via SMTP',
      });
    } catch (error: any) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  /**
   * Dispatch Generic / Custom System Email
   */
  static async sendCustom(req: Request, res: Response) {
    try {
      const { recipientEmail, recipientName, subject, title, body, fromName } = req.body;

      if (!recipientEmail || !subject || !body) {
        return res.status(400).json({ success: false, message: 'Recipient email, subject, and body are required.' });
      }

      const success = await EmailService.sendCustomEmail({
        recipientEmail,
        recipientName,
        subject,
        title,
        body,
        fromName,
      });

      return res.json({
        success,
        message: success ? `Custom email dispatched via SMTP to ${recipientEmail}` : 'Failed to send custom email via SMTP',
      });
    } catch (error: any) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }
}
