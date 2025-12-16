package org.example.edenmind.controller;

import org.example.edenmind.entities.Notification;
import org.example.edenmind.entities.User;
import org.example.edenmind.repositories.NotificationRepository;
import org.example.edenmind.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/notifications")
@CrossOrigin(origins = {"http://localhost:4200", "http://localhost:60826"})
public class NotificationController {

    @Autowired
    private NotificationRepository notificationRepository;

    @Autowired
    private UserRepository userRepository;

    private User getAuthenticatedUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            return null;
        }
        String email = authentication.getName();
        return userRepository.findByEmail(email).orElse(null);
    }

    /**
     * Get all notifications for the current user
     */
    @GetMapping
    public ResponseEntity<List<Notification>> getNotifications() {
        User user = getAuthenticatedUser();
        if (user == null) {
            return ResponseEntity.status(401).build();
        }
        
        List<Notification> notifications = notificationRepository.findByUserIdOrderByCreatedAtDesc(user.getId());
        return ResponseEntity.ok(notifications);
    }

    /**
     * Get unread notification count
     */
    @GetMapping("/unread-count")
    public ResponseEntity<Map<String, Long>> getUnreadCount() {
        User user = getAuthenticatedUser();
        if (user == null) {
            return ResponseEntity.status(401).build();
        }
        
        long count = notificationRepository.countByUserIdAndIsReadFalse(user.getId());
        Map<String, Long> response = new HashMap<>();
        response.put("count", count);
        return ResponseEntity.ok(response);
    }

    /**
     * Mark a notification as read
     */
    @PutMapping("/{id}/read")
    public ResponseEntity<Notification> markAsRead(@PathVariable Long id) {
        User user = getAuthenticatedUser();
        if (user == null) {
            return ResponseEntity.status(401).build();
        }

        Optional<Notification> notificationOpt = notificationRepository.findById(id);
        if (notificationOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Notification notification = notificationOpt.get();
        if (!notification.getUser().getId().equals(user.getId())) {
            return ResponseEntity.status(403).build();
        }

        notification.setRead(true);
        notificationRepository.save(notification);
        return ResponseEntity.ok(notification);
    }

    /**
     * Mark all notifications as read
     */
    @PutMapping("/read-all")
    public ResponseEntity<Map<String, String>> markAllAsRead() {
        User user = getAuthenticatedUser();
        if (user == null) {
            return ResponseEntity.status(401).build();
        }

        List<Notification> notifications = notificationRepository.findByUserIdOrderByCreatedAtDesc(user.getId());
        for (Notification notification : notifications) {
            notification.setRead(true);
            notificationRepository.save(notification);
        }

        Map<String, String> response = new HashMap<>();
        response.put("message", "All notifications marked as read");
        return ResponseEntity.ok(response);
    }

    /**
     * Delete a notification
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteNotification(@PathVariable Long id) {
        User user = getAuthenticatedUser();
        if (user == null) {
            return ResponseEntity.status(401).build();
        }

        Optional<Notification> notificationOpt = notificationRepository.findById(id);
        if (notificationOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Notification notification = notificationOpt.get();
        if (!notification.getUser().getId().equals(user.getId())) {
            return ResponseEntity.status(403).build();
        }

        notificationRepository.delete(notification);
        return ResponseEntity.noContent().build();
    }

    /**
     * Delete all notifications for the current user
     */
    @DeleteMapping("/clear-all")
    public ResponseEntity<Map<String, String>> clearAllNotifications() {
        User user = getAuthenticatedUser();
        if (user == null) {
            return ResponseEntity.status(401).build();
        }

        notificationRepository.deleteByUserId(user.getId());
        
        Map<String, String> response = new HashMap<>();
        response.put("message", "All notifications cleared");
        return ResponseEntity.ok(response);
    }

    /**
     * Create a notification (for testing or internal use)
     */
    @PostMapping
    public ResponseEntity<Notification> createNotification(@RequestBody Map<String, String> request) {
        User user = getAuthenticatedUser();
        if (user == null) {
            return ResponseEntity.status(401).build();
        }

        String title = request.get("title");
        String message = request.get("message");
        String type = request.getOrDefault("type", "tip");

        if (title == null || message == null) {
            return ResponseEntity.badRequest().build();
        }

        Notification notification = new Notification(user, title, message, type);
        notificationRepository.save(notification);
        
        return ResponseEntity.ok(notification);
    }

    /**
     * Create sample notifications for new users
     */
    @PostMapping("/init-samples")
    public ResponseEntity<Map<String, String>> initSampleNotifications() {
        User user = getAuthenticatedUser();
        if (user == null) {
            return ResponseEntity.status(401).build();
        }

        // Check if user already has notifications
        List<Notification> existing = notificationRepository.findByUserIdOrderByCreatedAtDesc(user.getId());
        if (!existing.isEmpty()) {
            Map<String, String> response = new HashMap<>();
            response.put("message", "User already has notifications");
            return ResponseEntity.ok(response);
        }

        // Create sample notifications
        Notification n1 = new Notification(user, "Welcome to EdenMind! 🎉", 
            "We're excited to have you join our wellness community. Start your journey to mental wellness today!", "achievement");
        
        Notification n2 = new Notification(user, "Daily Reminder",
            "Don't forget to log your mood today! Taking a moment to reflect can help improve your mental wellness.", "reminder");
        
        Notification n3 = new Notification(user, "Meditation Tip 🧘",
            "Try the new meditation tracks for a peaceful mind. Just 5 minutes a day can make a difference!", "meditation");
        
        Notification n4 = new Notification(user, "Wellness Tip 💡",
            "Taking short breaks during work can boost your productivity and reduce stress.", "tip");
        
        Notification n5 = new Notification(user, "New Games Available! 🎮",
            "Check out the therapeutic games section for fun stress-relief exercises!", "update");

        notificationRepository.save(n1);
        notificationRepository.save(n2);
        notificationRepository.save(n3);
        notificationRepository.save(n4);
        notificationRepository.save(n5);

        Map<String, String> response = new HashMap<>();
        response.put("message", "Sample notifications created");
        return ResponseEntity.ok(response);
    }
}
