package org.example.edenmind.service;

import org.example.edenmind.entities.EmotionLog;
import org.example.edenmind.entities.User;
import org.example.edenmind.repositories.EmotionLogRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class EmotionLogServiceTest {

    @Mock
    private EmotionLogRepository emotionLogRepository;

    @Mock
    private UserService userService;

    @InjectMocks
    private EmotionLogService emotionLogService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void testGetUserEmotionLogs() {
        // Arrange
        Long userId = 1L;
        EmotionLog log1 = new EmotionLog();
        EmotionLog log2 = new EmotionLog();

        when(emotionLogRepository.findByUserIdOrderByRecordedAtDesc(userId))
                .thenReturn(Arrays.asList(log1, log2));

        // Act
        List<EmotionLog> logs = emotionLogService.getUserEmotionLogs(userId);

        // Assert
        assertEquals(2, logs.size());
        verify(emotionLogRepository, times(1)).findByUserIdOrderByRecordedAtDesc(userId);
    }

    @Test
    void testGetEmotionLogById_Success() {
        // Arrange
        Long logId = 1L;
        EmotionLog log = new EmotionLog();
        log.setId(logId);

        when(emotionLogRepository.findById(logId)).thenReturn(Optional.of(log));

        // Act
        EmotionLog result = emotionLogService.getEmotionLogById(logId);

        // Assert
        assertNotNull(result);
        assertEquals(logId, result.getId());
    }

    @Test
    void testGetEmotionLogById_NotFound() {
        // Arrange
        Long logId = 99L;
        when(emotionLogRepository.findById(logId)).thenReturn(Optional.empty());

        // Act & Assert
        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            emotionLogService.getEmotionLogById(logId);
        });

        assertEquals("Émotion non trouvée avec l'id: " + logId, exception.getMessage());
    }

    @Test
    void testCreateEmotionLog() {
        // Arrange
        Long userId = 1L;
        EmotionLog logToCreate = new EmotionLog();
        logToCreate.setEmotionType("Happy");

        User user = new User();
        user.setId(userId);

        when(userService.getUserById(userId)).thenReturn(user);
        when(emotionLogRepository.save(any(EmotionLog.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // Act
        EmotionLog savedLog = emotionLogService.createEmotionLog(userId, logToCreate);

        // Assert
        assertNotNull(savedLog);
        assertEquals("Happy", savedLog.getEmotionType());
        assertEquals(user, savedLog.getUser()); // Vérifie que l'utilisateur a bien été associé

        verify(userService, times(1)).getUserById(userId);
        verify(emotionLogRepository, times(1)).save(logToCreate);
    }

    @Test
    void testDeleteEmotionLog() {
        // Arrange
        Long logId = 1L;
        EmotionLog log = new EmotionLog();
        log.setId(logId);

        // Il faut mocker le findById car deleteEmotionLog appelle getEmotionLogById avant de supprimer
        when(emotionLogRepository.findById(logId)).thenReturn(Optional.of(log));
        doNothing().when(emotionLogRepository).delete(log);

        // Act
        emotionLogService.deleteEmotionLog(logId);

        // Assert
        verify(emotionLogRepository, times(1)).findById(logId);
        verify(emotionLogRepository, times(1)).delete(log);
    }

    @Test
    void testGetEmotionLogsByDateRange() {
        // Arrange
        Long userId = 1L;
        LocalDateTime start = LocalDateTime.now().minusDays(7);
        LocalDateTime end = LocalDateTime.now();

        EmotionLog log = new EmotionLog();
        when(emotionLogRepository.findByUserIdAndRecordedAtBetween(userId, start, end))
                .thenReturn(Collections.singletonList(log));

        // Act
        List<EmotionLog> results = emotionLogService.getEmotionLogsByDateRange(userId, start, end);

        // Assert
        assertEquals(1, results.size());
        verify(emotionLogRepository, times(1)).findByUserIdAndRecordedAtBetween(userId, start, end);
    }

    @Test
    void testGetEmotionLogsByType() {
        // Arrange
        Long userId = 1L;
        String type = "Sad";
        EmotionLog log = new EmotionLog();
        log.setEmotionType(type);

        when(emotionLogRepository.findByUserIdAndEmotionType(userId, type))
                .thenReturn(Collections.singletonList(log));

        // Act
        List<EmotionLog> results = emotionLogService.getEmotionLogsByType(userId, type);

        // Assert
        assertEquals(1, results.size());
        assertEquals(type, results.get(0).getEmotionType());
        verify(emotionLogRepository, times(1)).findByUserIdAndEmotionType(userId, type);
    }
}