package org.example.edenmind.integration;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.example.edenmind.dto.AuthRequest;
import org.example.edenmind.dto.RegisterRequest;
import org.example.edenmind.repositories.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.junit.jupiter.api.Assertions.assertTrue;

@ExtendWith(SpringExtension.class)
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
public class AuthIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private org.example.edenmind.repositories.EmotionLogRepository emotionLogRepository;

    @Autowired
    private org.example.edenmind.repositories.NotificationRepository notificationRepository;

    @Autowired
    private org.example.edenmind.repositories.ConversationRepository conversationRepository;

    @Autowired
    private org.example.edenmind.repositories.MessageRepository messageRepository;

    @BeforeEach
    void setUp() {
        messageRepository.deleteAll();
        conversationRepository.deleteAll();
        notificationRepository.deleteAll();
        emotionLogRepository.deleteAll();
        userRepository.deleteAll();
    }

    @Test
    void testRegisterAndLoginFlow() throws Exception {
        // 1. Register a new user
        RegisterRequest registerRequest = new RegisterRequest();
        registerRequest.setEmail("integration@test.com");
        registerRequest.setPassword("securepass");
        registerRequest.setFirstName("Int");
        registerRequest.setLastName("User");

        mockMvc.perform(post("/api/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(registerRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.token").exists());

        // Verify user is in DB
        assertTrue(userRepository.findByEmail("integration@test.com").isPresent());

        // 2. Login with the registered user
        AuthRequest loginRequest = new AuthRequest();
        loginRequest.setEmail("integration@test.com");
        loginRequest.setPassword("securepass");

        mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.token").exists());
    }

    @Test
    void testLoginWithInvalidCredentials() throws Exception {
        AuthRequest loginRequest = new AuthRequest();
        loginRequest.setEmail("nonexistent@test.com");
        loginRequest.setPassword("wrongpass");

        mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isUnauthorized()); // Or Unauthorized depending on your specific implementation
    }

    @Test
    void testFullUserJourney() throws Exception {
        // 1. Register
        RegisterRequest registerRequest = new RegisterRequest();
        registerRequest.setEmail("journey@test.com");
        registerRequest.setPassword("password123");
        registerRequest.setFirstName("Journey");
        registerRequest.setLastName("User");

        mockMvc.perform(post("/api/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(registerRequest)))
                .andExpect(status().isOk());

        // 2. Login
        AuthRequest loginRequest = new AuthRequest();
        loginRequest.setEmail("journey@test.com");
        loginRequest.setPassword("password123");

        String responseContent = mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();

        String token = com.jayway.jsonpath.JsonPath.read(responseContent, "$.token");
        String bearerToken = "Bearer " + token;

        // Retrieving user ID to update profile
        org.example.edenmind.entities.User user = userRepository.findByEmail("journey@test.com").orElseThrow();
        Long userId = user.getId();

        // 3. Update Profile (e.g. update family situation)
        user.setFamilySituation("Married");
        
        mockMvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put("/api/users/" + userId)
                .header("Authorization", bearerToken)
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(user)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.familySituation").value("Married"));

        // 4. Create Emotion Log
        java.util.Map<String, Object> emotionLog = new java.util.HashMap<>();
        emotionLog.put("emotionType", "Happy");
        emotionLog.put("activities", "Coding, Testing");
        emotionLog.put("note", "Integration tests are fun!");
        emotionLog.put("confidence", 0.95);

        mockMvc.perform(post("/api/emotions")
                .header("Authorization", bearerToken)
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(emotionLog)))
                .andExpect(status().isOk());

        // 5. Fetch Logs to verify
        mockMvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get("/api/emotions")
                .header("Authorization", bearerToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$[0].emotionType").value("Happy"))
                .andExpect(jsonPath("$[0].note").value("Integration tests are fun!"));
    }
}
