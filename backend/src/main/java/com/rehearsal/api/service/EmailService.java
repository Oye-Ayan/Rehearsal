package com.rehearsal.api.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class EmailService {

    private final JavaMailSender mailSender;

    @Value("${spring.mail.username}")
    private String fromEmail;

    public EmailService(JavaMailSender mailSender) {
        this.mailSender = mailSender;
    }

    public void sendPasswordResetEmail(String to, String resetLink) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(fromEmail);
        message.setTo(to);
        message.setSubject("Rehearsal - Password Reset Request");
        message.setText("Hello,\n\nYou have requested to reset your password for Rehearsal. " +
                "Please click the link below to set a new password:\n\n" +
                resetLink + "\n\nIf you did not request this, please ignore this email.");

        mailSender.send(message);
    }
}
