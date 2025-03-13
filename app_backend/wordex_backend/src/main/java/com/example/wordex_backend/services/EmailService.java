package com.example.wordex_backend.services;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.MailException;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

@Service
public class EmailService {

    @Autowired
    private JavaMailSender javaMailSender;

    public void sendWelcomeEmail(String firstName, String lastName, String email) throws MessagingException {
        // Create email message
        MimeMessage message = javaMailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper((jakarta.mail.internet.MimeMessage) message, true);

        try {
            // Set up email message details
            helper.setFrom("your-email@gmail.com");
            helper.setTo(email);
            helper.setSubject("Welcome to Wordex, " + firstName + " " + lastName);
            helper.setText("Dear " + firstName + " " + lastName + ",\n\nWelcome to Wordex! We're glad to have you on board.");

            // Send the email
            javaMailSender.send(message);
        } catch (MailException e) {
            e.printStackTrace(); // Handle the exception
            throw new MessagingException("Failed to send email", e);
        }
    }
}
