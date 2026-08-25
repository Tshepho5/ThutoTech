import nodemailer from 'nodemailer';

export class EmailService {
  private static transporter: nodemailer.Transporter | null = null;

  private static async getTransporter(): Promise<nodemailer.Transporter> {
    if (this.transporter) return this.transporter;

    if (process.env.SMTP_USER && process.env.SMTP_PASS) {
      const isGmail = (process.env.SMTP_HOST || '').includes('gmail') || (process.env.SMTP_USER || '').includes('gmail');
      
      this.transporter = isGmail
        ? nodemailer.createTransport({
            service: 'gmail',
            auth: {
              user: process.env.SMTP_USER,
              pass: process.env.SMTP_PASS,
            },
          })
        : nodemailer.createTransport({
            host: process.env.SMTP_HOST || 'smtp.gmail.com',
            port: Number(process.env.SMTP_PORT) || 587,
            secure: Number(process.env.SMTP_PORT) === 465,
            connectionTimeout: 5000,
            auth: {
              user: process.env.SMTP_USER,
              pass: process.env.SMTP_PASS,
            },
          });
    } else {
      // Fallback: Create instant test SMTP inbox via Ethereal for zero-friction testing
      console.log('ℹ️ [EmailService] Generating instant test SMTP account via Ethereal...');
      const testAccount = await nodemailer.createTestAccount();
      this.transporter = nodemailer.createTransport({
        host: 'smtp.ethereal.email',
        port: 587,
        secure: false,
        auth: {
          user: testAccount.user,
          pass: testAccount.pass,
        },
      });
      console.log(`✅ [EmailService] Test SMTP ready: ${testAccount.user}`);
    }

    return this.transporter;
  }

  /**
   * 1. Send Admission Acceptance Email with Registration Token
   */
  static async sendAdmissionApprovalEmail(params: {
    recipientEmail: string;
    parentName: string;
    parentSurname: string;
    learnerName: string;
    learnerSurname: string;
    grade: string;
    homeLanguage: string;
    stream?: string;
    applicationNumber: string;
    registrationToken: string;
  }): Promise<boolean> {
    const { recipientEmail, parentName, parentSurname, learnerName, learnerSurname, grade, homeLanguage, stream, applicationNumber, registrationToken } = params;

    const htmlContent = `
      <div style="font-family: 'Segoe UI', Arial, sans-serif; max-width: 600px; margin: auto; padding: 24px; border: 1px solid #E2E8F0; border-radius: 16px; background-color: #ffffff;">
        <div style="background-color: #0B192C; padding: 24px; border-radius: 12px; text-align: center; color: white;">
          <h1 style="margin: 0; font-size: 24px; color: #16C47F; font-weight: 800;">ThutoTech Academy</h1>
          <p style="margin: 6px 0 0 0; font-size: 12px; letter-spacing: 2px; color: #94A3B8;">LEARN • CONNECT • EMPOWER</p>
        </div>

        <div style="padding: 24px 4px;">
          <h2 style="color: #0B192C; margin-top: 0; font-size: 20px;">Official Admission Acceptance</h2>
          <p style="color: #334155; font-size: 15px; line-height: 1.6;">
            Dear <strong>${parentName} ${parentSurname}</strong>,
          </p>
          <p style="color: #334155; font-size: 15px; line-height: 1.6;">
            Congratulations! We are pleased to confirm that the admission application for <strong>${learnerName} ${learnerSurname}</strong> for <strong>${grade}</strong> (Home Language: <em>${homeLanguage}</em>${stream ? ` • Stream: <em>${stream}</em>` : ''}) has been <strong style="color: #16A34A;">APPROVED</strong>.
          </p>

          <div style="background-color: #F0FDF4; border: 1.5px dashed #16C47F; border-radius: 12px; padding: 20px; text-align: center; margin: 24px 0;">
            <p style="margin: 0 0 8px 0; font-size: 12px; color: #166534; font-weight: 700; letter-spacing: 1px;">YOUR OFFICIAL REGISTRATION TOKEN:</p>
            <div style="font-size: 24px; font-weight: 800; color: #0B192C; letter-spacing: 3px; background: white; padding: 12px 20px; border-radius: 8px; display: inline-block; box-shadow: 0 2px 8px rgba(0,0,0,0.05);">
              ${registrationToken}
            </div>
            <p style="margin: 10px 0 0 0; font-size: 12px; color: #475569;">Application Reference: <strong>${applicationNumber}</strong></p>
          </div>

          <h3 style="color: #0B192C; font-size: 16px;">Next Steps to Register:</h3>
          <ol style="color: #475569; font-size: 14px; line-height: 1.8; padding-left: 20px;">
            <li>Open the ThutoTech Application.</li>
            <li>Click on <strong>"Complete Registration"</strong>.</li>
            <li>Enter your token <code>${registrationToken}</code> and set your parent password.</li>
            <li>Provide learner National ID number, name, and surname to activate the profile and generate login credentials.</li>
          </ol>
        </div>

        <div style="border-top: 1px solid #E2E8F0; padding-top: 16px; font-size: 12px; color: #64748B; text-align: center;">
          <p style="margin: 0;">ThutoTech Admissions & Records Directorate • South Africa</p>
        </div>
      </div>
    `;

    try {
      const transporter = await this.getTransporter();
      const info = await transporter.sendMail({
        from: `"ThutoTech Admissions" <${process.env.SMTP_FROM || 'admissions@thutotech.co.za'}>`,
        to: recipientEmail,
        subject: `Official Admission Approval - ThutoTech Academy (${applicationNumber})`,
        html: htmlContent,
      });

      console.log(`✉️ [EmailService] Admission approval email dispatched to ${recipientEmail} (Token: ${registrationToken})`);
      if (nodemailer.getTestMessageUrl(info)) {
        console.log(`🔗 [EmailService] Preview Email Online: ${nodemailer.getTestMessageUrl(info)}`);
      }
      return true;
    } catch (error) {
      console.error('⚠️ [EmailService] Failed to send admission approval email:', error);
      return false;
    }
  }

  /**
   * 2. Send Registration Confirmation & Learner Access Credentials
   */
  static async sendRegistrationSuccessEmail(params: {
    recipientEmail: string;
    parentName: string;
    parentSurname: string;
    learnerName: string;
    learnerSurname: string;
    learnerNumber: string;
    learnerEmail: string;
    generatedPassword: string;
  }): Promise<boolean> {
    const { recipientEmail, parentName, parentSurname, learnerName, learnerSurname, learnerNumber, learnerEmail, generatedPassword } = params;

    const htmlContent = `
      <div style="font-family: 'Segoe UI', Arial, sans-serif; max-width: 600px; margin: auto; padding: 24px; border: 1px solid #E2E8F0; border-radius: 16px; background-color: #ffffff;">
        <div style="background-color: #0B192C; padding: 24px; border-radius: 12px; text-align: center; color: white;">
          <h1 style="margin: 0; font-size: 24px; color: #16C47F; font-weight: 800;">ThutoTech Academy</h1>
          <p style="margin: 6px 0 0 0; font-size: 12px; letter-spacing: 2px; color: #94A3B8;">LEARN • CONNECT • EMPOWER</p>
        </div>

        <div style="padding: 24px 4px;">
          <h2 style="color: #0B192C; margin-top: 0; font-size: 20px;">Registration Confirmed & Learner Access Credentials</h2>
          <p style="color: #334155; font-size: 15px; line-height: 1.6;">
            Dear <strong>${parentName} ${parentSurname}</strong>,
          </p>
          <p style="color: #334155; font-size: 15px; line-height: 1.6;">
            Your registration for <strong>${learnerName} ${learnerSurname}</strong> has been successfully processed and activated in the ThutoTech system.
          </p>

          <div style="background-color: #0B192C; border-radius: 12px; padding: 22px; color: white; margin: 24px 0;">
            <p style="margin: 0 0 12px 0; font-size: 13px; color: #16C47F; font-weight: 700; letter-spacing: 1px;">OFFICIAL LEARNER LOGIN CREDENTIALS:</p>
            
            <p style="margin: 6px 0; font-size: 14px;"><strong>Student Number:</strong> <code style="background: rgba(255,255,255,0.15); padding: 3px 8px; border-radius: 4px; color: #FFFFFF;">${learnerNumber}</code></p>
            <p style="margin: 6px 0; font-size: 14px;"><strong>Learner Login Email:</strong> <code style="background: rgba(255,255,255,0.15); padding: 3px 8px; border-radius: 4px; color: #FFFFFF;">${learnerEmail}</code></p>
            <p style="margin: 6px 0; font-size: 14px;"><strong>Generated Password:</strong> <code style="background: rgba(22,196,127,0.25); padding: 4px 10px; border-radius: 4px; color: #16C47F; font-weight: bold; font-size: 16px;">${generatedPassword}</code></p>
            
            <p style="margin: 12px 0 0 0; font-size: 11px; color: #94A3B8;">
              *(Password generated systematically using standard security rules from the 13-digit National ID)*
            </p>
          </div>

          <div style="background-color: #F8FAFC; border: 1px solid #E2E8F0; border-radius: 8px; padding: 14px; margin-bottom: 20px;">
            <p style="margin: 0; font-size: 13px; color: #334155;">
              <strong>Parent Portal Login:</strong> Use your email <code>${recipientEmail}</code> and the password you created during registration.
            </p>
          </div>

          <p style="color: #475569; font-size: 14px; line-height: 1.6;">
            ${learnerName} can now sign in to the Learner Portal to access their CAPS timetable, class assignments, and teacher updates.
          </p>
        </div>

        <div style="border-top: 1px solid #E2E8F0; padding-top: 16px; font-size: 12px; color: #64748B; text-align: center;">
          <p style="margin: 0;">ThutoTech Admissions & Records Directorate • South Africa</p>
        </div>
      </div>
    `;

    try {
      const transporter = await this.getTransporter();
      const info = await transporter.sendMail({
        from: `"ThutoTech Records" <${process.env.SMTP_FROM || 'records@thutotech.co.za'}>`,
        to: recipientEmail,
        subject: `Registration Confirmed - Learner Login Details for ${learnerName} (${learnerNumber})`,
        html: htmlContent,
      });

      console.log(`✉️ [EmailService] Learner credentials email dispatched to ${recipientEmail} (Student No: ${learnerNumber})`);
      if (nodemailer.getTestMessageUrl(info)) {
        console.log(`🔗 [EmailService] Preview Email Online: ${nodemailer.getTestMessageUrl(info)}`);
      }
      return true;
    } catch (error) {
      console.error('⚠️ [EmailService] Failed to send registration confirmation email:', error);
      return false;
    }
  }

  /**
   * 3. Send 6-digit Password Reset OTP with 2-minute Expiry Notice
   */
  static async sendPasswordResetOtpEmail(params: {
    recipientEmail: string;
    recipientName: string;
    otp: string;
    resetLink: string;
  }): Promise<boolean> {
    const { recipientEmail, recipientName, otp, resetLink } = params;

    const htmlContent = `
      <div style="font-family: 'Segoe UI', Arial, sans-serif; max-width: 600px; margin: auto; padding: 24px; border: 1px solid #E2E8F0; border-radius: 16px; background-color: #ffffff;">
        <div style="background-color: #0B192C; padding: 24px; border-radius: 12px; text-align: center; color: white;">
          <h1 style="margin: 0; font-size: 24px; color: #16C47F; font-weight: 800;">ThutoTech Academy</h1>
          <p style="margin: 6px 0 0 0; font-size: 12px; letter-spacing: 2px; color: #94A3B8;">LEARN • CONNECT • EMPOWER</p>
        </div>

        <div style="padding: 24px 4px;">
          <h2 style="color: #0B192C; margin-top: 0; font-size: 20px;">Password Reset Verification Code</h2>
          <p style="color: #334155; font-size: 15px; line-height: 1.6;">
            Hello <strong>${recipientName}</strong>,
          </p>
          <p style="color: #334155; font-size: 15px; line-height: 1.6;">
            We received a request to reset the password for your ThutoTech account (<strong>${recipientEmail}</strong>). Please use the 6-digit verification code below:
          </p>

          <div style="background-color: #0B192C; border: 2px solid #16C47F; border-radius: 14px; padding: 24px; text-align: center; margin: 24px 0;">
            <p style="margin: 0 0 8px 0; font-size: 12px; color: #16C47F; font-weight: 700; letter-spacing: 1.5px;">YOUR 6-DIGIT OTP CODE:</p>
            <div style="font-size: 36px; font-weight: 900; color: #FFFFFF; letter-spacing: 10px; background: rgba(22, 196, 127, 0.15); padding: 12px 24px; border-radius: 10px; display: inline-block;">
              ${otp}
            </div>
            <p style="margin: 14px 0 0 0; font-size: 13px; color: #F87171; font-weight: bold;">
              ⏳ This code will expire in 2 MINUTES (120 seconds).
            </p>
          </div>

          <div style="text-align: center; margin: 24px 0;">
            <a href="${resetLink}" style="background-color: #16C47F; color: #0B192C; font-weight: bold; text-decoration: none; padding: 12px 24px; border-radius: 8px; font-size: 14px; display: inline-block;">
              Verify OTP & Reset Password Directly
            </a>
          </div>

          <p style="color: #64748B; font-size: 13px; line-height: 1.5;">
            If you did not request this password reset or remember your old password, you can safely ignore this email.
          </p>
        </div>

        <div style="border-top: 1px solid #E2E8F0; padding-top: 16px; font-size: 12px; color: #64748B; text-align: center;">
          <p style="margin: 0;">ThutoTech Security & Authentication Services • South Africa</p>
        </div>
      </div>
    `;

    try {
      const transporter = await this.getTransporter();
      const info = await transporter.sendMail({
        from: `"ThutoTech Security" <${process.env.SMTP_FROM || 'security@thutotech.co.za'}>`,
        to: recipientEmail,
        subject: `Your 6-Digit Password Reset OTP: ${otp} (Expires in 2 mins) - ThutoTech`,
        html: htmlContent,
      });

      console.log(`✉️ [EmailService] Password reset OTP dispatched to ${recipientEmail} (OTP: ${otp})`);
      if (nodemailer.getTestMessageUrl(info)) {
        console.log(`🔗 [EmailService] Preview OTP Email Online: ${nodemailer.getTestMessageUrl(info)}`);
      }
      return true;
    } catch (error) {
      console.error('⚠️ [EmailService] Failed to send password reset OTP email:', error);
      return false;
    }
  }
}
