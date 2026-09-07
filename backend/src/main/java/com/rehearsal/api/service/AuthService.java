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

    @Value("${app.reset-password.url-scheme:rehearsal://reset-password?token=}")
    private String resetPasswordUrlScheme;

    @Value("${app.reset-password.web-url:http://10.10.20.121:8080/reset-password?token=}")
    private String webResetUrl;

    public AuthService(UserRepository repository, PasswordEncoder passwordEncoder, JwtService jwtService,
            AuthenticationManager authenticationManager, PasswordResetTokenRepository tokenRepository,
            EmailService emailService) {
        this.repository = repository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.authenticationManager = authenticationManager;
        this.tokenRepository = tokenRepository;
        this.emailService = emailService;
    }

    private String hashToken(String rawToken) {
        try {
            java.security.MessageDigest digest = java.security.MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(rawToken.getBytes(java.nio.charset.StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1)
                    hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (java.security.NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 algorithm not available", e);
        }
    }

    @org.springframework.transaction.annotation.Transactional
    public void forgotPassword(String email) {
        System.out.println("AuthService: Secure forgot-password request for: " + email);
        User user = repository.findByEmail(email).orElse(null);
        if (user == null) {
            // Constant-time mitigation against timing attacks / email enumeration
            hashToken("dummy-salt-" + email);
            System.out.println("AuthService: User not found (anti-enumeration return).");
            return;
        }

        // Delete any existing tokens for this user immediately
        tokenRepository.deleteByUser(user);
        tokenRepository.flush();

        // Generate 128-bit cryptographically secure raw token
        String rawToken = UUID.randomUUID().toString();
        String tokenHash = hashToken(rawToken);

        // Enforce strict 15-minute single-use expiration
        PasswordResetToken token = new PasswordResetToken(tokenHash, user, LocalDateTime.now().plusMinutes(15));
        tokenRepository.save(token);

        String webLink = (webResetUrl != null && !webResetUrl.isBlank() ? webResetUrl
                : "http://10.10.20.121:8080/reset-password?token=") + rawToken;
        String appLink = (resetPasswordUrlScheme != null && !resetPasswordUrlScheme.isBlank() ? resetPasswordUrlScheme
                : "rehearsal://reset-password?token=") + rawToken;

        emailService.sendPasswordResetEmail(user.getEmail(), rawToken, webLink, appLink);
    }

    @org.springframework.transaction.annotation.Transactional
    public void resetPassword(String rawToken, String newPassword) {
        if (rawToken == null || rawToken.trim().isEmpty()) {
            throw new IllegalArgumentException("Reset token is required");
        }
        if (newPassword == null || newPassword.length() < 8) {
            throw new IllegalArgumentException("Password must be at least 8 characters");
        }

        String tokenHash = hashToken(rawToken.trim());
        PasswordResetToken token = tokenRepository.findByToken(tokenHash)
                .or(() -> tokenRepository.findByToken(rawToken.trim())) // Backward-compatibility fallback for in-flight
                                                                        // tokens
                .orElseThrow(() -> new IllegalArgumentException("Invalid or expired reset token"));

        if (token.getExpiryDate().isBefore(LocalDateTime.now())) {
            tokenRepository.delete(token);
            throw new IllegalArgumentException("Reset token has expired (validity is 15 minutes)");
        }

        User user = token.getUser();
        user.setPasswordHash(passwordEncoder.encode(newPassword));
        repository.save(user);

        // Delete token immediately to enforce single-use
        tokenRepository.delete(token);
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
                        request.getPassword()));

        User user = repository.findByEmail(request.getEmail())
                .orElseThrow();

        String jwtToken = jwtService.generateToken(new CustomUserDetails(user));
        return new AuthResponse(jwtToken);
    }

    public AuthResponse googleLogin(String idTokenString) {
        try {
            GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(new NetHttpTransport(),
                    GsonFactory.getDefaultInstance())
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
}
