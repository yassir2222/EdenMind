package org.example.edenmind.controller;

import lombok.RequiredArgsConstructor;
import org.example.edenmind.dto.AuthRequest;
import org.example.edenmind.dto.AuthResponse;
import org.example.edenmind.dto.RegisterRequest;
import org.example.edenmind.entities.User;
import org.example.edenmind.repositories.UserRepository;
import org.example.edenmind.security.JwtUtils;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtils jwtUtils;
    private final AuthenticationManager authenticationManager;
    private final UserDetailsService userDetailsService;

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@RequestBody RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            return ResponseEntity.badRequest().build();
        }

        var user = new User();
        user.setFirstName(request.getFirstName());
        user.setLastName(request.getLastName());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        
        userRepository.save(user);

        UserDetails userDetails = userDetailsService.loadUserByUsername(user.getEmail());
        
        java.util.Map<String, Object> extraClaims = new java.util.HashMap<>();
        extraClaims.put("firstName", user.getFirstName());
        extraClaims.put("lastName", user.getLastName());
        extraClaims.put("createdAt", user.getCreatedAt() != null ? user.getCreatedAt().toString() : java.time.LocalDateTime.now().toString());

        var jwtToken = jwtUtils.generateToken(extraClaims, userDetails);
        
        return ResponseEntity.ok(AuthResponse.builder()
                .token(jwtToken)
                .build());
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@RequestBody AuthRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getEmail(),
                        request.getPassword()
                )
        );
        
        UserDetails userDetails = userDetailsService.loadUserByUsername(request.getEmail());
        User user = userRepository.findByEmail(request.getEmail()).orElseThrow();

        java.util.Map<String, Object> extraClaims = new java.util.HashMap<>();
        extraClaims.put("firstName", user.getFirstName());
        extraClaims.put("lastName", user.getLastName());
        extraClaims.put("createdAt", user.getCreatedAt() != null ? user.getCreatedAt().toString() : java.time.LocalDateTime.now().toString());

        var jwtToken = jwtUtils.generateToken(extraClaims, userDetails);
        
        return ResponseEntity.ok(AuthResponse.builder()
                .token(jwtToken)
                .build());
    }
}
