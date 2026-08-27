package com.rehearsal.api.controller;

import com.rehearsal.api.dto.AuthRequest;
import com.rehearsal.api.dto.AuthResponse;
import com.rehearsal.api.service.AuthService;
import com.rehearsal.api.dto.GoogleAuthRequest;
import com.rehearsal.api.dto.ForgotPasswordRequest;
import com.rehearsal.api.dto.ResetPasswordRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService service;

    public AuthController(AuthService service) {
        this.service = service;
    }

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@RequestBody AuthRequest request) {
        return ResponseEntity.ok(service.register(request));
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@RequestBody AuthRequest request) {
        return ResponseEntity.ok(service.login(request));
    }

    @PostMapping("/google")
    public ResponseEntity<AuthResponse> googleLogin(@RequestBody GoogleAuthRequest request) {
        return ResponseEntity.ok(service.googleLogin(request.getIdToken()));
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<String> forgotPassword(@RequestBody ForgotPasswordRequest request) {
        System.out.println("Received forgot password request for: " + request.getEmail());
        try {
            service.forgotPassword(request.getEmail());
            System.out.println("Forgot password request processed successfully for: " + request.getEmail());
            return ResponseEntity.ok("If that email address exists in our system, a password reset link has been sent.");
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body("Failed to process request: " + e.getMessage());
        }
    }

    @PostMapping("/reset-password")
    public ResponseEntity<String> resetPassword(@RequestBody ResetPasswordRequest request) {
        try {
            service.resetPassword(request.getToken(), request.getNewPassword());
            return ResponseEntity.ok("Password successfully reset.");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}
