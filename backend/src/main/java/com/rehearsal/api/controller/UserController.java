package com.rehearsal.api.controller;

import com.rehearsal.api.domain.User;
import com.rehearsal.api.dto.UpdateUsernameRequest;
import com.rehearsal.api.dto.UserProfileResponse;
import com.rehearsal.api.repository.UserRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserRepository userRepository;

    public UserController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @GetMapping("/me")
    public ResponseEntity<UserProfileResponse> getCurrentUser(Authentication authentication) {
        String email = authentication.getName();
        return userRepository.findByEmail(email)
                .map(user -> ResponseEntity.ok(new UserProfileResponse(user.getEmail(), user.getUsername())))
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/username")
    public ResponseEntity<?> updateUsername(@RequestBody UpdateUsernameRequest request, Authentication authentication) {
        String newUsername = request.getUsername();
        
        if (newUsername == null || newUsername.trim().length() < 3) {
            return ResponseEntity.badRequest().body("Username must be at least 3 characters long.");
        }
        
        if (userRepository.existsByUsername(newUsername.trim())) {
            return ResponseEntity.badRequest().body("Username is already taken.");
        }

        String email = authentication.getName();
        User user = userRepository.findByEmail(email).orElse(null);
        
        if (user == null) {
            return ResponseEntity.notFound().build();
        }

        user.setUsername(newUsername.trim());
        userRepository.save(user);

        return ResponseEntity.ok(new UserProfileResponse(user.getEmail(), user.getUsername()));
    }
}
