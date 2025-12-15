package org.example.edenmind.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;

import java.io.IOException;
import java.util.Collections;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

class JwtAuthenticationFilterTest {

    @Mock
    private JwtUtils jwtUtils;

    @Mock
    private UserDetailsService userDetailsService;

    @Mock
    private HttpServletRequest request;

    @Mock
    private HttpServletResponse response;

    @Mock
    private FilterChain filterChain;

    @InjectMocks
    private JwtAuthenticationFilter jwtAuthenticationFilter;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        SecurityContextHolder.clearContext(); // Nettoyer le contexte avant chaque test
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext(); // Nettoyer après pour ne pas polluer les autres tests
    }

    @Test
    void testDoFilterInternal_NoAuthHeader() throws ServletException, IOException {
        // Branche 1: Header null
        when(request.getHeader("Authorization")).thenReturn(null);

        jwtAuthenticationFilter.doFilterInternal(request, response, filterChain);

        verify(filterChain).doFilter(request, response);
        verifyNoInteractions(jwtUtils);
        verifyNoInteractions(userDetailsService);
    }

    @Test
    void testDoFilterInternal_InvalidHeaderFormat() throws ServletException, IOException {
        // Branche 2: Header ne commence pas par "Bearer "
        when(request.getHeader("Authorization")).thenReturn("Basic xyz123");

        jwtAuthenticationFilter.doFilterInternal(request, response, filterChain);

        verify(filterChain).doFilter(request, response);
        verifyNoInteractions(jwtUtils);
    }

    @Test
    void testDoFilterInternal_ExtractionException() throws ServletException, IOException {
        // Branche 3: Exception lors de l'extraction (catch block)
        when(request.getHeader("Authorization")).thenReturn("Bearer invalid.token");
        when(jwtUtils.extractUsername(anyString())).thenThrow(new RuntimeException("Extraction failed"));

        jwtAuthenticationFilter.doFilterInternal(request, response, filterChain);

        verify(filterChain).doFilter(request, response);
        // On s'assure qu'on n'a pas essayé de charger l'user
        verifyNoInteractions(userDetailsService);
    }

    @Test
    void testDoFilterInternal_UserAlreadyAuthenticated() throws ServletException, IOException {
        // Branche 4: Utilisateur déjà authentifié dans le contexte
        when(request.getHeader("Authorization")).thenReturn("Bearer valid.token");
        when(jwtUtils.extractUsername("valid.token")).thenReturn("user@example.com");

        // Simuler un contexte déjà rempli
        Authentication existingAuth = mock(Authentication.class);
        SecurityContext securityContext = mock(SecurityContext.class);
        when(securityContext.getAuthentication()).thenReturn(existingAuth);
        SecurityContextHolder.setContext(securityContext);

        jwtAuthenticationFilter.doFilterInternal(request, response, filterChain);

        verify(filterChain).doFilter(request, response);
        // Si déjà auth, on ne doit pas recharger l'user ni valider le token
        verify(userDetailsService, never()).loadUserByUsername(anyString());
    }

    @Test
    void testDoFilterInternal_UserEmailNull() throws ServletException, IOException {
        // Branche 5: extractUsername retourne null (cas rare mais possible)
        when(request.getHeader("Authorization")).thenReturn("Bearer token");
        when(jwtUtils.extractUsername("token")).thenReturn(null);

        jwtAuthenticationFilter.doFilterInternal(request, response, filterChain);

        verify(filterChain).doFilter(request, response);
        verify(userDetailsService, never()).loadUserByUsername(anyString());
    }

    @Test
    void testDoFilterInternal_ValidToken_SetsAuthentication() throws ServletException, IOException {
        // Branche 6 (Happy Path): Token valide, contexte vide -> Authentification réussie
        String token = "valid.token";
        String email = "user@example.com";

        when(request.getHeader("Authorization")).thenReturn("Bearer " + token);
        when(jwtUtils.extractUsername(token)).thenReturn(email);

        UserDetails userDetails = new User(email, "password", Collections.emptyList());
        when(userDetailsService.loadUserByUsername(email)).thenReturn(userDetails);
        when(jwtUtils.isTokenValid(token, userDetails)).thenReturn(true);

        // Appel de la méthode
        jwtAuthenticationFilter.doFilterInternal(request, response, filterChain);

        // Vérifications
        verify(filterChain).doFilter(request, response);
        verify(userDetailsService).loadUserByUsername(email);
        verify(jwtUtils).isTokenValid(token, userDetails);

        // Vérifier que l'authentification a bien été mise dans le SecurityContext
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        assertNotNull(auth, "L'authentification ne doit pas être null");
        assertNotNull(auth.getDetails(), "Les détails Web doivent être définis");
    }

    @Test
    void testDoFilterInternal_InvalidToken_DoesNotSetAuthentication() throws ServletException, IOException {
        // Branche 7: Token invalide (expiré ou mauvais user)
        String token = "invalid.token";
        String email = "user@example.com";

        when(request.getHeader("Authorization")).thenReturn("Bearer " + token);
        when(jwtUtils.extractUsername(token)).thenReturn(email);

        UserDetails userDetails = new User(email, "password", Collections.emptyList());
        when(userDetailsService.loadUserByUsername(email)).thenReturn(userDetails);

        // Le token est considéré invalide
        when(jwtUtils.isTokenValid(token, userDetails)).thenReturn(false);

        jwtAuthenticationFilter.doFilterInternal(request, response, filterChain);

        verify(filterChain).doFilter(request, response);

        // Vérifier que le contexte est resté vide
        assertNull(SecurityContextHolder.getContext().getAuthentication(), "L'authentification devrait être null pour un token invalide");
    }
}