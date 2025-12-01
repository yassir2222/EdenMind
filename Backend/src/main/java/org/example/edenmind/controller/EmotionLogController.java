package org.example.edenmind.controller;

import lombok.RequiredArgsConstructor;
import org.example.edenmind.entities.EmotionLog;
import org.example.edenmind.entities.User;
import org.example.edenmind.repositories.EmotionLogRepository;
import org.example.edenmind.repositories.UserRepository;
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

    @PostMapping
    public ResponseEntity<?> createLog(@RequestBody Map<String, Object> request, @AuthenticationPrincipal UserDetails userDetails) {
        User user = userRepository.findByEmail(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found"));

        String emotionType = (String) request.get("emotionType");
        String activities = (String) request.get("activities");
        String note = (String) request.get("note");

        EmotionLog log = new EmotionLog(user, emotionType, activities, note);
        emotionLogRepository.save(log);

        return ResponseEntity.ok().build();
    }

    @GetMapping
    public ResponseEntity<List<EmotionLog>> getLogs(@AuthenticationPrincipal UserDetails userDetails) {
        List<EmotionLog> logs = emotionLogRepository.findByUserEmailOrderByRecordedAtDesc(userDetails.getUsername());
        return ResponseEntity.ok(logs);
    }
}
