package com.rehearsal.api;

import com.rehearsal.api.dto.AuthRequest;
import com.rehearsal.api.dto.AuthResponse;
import com.rehearsal.api.service.AuthService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import com.rehearsal.api.service.EmbeddingService;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;

@SpringBootTest
@TestPropertySource(locations="classpath:application-test.properties")
public class AuthIntegrationTest {

    @MockitoBean
    private EmbeddingService embeddingService;

    @Autowired
    private AuthService authService;

    @Test
    public void testRegisterAndLogin() {
        AuthRequest registerRequest = new AuthRequest();
        registerRequest.setEmail("testuser@example.com");
        registerRequest.setPassword("securePassword123");

        // 1. Test Registration
        AuthResponse registerResponse = authService.register(registerRequest);
        assertNotNull(registerResponse.getToken());

        // 2. Test Login
        AuthRequest loginRequest = new AuthRequest();
        loginRequest.setEmail("testuser@example.com");
        loginRequest.setPassword("securePassword123");

        AuthResponse loginResponse = authService.login(loginRequest);
        assertNotNull(loginResponse.getToken());
        
        // 3. Test Invalid Login
        AuthRequest invalidLoginRequest = new AuthRequest();
        invalidLoginRequest.setEmail("testuser@example.com");
        invalidLoginRequest.setPassword("wrongpassword");
        
        assertThrows(Exception.class, () -> authService.login(invalidLoginRequest));
    }
}
