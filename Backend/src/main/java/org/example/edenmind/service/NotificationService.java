package org.example.edenmind.service;

import org.example.edenmind.entities.Notification;
import org.example.edenmind.entities.User;
import org.example.edenmind.repositories.NotificationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class NotificationService {

    @Autowired
    private NotificationRepository notificationRepository;

    /**
     * Create a notification for a user
     */
    public Notification createNotification(User user, String title, String message, String type) {
        Notification notification = new Notification(user, title, message, type);
        return notificationRepository.save(notification);
    }

    /**
     * Notification when user logs their mood
     */
    public void notifyMoodLogged(User user, String mood) {
        String title = "Mood Logged! 📝";
        String message = "Great job logging your mood as '" + mood + "'. Keep tracking to see patterns in your wellness journey.";
        createNotification(user, title, message, "achievement");
    }

    /**
     * Notification for daily reminder
     */
    public void sendDailyReminder(User user) {
        String title = "Daily Check-in 🌟";
        String message = "Don't forget to log your mood today! Taking a moment to reflect can help improve your mental wellness.";
        createNotification(user, title, message, "reminder");
    }

    /**
     * Notification when user completes a meditation
     */
    public void notifyMeditationCompleted(User user, String sessionName, int minutes) {
        String title = "Meditation Complete! 🧘";
        String message = "You completed a " + minutes + "-minute session of '" + sessionName + "'. Great work on prioritizing your mental health!";
        createNotification(user, title, message, "achievement");
    }

    /**
     * Notification when user starts their first chat
     */
    public void notifyFirstChat(User user) {
        String title = "Welcome to ZenBot! 💬";
        String message = "Great job starting your first conversation with ZenBot. Feel free to share your thoughts anytime.";
        createNotification(user, title, message, "tip");
    }

    /**
     * Notification for wellness tip
     */
    public void sendWellnessTip(User user, String tip) {
        String title = "Wellness Tip 💡";
        createNotification(user, title, tip, "tip");
    }

    /**
     * Notification when user plays a therapeutic game
     */
    public void notifyGamePlayed(User user, String gameName) {
        String title = "Game Completed! 🎮";
        String message = "You finished playing '" + gameName + "'. These exercises can help reduce stress and improve mindfulness.";
        createNotification(user, title, message, "achievement");
    }

    /**
     * Notification for streak achievement
     */
    public void notifyStreak(User user, int days) {
        String title = "🔥 " + days + "-Day Streak!";
        String message = "Amazing! You've been using EdenMind for " + days + " days in a row. Keep up the great work!";
        createNotification(user, title, message, "achievement");
    }

    /**
     * Notification for new feature update
     */
    public void notifyUpdate(User user, String feature) {
        String title = "New Feature! 🆕";
        String message = "Check out the new " + feature + " feature in EdenMind!";
        createNotification(user, title, message, "update");
    }
}
