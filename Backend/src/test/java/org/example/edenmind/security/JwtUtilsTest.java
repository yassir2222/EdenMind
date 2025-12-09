package org.example.edenmind.security;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class JwtUtilsTest {

    @InjectMocks
    private JwtUtils jwtUtils;

    @Mock
    private UserDetails userDetails;

    private final String secretKey = "404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970";

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        ReflectionTestUtils.setField(jwtUtils, "secretKey", secretKey);
        ReflectionTestUtils.setField(jwtUtils, "jwtExpiration", 3600000L); // 1 hour

        when(userDetails.getUsername()).thenReturn("test@example.com");
    }

    @Test
    void testGenerateToken() {
        String token = jwtUtils.generateToken(userDetails);
        assertNotNull(token);
        assertFalse(token.isEmpty());
    }

    @Test
    void testExtractUsername() {
        String token = jwtUtils.generateToken(userDetails);
        String username = jwtUtils.extractUsername(token);
        assertEquals("test@example.com", username);
    }

    @Test
    void testIsTokenValid() {
        String token = jwtUtils.generateToken(userDetails);
        boolean isValid = jwtUtils.isTokenValid(token, userDetails);
        assertTrue(isValid);
    }

    @Test
    void testIsTokenValid_WrongUsername() {
        String token = jwtUtils.generateToken(userDetails);
        UserDetails otherUser = mock(UserDetails.class);
        when(otherUser.getUsername()).thenReturn("other@example.com");
        
        boolean isValid = jwtUtils.isTokenValid(token, otherUser);
        assertFalse(isValid);
    }

    @Test
    void testIsTokenExpired() {
        // Set expiration to negative value to generate expired token
        ReflectionTestUtils.setField(jwtUtils, "jwtExpiration", -1000L);
        
        String token = jwtUtils.generateToken(userDetails);
        
        // Validation should fail or throw exception depending on implementation
        // JwtUtils catches expiration in some implementations, but here it seems to just check date.
        // However, extracting claims from expired token throws ExpiredJwtException usually.
        // Let's verify if extractUsername throws it.
        
        assertThrows(io.jsonwebtoken.ExpiredJwtException.class, () -> {
            jwtUtils.isTokenValid(token, userDetails);
        });
    }

    @Test
    void testGenerateTokenWithExtraClaims() {
        Map<String, Object> claims = new HashMap<>();
        claims.put("role", "USER");
        String token = jwtUtils.generateToken(claims, userDetails);
        
        String username = jwtUtils.extractUsername(token);
        assertEquals("test@example.com", username);
        // We can't easily extract custom claims with current public API without casting, 
        // but we can verify the token is valid and generated.
        assertTrue(jwtUtils.isTokenValid(token, userDetails));
    }
}
