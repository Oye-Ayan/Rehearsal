package com.rehearsal.api.service;

import com.rehearsal.api.domain.User;
import com.rehearsal.api.dto.AuthRequest;
import com.rehearsal.api.dto.AuthResponse;
import com.rehearsal.api.repository.UserRepository;
import com.rehearsal.api.domain.PasswordResetToken;
import com.rehearsal.api.repository.PasswordResetTokenRepository;
import com.rehearsal.api.security.CustomUserDetails;
import com.rehearsal.api.security.JwtService;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Value;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;

import java.util.Collections;
import java.util.UUID;
import java.time.LocalDateTime;

@Service
public class AuthService {

    private final UserRepository repository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;

    private final PasswordResetTokenRepository tokenRepository;
    private final EmailService emailService;

    @Value("${google.client.id}")
    private String googleClientId;

    public AuthService(UserRepository repository, PasswordEncoder passwordEncoder, JwtService jwtService, AuthenticationManager authenticationManager, PasswordResetTokenRepository tokenRepository, EmailService emailService) {
        this.repository = repository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.authenticationManager = authenticationManager;
        this.tokenRepository = tokenRepository;
        this.emailService = emailService;
    }

    public AuthResponse register(AuthRequest request) {
        if (repository.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("Email already exists");
        }

        User user = new User();
        user.setEmail(request.getEmail());
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        
        repository.save(user);

        String jwtToken = jwtService.generateToken(new CustomUserDetails(user));
        return new AuthResponse(jwtToken);
    }

    public AuthResponse login(AuthRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getEmail(),
                        request.getPassword()
                )
        );
        
        User user = repository.findByEmail(request.getEmail())
                .orElseThrow();
                
        String jwtToken = jwtService.generateToken(new CustomUserDetails(user));
        return new AuthResponse(jwtToken);
    }

    public AuthResponse googleLogin(String idTokenString) {
        try {
            GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(new NetHttpTransport(), GsonFactory.getDefaultInstance())
                    .setAudience(Collections.singletonList(googleClientId))
                    .build();

            GoogleIdToken idToken = verifier.verify(idTokenString);
            if (idToken != null) {
                GoogleIdToken.Payload payload = idToken.getPayload();
                String email = payload.getEmail();

                // Check if user exists
                User user = repository.findByEmail(email).orElseGet(() -> {
                    User newUser = new User();
                    newUser.setEmail(email);
                    // generate random password for google users
                    newUser.setPasswordHash(passwordEncoder.encode(UUID.randomUUID().toString()));
                    return repository.save(newUser);
                });

                String jwtToken = jwtService.generateToken(new CustomUserDetails(user));
                return new AuthResponse(jwtToken);
            } else {
                throw new IllegalArgumentException("Invalid ID token.");
            }
        } catch (Exception e) {
            throw new RuntimeException("Failed to verify Google token", e);
        }
    }

    @org.springframework.transaction.annotation.Transactional
    public void forgotPassword(String email) {
        System.out.println("AuthService: looking up user by email: " + email);
        User user = repository.findByEmail(email).orElse(null);
        if (user == null) {
            System.out.println("AuthService: User not found for email: " + email);
            // Silently return to prevent email enumeration attacks
            return;
        }
        System.out.println("AuthService: User found. Generating token...");

        // Delete any existing tokens for this user and flush to avoid unique constraint violations
        tokenRepository.deleteByUser(user);
        tokenRepository.flush();

        // Create new token
        String tokenStr = UUID.randomUUID().toString();
        PasswordResetToken token = new PasswordResetToken(tokenStr, user, LocalDateTime.now().plusHours(1));
        tokenRepository.save(token);

        // Ideally this would be a deep link into the mobile app, but a mock web url works for the simulation
        String resetLink = "https://rehearsal.app/reset-password?token=" + tokenStr;
        emailService.sendPasswordResetEmail(user.getEmail(), resetLink);
    }

    @org.springframework.transaction.annotation.Transactional
    public void resetPassword(String tokenStr, String newPassword) {
        PasswordResetToken token = tokenRepository.findByToken(tokenStr)
                .orElseThrow(() -> new IllegalArgumentException("Invalid or expired token"));

        if (token.getExpiryDate().isBefore(LocalDateTime.now())) {
            tokenRepository.delete(token);
            throw new IllegalArgumentException("Token has expired");
        }

        User user = token.getUser();
        user.setPasswordHash(passwordEncoder.encode(newPassword));
        repository.save(user);

        // Delete token after successful reset
        tokenRepository.delete(token);
    }
}
