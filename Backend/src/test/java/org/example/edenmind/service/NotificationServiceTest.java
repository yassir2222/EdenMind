package org.example.edenmind.service;

import org.example.edenmind.entities.Notification;
import org.example.edenmind.entities.User;
import org.example.edenmind.repositories.NotificationRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class NotificationServiceTest {

    @Mock
    private NotificationRepository notificationRepository;

    @InjectMocks
    private NotificationService notificationService;

    // Un objet User réutilisable pour les tests
    private User testUser;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        testUser = new User();
        testUser.setId(1L);
        testUser.setFirstName("Test");
    }

    @Test
    void testCreateNotification() {
        // Arrange
        String title = "Test Title";
        String message = "Test Message";
        String type = "info";

        when(notificationRepository.save(any(Notification.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // Act
        Notification result = notificationService.createNotification(testUser, title, message, type);

        // Assert
        assertNotNull(result);
        assertEquals(testUser, result.getUser());
        assertEquals(title, result.getTitle());
        assertEquals(message, result.getMessage());
        assertEquals(type, result.getType());
        assertFalse(result.isRead()); // Par défaut false

        verify(notificationRepository, times(1)).save(any(Notification.class));
    }

    @Test
    void testNotifyMoodLogged() {
        // Arrange
        String mood = "Happy";
        ArgumentCaptor<Notification> notificationCaptor = ArgumentCaptor.forClass(Notification.class);
        when(notificationRepository.save(any(Notification.class))).thenReturn(new Notification());

        // Act
        notificationService.notifyMoodLogged(testUser, mood);

        // Assert
        verify(notificationRepository).save(notificationCaptor.capture());
        Notification captured = notificationCaptor.getValue();

        assertEquals("Mood Logged! 📝", captured.getTitle());
        assertTrue(captured.getMessage().contains(mood)); // Vérifie que l'humeur est dans le message
        assertEquals("achievement", captured.getType());
        assertEquals(testUser, captured.getUser());
    }

    @Test
    void testSendDailyReminder() {
        // Arrange
        ArgumentCaptor<Notification> notificationCaptor = ArgumentCaptor.forClass(Notification.class);
        when(notificationRepository.save(any(Notification.class))).thenReturn(new Notification());

        // Act
        notificationService.sendDailyReminder(testUser);

        // Assert
        verify(notificationRepository).save(notificationCaptor.capture());
        Notification captured = notificationCaptor.getValue();

        assertEquals("Daily Check-in 🌟", captured.getTitle());
        assertTrue(captured.getMessage().contains("log your mood"));
        assertEquals("reminder", captured.getType());
    }

    @Test
    void testNotifyMeditationCompleted() {
        // Arrange
        String sessionName = "Deep Sleep";
        int minutes = 15;
        ArgumentCaptor<Notification> notificationCaptor = ArgumentCaptor.forClass(Notification.class);
        when(notificationRepository.save(any(Notification.class))).thenReturn(new Notification());

        // Act
        notificationService.notifyMeditationCompleted(testUser, sessionName, minutes);

        // Assert
        verify(notificationRepository).save(notificationCaptor.capture());
        Notification captured = notificationCaptor.getValue();

        assertEquals("Meditation Complete! 🧘", captured.getTitle());
        assertTrue(captured.getMessage().contains("15-minute"));
        assertTrue(captured.getMessage().contains("Deep Sleep"));
        assertEquals("achievement", captured.getType());
    }

    @Test
    void testNotifyFirstChat() {
        // Arrange
        ArgumentCaptor<Notification> notificationCaptor = ArgumentCaptor.forClass(Notification.class);
        when(notificationRepository.save(any(Notification.class))).thenReturn(new Notification());

        // Act
        notificationService.notifyFirstChat(testUser);

        // Assert
        verify(notificationRepository).save(notificationCaptor.capture());
        Notification captured = notificationCaptor.getValue();

        assertEquals("Welcome to ZenBot! 💬", captured.getTitle());
        assertEquals("tip", captured.getType());
    }

    @Test
    void testSendWellnessTip() {
        // Arrange
        String tip = "Drink more water.";
        ArgumentCaptor<Notification> notificationCaptor = ArgumentCaptor.forClass(Notification.class);
        when(notificationRepository.save(any(Notification.class))).thenReturn(new Notification());

        // Act
        notificationService.sendWellnessTip(testUser, tip);

        // Assert
        verify(notificationRepository).save(notificationCaptor.capture());
        Notification captured = notificationCaptor.getValue();

        assertEquals("Wellness Tip 💡", captured.getTitle());
        assertEquals(tip, captured.getMessage());
        assertEquals("tip", captured.getType());
    }

    @Test
    void testNotifyGamePlayed() {
        // Arrange
        String gameName = "Stress Buster";
        ArgumentCaptor<Notification> notificationCaptor = ArgumentCaptor.forClass(Notification.class);
        when(notificationRepository.save(any(Notification.class))).thenReturn(new Notification());

        // Act
        notificationService.notifyGamePlayed(testUser, gameName);

        // Assert
        verify(notificationRepository).save(notificationCaptor.capture());
        Notification captured = notificationCaptor.getValue();

        assertEquals("Game Completed! 🎮", captured.getTitle());
        assertTrue(captured.getMessage().contains(gameName));
        assertEquals("achievement", captured.getType());
    }

    @Test
    void testNotifyStreak() {
        // Arrange
        int days = 7;
        ArgumentCaptor<Notification> notificationCaptor = ArgumentCaptor.forClass(Notification.class);
        when(notificationRepository.save(any(Notification.class))).thenReturn(new Notification());

        // Act
        notificationService.notifyStreak(testUser, days);

        // Assert
        verify(notificationRepository).save(notificationCaptor.capture());
        Notification captured = notificationCaptor.getValue();

        assertEquals("🔥 7-Day Streak!", captured.getTitle());
        assertTrue(captured.getMessage().contains("7 days"));
        assertEquals("achievement", captured.getType());
    }

    @Test
    void testNotifyUpdate() {
        // Arrange
        String feature = "Dark Mode";
        ArgumentCaptor<Notification> notificationCaptor = ArgumentCaptor.forClass(Notification.class);
        when(notificationRepository.save(any(Notification.class))).thenReturn(new Notification());

        // Act
        notificationService.notifyUpdate(testUser, feature);

        // Assert
        verify(notificationRepository).save(notificationCaptor.capture());
        Notification captured = notificationCaptor.getValue();

        assertEquals("New Feature! 🆕", captured.getTitle());
        assertTrue(captured.getMessage().contains(feature));
        assertEquals("update", captured.getType());
    }
}