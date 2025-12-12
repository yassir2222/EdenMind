package org.example.edenmind.repositories;

import org.example.edenmind.entities.EmotionLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface EmotionLogRepository extends JpaRepository<EmotionLog, Long> {
    List<EmotionLog> findByUserEmailOrderByRecordedAtDesc(String email);
    List<EmotionLog> findByUserIdOrderByRecordedAtDesc(Long userId);
    List<EmotionLog> findByUserIdAndRecordedAtBetween(Long userId, LocalDateTime start, LocalDateTime end);
    List<EmotionLog> findByUserIdAndEmotionType(Long userId, String emotionType);
    long countByUserEmail(String email);
}

