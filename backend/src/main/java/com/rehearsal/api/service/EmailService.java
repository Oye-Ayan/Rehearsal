package com.rehearsal.api.service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

@Service
public class EmailService {

  private final JavaMailSender mailSender;

  @Value("${spring.mail.username}")
  private String fromEmail;

  public EmailService(JavaMailSender mailSender) {
    this.mailSender = mailSender;
  }

  public void sendPasswordResetEmail(String to, String rawToken, String webResetLink, String appResetLink) {
    try {
      MimeMessage mimeMessage = mailSender.createMimeMessage();
      MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, true, "UTF-8");

      helper.setFrom(fromEmail);
      helper.setTo(to);
      helper.setSubject("Rehearsal - Secure Password Reset");

      String htmlContent = """
          <!DOCTYPE html>
          <html>
          <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <meta name="referrer" content="no-referrer">
            <style>
              body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #0F172A; color: #F8FAFC; margin: 0; padding: 32px 16px; }
              .container { max-width: 540px; margin: 0 auto; background-color: #1E293B; border-radius: 16px; border: 1px solid #334155; padding: 36px 32px; box-shadow: 0 10px 25px rgba(0,0,0,0.4); }
              .header { font-size: 24px; font-weight: 700; color: #F8FAFC; margin-bottom: 8px; }
              .badge { display: inline-block; background-color: rgba(20, 184, 166, 0.15); color: #14B8A6; font-size: 12px; font-weight: 600; padding: 4px 10px; border-radius: 999px; margin-bottom: 24px; }
              .text { font-size: 15px; line-height: 1.6; color: #94A3B8; margin-bottom: 20px; }
              .token-box { background-color: #0F172A; border: 1px dashed #14B8A6; border-radius: 10px; padding: 16px; text-align: center; margin: 24px 0; }
              .token-label { font-size: 12px; color: #94A3B8; text-transform: uppercase; letter-spacing: 0.08em; margin-bottom: 6px; font-weight: 600; }
              .token-value { font-family: monospace, Courier, monospace; font-size: 18px; font-weight: 700; color: #14B8A6; word-break: break-all; }
              .btn-primary { display: block; width: 100%; text-align: center; background-color: #14B8A6; color: #0F172A; font-weight: 700; font-size: 15px; padding: 14px 0; border-radius: 10px; text-decoration: none; margin: 20px 0 12px 0; }
              .btn-secondary { display: block; width: 100%; text-align: center; background-color: transparent; border: 1px solid #334155; color: #F8FAFC; font-weight: 600; font-size: 14px; padding: 12px 0; border-radius: 10px; text-decoration: none; margin-bottom: 24px; }
              .footer { font-size: 12px; line-height: 1.5; color: #64748B; border-top: 1px solid #334155; padding-top: 20px; }
            </style>
          </head>
          <body>
            <div class="container">
              <div class="header">Rehearsal</div>
              <div class="badge">Password Reset Request</div>
              <div class="text">
                Hello,<br><br>
                We received a request to reset your password for your Rehearsal account. For your security, this request is single-use and will strictly expire in <strong>15 minutes</strong>.
              </div>

              <div class="token-box">
                <div class="token-label">Your Reset Token / Code</div>
                <div class="token-value">__RAW_TOKEN__</div>
              </div>

              <a href="__WEB_RESET_LINK__" class="btn-primary">Reset Password in Browser</a>
              <a href="__APP_RESET_LINK__" class="btn-secondary">Open Directly in Rehearsal App</a>

              <div class="footer">
                <strong>Didn't request this change?</strong><br>
                You can safely disregard this email. Your password will not be changed without clicking the link or entering the token above.
              </div>
            </div>
          </body>
          </html>
          """
          .replace("__RAW_TOKEN__", rawToken)
          .replace("__WEB_RESET_LINK__", webResetLink)
          .replace("__APP_RESET_LINK__", appResetLink);

      String plainText = "Hello,\n\n" +
          "You have requested to reset your password for Rehearsal. For your security, this request is valid for 15 minutes.\n\n"
          +
          "Your Reset Token:\n" + rawToken + "\n\n" +
          "Reset in browser:\n" + webResetLink + "\n\n" +
          "Open in app:\n" + appResetLink + "\n\n" +
          "If you did not request this, please safely ignore this email.";

      helper.setText(plainText, htmlContent);
      mailSender.send(mimeMessage);
    } catch (MessagingException e) {
      // Fallback to simple text email if MIME fails
      SimpleMailMessage fallback = new SimpleMailMessage();
      fallback.setFrom(fromEmail);
      fallback.setTo(to);
      fallback.setSubject("Rehearsal - Secure Password Reset");
      fallback.setText("Hello,\n\nYour Rehearsal password reset token (valid for 15 minutes):\n" +
          rawToken + "\n\nReset Link:\n" + webResetLink + "\n\nOr open in app:\n" + appResetLink);
      mailSender.send(fallback);
    }
  }

  public void sendPasswordResetEmail(String to, String resetLink) {
    sendPasswordResetEmail(to, resetLink, resetLink, resetLink);
  }
}
