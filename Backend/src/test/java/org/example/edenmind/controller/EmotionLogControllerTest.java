package org.example.edenmind.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.example.edenmind.entities.EmotionLog;
import org.example.edenmind.entities.User;
import org.example.edenmind.repositories.EmotionLogRepository;
import org.example.edenmind.repositories.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.http.MediaType;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import org.springframework.core.MethodParameter;
import org.springframework.web.bind.support.WebDataBinderFactory;
import org.springframework.web.context.request.NativeWebRequest;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.method.support.ModelAndViewContainer;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

public class EmotionLogControllerTest {

    private MockMvc mockMvc;

    @Mock
    private EmotionLogRepository emotionLogRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private org.example.edenmind.service.NotificationService notificationService;

    @InjectMocks
    private EmotionLogController emotionLogController;

    private ObjectMapper objectMapper = new ObjectMapper();

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        
        UserDetails userDetails = org.springframework.security.core.userdetails.User.builder()
                .username("test@example.com")
                .password("password")
                .authorities("USER")
                .build();
        
        HandlerMethodArgumentResolver putPrincipal = new HandlerMethodArgumentResolver() {
            @Override
            public boolean supportsParameter(MethodParameter parameter) {
                return parameter.getParameterType().isAssignableFrom(UserDetails.class);
            }

            @Override
            public Object resolveArgument(MethodParameter parameter, ModelAndViewContainer mavContainer, NativeWebRequest webRequest, WebDataBinderFactory binderFactory) {
                return userDetails;
            }
        };

        mockMvc = MockMvcBuilders.standaloneSetup(emotionLogController)
                .setCustomArgumentResolvers(putPrincipal)
                .build();
    }

    @Test
    void testCreateLog() throws Exception {
        Map<String, Object> request = new HashMap<>();
        request.put("emotionType", "Happy");
        request.put("activities", "Coding");
        request.put("note", "Great progress");
        
        User user = new User();
        user.setEmail("test@example.com");
        
        when(userRepository.findByEmail("test@example.com")).thenReturn(Optional.of(user));
        when(emotionLogRepository.save(any(EmotionLog.class))).thenAnswer(i -> i.getArgument(0));

        mockMvc.perform(post("/api/emotions")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk());
    }

    @Test
    void testGetLogs() throws Exception {
        when(emotionLogRepository.findByUserEmailOrderByRecordedAtDesc("test@example.com"))
                .thenReturn(Collections.emptyList());

        mockMvc.perform(get("/api/emotions"))
                .andExpect(status().isOk());
    }
}
