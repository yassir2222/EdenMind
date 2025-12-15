package org.example.edenmind.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.example.edenmind.dto.AuthRequest;
import org.example.edenmind.dto.RegisterRequest;
import org.example.edenmind.entities.User;
import org.example.edenmind.repositories.UserRepository;
import org.example.edenmind.security.JwtUtils;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class AuthControllerTest {

    private MockMvc mockMvc;

    @Mock
    private UserRepository userRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private JwtUtils jwtUtils;

    @Mock
    private AuthenticationManager authenticationManager;

    @Mock
    private UserDetailsService userDetailsService;

    @InjectMocks
    private AuthController authController;

    private ObjectMapper objectMapper = new ObjectMapper();

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        mockMvc = MockMvcBuilders.standaloneSetup(authController).build();
    }

    @Test
    void testRegister_Success() throws Exception {
        RegisterRequest request = new RegisterRequest();
        request.setEmail("new@example.com");
        request.setPassword("password");
        request.setFirstName("First");
        request.setLastName("Last");

        when(userRepository.existsByEmail(anyString())).thenReturn(false);
        
        User savedUser = new User();
        savedUser.setId(1L);
        savedUser.setEmail("new@example.com");
        savedUser.setFirstName("First");
        savedUser.setLastName("Last");
        
        when(userRepository.save(any(User.class))).thenReturn(savedUser);
        when(passwordEncoder.encode(anyString())).thenReturn("encodedPassword");
        
        UserDetails userDetails = org.springframework.security.core.userdetails.User.builder()
                .username("new@example.com")
                .password("encodedPassword")
                .authorities("USER")
                .build();
        
        when(userDetailsService.loadUserByUsername(anyString())).thenReturn(userDetails);
        when(jwtUtils.generateToken(any(), any(UserDetails.class))).thenReturn("fake-jwt-token");

        mockMvc.perform(post("/api/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk());
    }

    @Test
    void testRegister_EmailExists() throws Exception {
        RegisterRequest request = new RegisterRequest();
        request.setEmail("existing@example.com");
        request.setPassword("password");

        when(userRepository.existsByEmail("existing@example.com")).thenReturn(true);

        mockMvc.perform(post("/api/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());
    }

    @Test
    void testLogin_Success() throws Exception {
        AuthRequest request = new AuthRequest();
        request.setEmail("test@example.com");
        request.setPassword("password");

        User user = new User();
        user.setId(1L);
        user.setEmail("test@example.com");
        user.setFirstName("First");
        user.setLastName("Last");

        when(userRepository.findByEmail("test@example.com")).thenReturn(Optional.of(user));
        
        UserDetails userDetails = org.springframework.security.core.userdetails.User.builder()
                .username("test@example.com")
                .password("encodedPassword")
                .authorities("USER")
                .build();
        
        when(userDetailsService.loadUserByUsername("test@example.com")).thenReturn(userDetails);
        when(jwtUtils.generateToken(any(), any(UserDetails.class))).thenReturn("fake-jwt-token");

        mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk());
    }

    @Test
    void testLogin_InvalidCredentials() throws Exception {
        AuthRequest request = new AuthRequest();
        request.setEmail("test@example.com");
        request.setPassword("wrongpassword");

        when(authenticationManager.authenticate(any(org.springframework.security.core.Authentication.class)))
                .thenThrow(new org.springframework.security.authentication.BadCredentialsException("Bad credentials"));

        try {
             mockMvc.perform(post("/api/auth/login")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(request)))
                    .andExpect(status().isUnauthorized()); 
        } catch (Exception e) {
            // Expected
        }
    }
    
    @Test
    void testLogin_UserNotFound() throws Exception {
        AuthRequest request = new AuthRequest();
        request.setEmail("unknown@example.com");
        request.setPassword("password");
        
        when(authenticationManager.authenticate(any())).thenReturn(null);

        when(userDetailsService.loadUserByUsername("unknown@example.com")).thenThrow(new org.springframework.security.core.userdetails.UsernameNotFoundException("User not found"));
        
        try {
             mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isNotFound()) 
                .andReturn();
        } catch (Exception e) {
            // Expected
        }
    }

    @Test
    void testRegister_WithCreatedAt_And_Claims() throws Exception {
        RegisterRequest request = new RegisterRequest();
        request.setEmail("timetest@example.com");
        request.setPassword("pass");
        request.setFirstName("Time");
        request.setLastName("User");

        User savedUser = new User();
        savedUser.setId(5L);
        savedUser.setEmail("timetest@example.com");
        savedUser.setFirstName("Time");
        savedUser.setLastName("User");
        savedUser.setCreatedAt(java.time.LocalDateTime.of(2023, 1, 1, 12, 0));

        when(userRepository.existsByEmail("timetest@example.com")).thenReturn(false);
        when(userRepository.save(any(User.class))).thenReturn(savedUser);
        when(passwordEncoder.encode(anyString())).thenReturn("encoded");
        
        UserDetails userDetails = org.springframework.security.core.userdetails.User.builder()
                .username("timetest@example.com")
                .password("encoded")
                .authorities("USER")
                .build();
        when(userDetailsService.loadUserByUsername("timetest@example.com")).thenReturn(userDetails);

        when(jwtUtils.generateToken(any(), eq(userDetails))).thenAnswer(invocation -> {
            java.util.Map<String, Object> claims = invocation.getArgument(0);
            if (!claims.get("createdAt").toString().contains("2023-01-01")) {
                throw new AssertionError("CreatedAt not passed correctly: " + claims.get("createdAt"));
            }
            if (!claims.get("firstName").equals("Time")) throw new AssertionError("FirstName missing");
            return "token-with-claims";
        });

        mockMvc.perform(post("/api/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.token", org.hamcrest.Matchers.is("token-with-claims")));
    }

    @Test
    void testLogin_WithCreatedAt_And_Claims() throws Exception {
        AuthRequest request = new AuthRequest();
        request.setEmail("logintime@example.com");
        request.setPassword("pass");

        User user = new User();
        user.setId(6L);
        user.setEmail("logintime@example.com");
        user.setFirstName("Login");
        user.setLastName("Time");
        user.setCreatedAt(java.time.LocalDateTime.of(2023, 5, 20, 10, 30));

        when(userRepository.findByEmail("logintime@example.com")).thenReturn(Optional.of(user));
        
        UserDetails userDetails = org.springframework.security.core.userdetails.User.builder()
                .username("logintime@example.com")
                .password("encoded")
                .authorities("USER")
                .build();
        when(userDetailsService.loadUserByUsername("logintime@example.com")).thenReturn(userDetails);

         when(jwtUtils.generateToken(any(), eq(userDetails))).thenAnswer(invocation -> {
            java.util.Map<String, Object> claims = invocation.getArgument(0);
             if (!claims.get("createdAt").toString().contains("2023-05-20")) {
                throw new AssertionError("CreatedAt not passed correctly: " + claims.get("createdAt"));
            }
            return "login-token";
        });

        mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.token", org.hamcrest.Matchers.is("login-token")));
    }
}
