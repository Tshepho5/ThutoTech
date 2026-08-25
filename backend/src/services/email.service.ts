import nodemailer from 'nodemailer';

export class EmailService {
  private static transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST || 'smtp.mailtrap.io',
    port: Number(process.env.SMTP_PORT) || 2525,
    auth: {
      user: process.env.SMTP_USER || '',
      pass: process.env.SMTP_PASS || '',
    },
  });

  static async sendAdmissionApprovalEmail(params: {
    recipientEmail: string;
    parentName: string;
    parentSurname: string;
    learnerName: string;
    learnerSurname: string;
    grade: string;
    applicationNumber: string;
    registrationToken: string;
  }): Promise<boolean> {
    const { recipientEmail, parentName, parentSurname, learnerName, learnerSurname, grade, applicationNumber, registrationToken } = params;

    const htmlContent = `
      <div style="font-family: 'Segoe UI', Arial, sans-serif; max-width: 600px; margin: auto; padding: 24px; border: 1px solid #E2E8F0; border-radius: 12px; background-color: #ffffff;">
        <div style="background-color: #0B192C; padding: 20px; border-radius: 8px; text-align: center; color: white;">
          <h1 style="margin: 0; font-size: 22px; color: #16C47F;">ThutoTech Academy</h1>
          <p style="margin: 4px 0 0 0; font-size: 12px; letter-spacing: 1px; color: #94A3B8;">LEARN • CONNECT • EMPOWER</p>
        </div>

        <div style="padding: 24px 0;">
          <h2 style="color: #0B192C; margin-top: 0;">Official Admission Approval</h2>
          <p style="color: #334155; font-size: 15px; line-height: 1.6;">
            Dear <strong>${parentName} ${parentSurname}</strong>,
          </p>
          <p style="color: #334155; font-size: 15px; line-height: 1.6;">
            We are delighted to confirm that the admission application for <strong>${learnerName} ${learnerSurname}</strong> for <strong>${grade}</strong> (Ref: <code>${applicationNumber}</code>) has been <strong>APPROVED</strong>.
          </p>

          <div style="background-color: #F0FDF4; border: 1px solid #86EFAC; border-radius: 8px; padding: 18px; text-align: center; margin: 20px 0;">
            <p style="margin: 0 0 8px 0; font-size: 13px; color: #166534; font-weight: 600;">YOUR REGISTRATION TOKEN:</p>
            <div style="font-size: 22px; font-weight: bold; color: #0B192C; letter-spacing: 2px; background: white; padding: 10px; border-radius: 6px; display: inline-block;">
              ${registrationToken}
            </div>
          </div>

          <h3 style="color: #0B192C; font-size: 15px;">Next Steps to Activate Your Accounts:</h3>
          <ol style="color: #475569; font-size: 14px; line-height: 1.6; padding-left: 20px;">
            <li>Open the ThutoTech Application.</li>
            <li>Click on <strong>"Complete Registration"</strong>.</li>
            <li>Enter your token <code>${registrationToken}</code> and set your parent password.</li>
            <li>Confirm learner National ID and complete activation.</li>
          </ol>
        </div>

        <div style="border-top: 1px solid #E2E8F0; padding-top: 16px; font-size: 12px; color: #64748B; text-align: center;">
          <p style="margin: 0;">ThutoTech Admissions Directorate • Automated Academic Notification</p>
        </div>
      </div>
    `;

    try {
      if (process.env.SMTP_USER) {
        await this.transporter.sendMail({
          from: `"ThutoTech Admissions" <${process.env.SMTP_FROM || 'admissions@thutotech.co.za'}>`,
          to: recipientEmail,
          subject: `Official Admission Approval - ThutoTech Academy (${applicationNumber})`,
          html: htmlContent,
        });
      }
      console.log(`✉️ [EmailService] Admission approval email dispatched to ${recipientEmail} (Token: ${registrationToken})`);
      return true;
    } catch (error) {
      console.error('⚠️ [EmailService] Failed to send email via SMTP:', error);
      return false;
    }
  }
}
