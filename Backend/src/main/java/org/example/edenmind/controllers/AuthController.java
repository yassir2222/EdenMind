package org.example.edenmind.controllers;

import org.example.edenmind.entities.User;
import org.example.edenmind.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        String password = request.get("password");
        String firstName = request.get("firstName");
        String lastName = request.get("lastName");

        if (userRepository.findByEmail(email).isPresent()) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body("Email already in use");
        }

        User user = new User(email, passwordEncoder.encode(password), firstName, lastName);
        userRepository.save(user);

        return ResponseEntity.status(HttpStatus.CREATED).body(user);
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        String password = request.get("password");

        Optional<User> userOpt = userRepository.findByEmail(email);

        if (userOpt.isPresent()) {
            User user = userOpt.get();
            if (passwordEncoder.matches(password, user.getPassword())) {
                return ResponseEntity.ok(user);
            }
        }

        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid credentials");
    }
}
