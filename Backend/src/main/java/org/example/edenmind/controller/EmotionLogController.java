package org.example.edenmind.controller;

import lombok.RequiredArgsConstructor;
import org.example.edenmind.entities.EmotionLog;
import org.example.edenmind.entities.User;
import org.example.edenmind.repositories.EmotionLogRepository;
import org.example.edenmind.repositories.UserRepository;
import org.example.edenmind.service.NotificationService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/emotions")
@RequiredArgsConstructor
public class EmotionLogController {

    private final EmotionLogRepository emotionLogRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;

    @PostMapping
    public ResponseEntity<?> createLog(@RequestBody Map<String, Object> request, @AuthenticationPrincipal UserDetails userDetails) {
        User user = userRepository.findByEmail(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found"));

        String emotionType = (String) request.get("emotionType");
        String activities = (String) request.get("activities");
        String note = (String) request.get("note");
        String source = (String) request.getOrDefault("source", "MANUAL");
        Double confidence = request.get("confidence") != null 
            ? ((Number) request.get("confidence")).doubleValue() 
            : null;

        EmotionLog log = new EmotionLog(user, emotionType, activities, note);
        log.setSource(source);
        log.setConfidence(confidence);
        emotionLogRepository.save(log);

        // Create notification for mood logging
        String notificationMessage = source.equals("FACE_ANALYSIS") 
            ? "Mood detected via camera: " + emotionType
            : emotionType;
        notificationService.notifyMoodLogged(user, notificationMessage);

        return ResponseEntity.ok().build();
    }

    @GetMapping
    public ResponseEntity<List<EmotionLog>> getLogs(@AuthenticationPrincipal UserDetails userDetails) {
        List<EmotionLog> logs = emotionLogRepository.findByUserEmailOrderByRecordedAtDesc(userDetails.getUsername());
        return ResponseEntity.ok(logs);
    }
}

