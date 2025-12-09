package org.example.edenmind.service;

import org.example.edenmind.entities.EmotionLog;
import org.example.edenmind.entities.User;
import org.example.edenmind.repositories.EmotionLogRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.when;

class EmotionLogServiceTest {

    @Mock
    private EmotionLogRepository emotionLogRepository;

    @InjectMocks
    private EmotionLogService emotionLogService;

    @Mock
    private UserService userService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void testCreateEmotionLog() {
        EmotionLog log = new EmotionLog();
        log.setEmotionType("Happy");
        User user = new User();
        user.setId(1L);
        
        when(userService.getUserById(1L)).thenReturn(user);
        when(emotionLogRepository.save(log)).thenReturn(log);
        
        EmotionLog savedLog = emotionLogService.createEmotionLog(1L, log);
        assertEquals("Happy", savedLog.getEmotionType());
    }

    @Test
    void testGetUserEmotionLogs() {
        EmotionLog log1 = new EmotionLog();
        EmotionLog log2 = new EmotionLog();
        
        when(emotionLogRepository.findByUserIdOrderByRecordedAtDesc(1L))
                .thenReturn(Arrays.asList(log1, log2));
        
        List<EmotionLog> logs = emotionLogService.getUserEmotionLogs(1L);
        assertEquals(2, logs.size());
    }
}
