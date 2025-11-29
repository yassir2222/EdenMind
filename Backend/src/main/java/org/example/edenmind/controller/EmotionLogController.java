package org.example.edenmind.controller;

import org.example.edenmind.entities.EmotionLog;
import org.example.edenmind.service.EmotionLogService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Controller REST pour gérer les journaux d'émotions
 * Toutes les routes commencent par /api/emotions
 */
@RestController
@RequestMapping("/api/emotions")
public class EmotionLogController {

    @Autowired
    private EmotionLogService emotionLogService;

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<EmotionLog>> getUserEmotionLogs(@PathVariable Long userId) {
        List<EmotionLog> emotions = emotionLogService.getUserEmotionLogs(userId);
        return ResponseEntity.ok(emotions);
    }


    @GetMapping("/{id}")
    public ResponseEntity<EmotionLog> getEmotionLogById(@PathVariable Long id) {
        EmotionLog emotion = emotionLogService.getEmotionLogById(id);
        return ResponseEntity.ok(emotion);
    }


    @PostMapping("/user/{userId}")
    public ResponseEntity<EmotionLog> createEmotionLog(
            @PathVariable Long userId,
            @RequestBody EmotionLog emotionLog) {

        EmotionLog createdEmotion = emotionLogService.createEmotionLog(userId, emotionLog);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdEmotion);
    }


    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteEmotionLog(@PathVariable Long id) {
        emotionLogService.deleteEmotionLog(id);
        return ResponseEntity.noContent().build();
    }


    @GetMapping("/user/{userId}/range")
    public ResponseEntity<List<EmotionLog>> getEmotionLogsByDateRange(
            @PathVariable Long userId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime start,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime end) {

        List<EmotionLog> emotions = emotionLogService.getEmotionLogsByDateRange(userId, start, end);
        return ResponseEntity.ok(emotions);
    }


    @GetMapping("/user/{userId}/type/{emotionType}")
    public ResponseEntity<List<EmotionLog>> getEmotionLogsByType(
            @PathVariable Long userId,
            @PathVariable String emotionType) {

        List<EmotionLog> emotions = emotionLogService.getEmotionLogsByType(userId, emotionType);
        return ResponseEntity.ok(emotions);
    }
}
