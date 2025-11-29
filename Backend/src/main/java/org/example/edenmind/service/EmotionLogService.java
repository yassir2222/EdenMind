package org.example.edenmind.service;

import org.example.edenmind.entities.EmotionLog;
import org.example.edenmind.entities.User;
import org.example.edenmind.repositories.EmotionLogRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class EmotionLogService {

    @Autowired
    private EmotionLogRepository emotionLogRepository;

    @Autowired
    private UserService userService;


    public List<EmotionLog> getUserEmotionLogs(Long userId) {
        return emotionLogRepository.findByUserIdOrderByRecordedAtDesc(userId);
    }


    public EmotionLog getEmotionLogById(Long id) {
        return emotionLogRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Émotion non trouvée avec l'id: " + id));
    }


    public EmotionLog createEmotionLog(Long userId, EmotionLog emotionLog) {
        User user = userService.getUserById(userId);

        emotionLog.setUser(user);

        return emotionLogRepository.save(emotionLog);
    }

    public void deleteEmotionLog(Long id) {
        EmotionLog emotionLog = getEmotionLogById(id);
        emotionLogRepository.delete(emotionLog);
    }

    public List<EmotionLog> getEmotionLogsByDateRange(Long userId, LocalDateTime start, LocalDateTime end) {
        return emotionLogRepository.findByUserIdAndRecordedAtBetween(userId, start, end);
    }


    public List<EmotionLog> getEmotionLogsByType(Long userId, String emotionType) {
        return emotionLogRepository.findByUserIdAndEmotionType(userId, emotionType);
    }
}