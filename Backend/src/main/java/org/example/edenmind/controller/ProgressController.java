package org.example.edenmind.controller;

import org.example.edenmind.entities.User;
import org.example.edenmind.repositories.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/progress")
@CrossOrigin(origins = "*")
public class ProgressController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private EmotionLogRepository emotionLogRepository;

    @Autowired
    private ConversationRepository conversationRepository;

    @Autowired
    private MessageRepository messageRepository;

    @Autowired
    private NotificationRepository notificationRepository;

    private User getAuthenticatedUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            return null;
        }
        String email = authentication.getName();
        return userRepository.findByEmail(email).orElse(null);
    }

    @GetMapping
    public ResponseEntity<Map<String, Object>> getProgress() {
        User user = getAuthenticatedUser();
        if (user == null) {
            return ResponseEntity.status(401).build();
        }

        Map<String, Object> progress = new HashMap<>();

        // User info
        progress.put("userId", user.getId());
        progress.put("userName", user.getFirstName() + " " + user.getLastName());
        progress.put("memberSince", user.getCreatedAt());

        // Mood logs statistics
        long totalMoodLogs = emotionLogRepository.countByUserEmail(user.getEmail());
        progress.put("totalMoodLogs", totalMoodLogs);

        // Calculate mood logging streak (simplified version)
        int moodStreak = calculateMoodStreak(user.getEmail());
        progress.put("moodStreak", moodStreak);

        // Conversations and messages
        long totalConversations = conversationRepository.countByUserId(user.getId());
        long totalMessages = messageRepository.countByConversationUserId(user.getId());
        progress.put("totalConversations", totalConversations);
        progress.put("totalMessages", totalMessages);

        // Days since registration
        long daysSinceRegistration = 0;
        if (user.getCreatedAt() != null) {
            daysSinceRegistration = java.time.temporal.ChronoUnit.DAYS.between(
                user.getCreatedAt().toLocalDate(), 
                LocalDate.now()
            );
        }
        progress.put("daysSinceRegistration", daysSinceRegistration);

        // Calculate wellness score (0-100)
        int wellnessScore = calculateWellnessScore(totalMoodLogs, totalConversations, moodStreak, daysSinceRegistration);
        progress.put("wellnessScore", wellnessScore);

        // Achievements
        progress.put("achievements", calculateAchievements(totalMoodLogs, totalConversations, moodStreak));

        return ResponseEntity.ok(progress);
    }

    private int calculateMoodStreak(String email) {
        // Simplified streak calculation
        // In production, you'd check consecutive days with mood logs
        long moodLogs = emotionLogRepository.countByUserEmail(email);
        if (moodLogs == 0) return 0;
        if (moodLogs >= 30) return 30;
        if (moodLogs >= 14) return 14;
        if (moodLogs >= 7) return 7;
        return (int) Math.min(moodLogs, 7);
    }

    private int calculateWellnessScore(long moodLogs, long conversations, int streak, long days) {
        // Score based on activity
        int score = 0;
        
        // Mood logging frequency (max 40 points)
        if (days > 0) {
            double moodFrequency = (double) moodLogs / days;
            score += Math.min(40, (int) (moodFrequency * 40));
        }
        
        // Streak bonus (max 20 points)
        score += Math.min(20, streak * 3);
        
        // Conversations (max 20 points)
        score += Math.min(20, (int) conversations * 2);
        
        // Base engagement score (max 20 points)
        score += Math.min(20, (int) (moodLogs + conversations) / 2);
        
        return Math.min(100, score);
    }

    private Map<String, Object>[] calculateAchievements(long moodLogs, long conversations, int streak) {
        java.util.List<Map<String, Object>> achievements = new java.util.ArrayList<>();

        // First Mood Log
        if (moodLogs >= 1) {
            achievements.add(createAchievement("First Step", "Logged your first mood", "🌱", true));
        } else {
            achievements.add(createAchievement("First Step", "Log your first mood", "🌱", false));
        }

        // 7 Mood Logs
        if (moodLogs >= 7) {
            achievements.add(createAchievement("Week Warrior", "7 mood logs recorded", "🎯", true));
        } else {
            achievements.add(createAchievement("Week Warrior", "Log 7 moods", "🎯", false));
        }

        // 30 Mood Logs
        if (moodLogs >= 30) {
            achievements.add(createAchievement("Monthly Master", "30 mood logs recorded", "🏆", true));
        } else {
            achievements.add(createAchievement("Monthly Master", "Log 30 moods", "🏆", false));
        }

        // First Chat
        if (conversations >= 1) {
            achievements.add(createAchievement("Conversation Starter", "Started your first chat", "💬", true));
        } else {
            achievements.add(createAchievement("Conversation Starter", "Start a chat with ZenBot", "💬", false));
        }

        // 10 Conversations
        if (conversations >= 10) {
            achievements.add(createAchievement("Regular Talker", "10 conversations completed", "🗣️", true));
        } else {
            achievements.add(createAchievement("Regular Talker", "Have 10 conversations", "🗣️", false));
        }

        // 7 Day Streak
        if (streak >= 7) {
            achievements.add(createAchievement("Week Streak", "7 day logging streak", "🔥", true));
        } else {
            achievements.add(createAchievement("Week Streak", "Maintain a 7 day streak", "🔥", false));
        }

        return achievements.toArray(new Map[0]);
    }

    private Map<String, Object> createAchievement(String name, String description, String icon, boolean unlocked) {
        Map<String, Object> achievement = new HashMap<>();
        achievement.put("name", name);
        achievement.put("description", description);
        achievement.put("icon", icon);
        achievement.put("unlocked", unlocked);
        return achievement;
    }
}
