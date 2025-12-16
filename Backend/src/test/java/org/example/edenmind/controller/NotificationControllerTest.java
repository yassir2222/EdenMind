package org.example.edenmind.controller;

import org.example.edenmind.entities.Notification;
import org.example.edenmind.entities.User;
import org.example.edenmind.repositories.NotificationRepository;
import org.example.edenmind.repositories.UserRepository;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class NotificationControllerTest {

    @Mock
    private NotificationRepository notificationRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private SecurityContext securityContext;

    @Mock
    private Authentication authentication;

    @InjectMocks
    private NotificationController notificationController;

    private User testUser;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);

        // Préparation de l'utilisateur de test
        testUser = new User();
        testUser.setId(1L);
        testUser.setEmail("test@example.com");

        // Configuration du Mock SecurityContext pour simuler un utilisateur connecté
        when(securityContext.getAuthentication()).thenReturn(authentication);
        SecurityContextHolder.setContext(securityContext);
    }

    @AfterEach
    void tearDown() {
        // Nettoyage du contexte de sécurité après chaque test
        SecurityContextHolder.clearContext();
    }

    // Méthode utilitaire pour simuler une connexion réussie
    private void mockAuthenticatedUser() {
        when(authentication.isAuthenticated()).thenReturn(true);
        when(authentication.getName()).thenReturn(testUser.getEmail());
        when(userRepository.findByEmail(testUser.getEmail())).thenReturn(Optional.of(testUser));
    }

    // --- Tests getNotifications ---

    @Test
    void testGetNotifications_Success() {
        mockAuthenticatedUser();
        List<Notification> notifications = Arrays.asList(new Notification(), new Notification());

        when(notificationRepository.findByUserIdOrderByCreatedAtDesc(testUser.getId()))
                .thenReturn(notifications);

        ResponseEntity<List<Notification>> response = notificationController.getNotifications();

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals(2, response.getBody().size());
    }

    @Test
    void testGetNotifications_Unauthorized() {
        // Cas où l'utilisateur n'est pas trouvé ou pas connecté
        when(authentication.isAuthenticated()).thenReturn(false);

        ResponseEntity<List<Notification>> response = notificationController.getNotifications();
        assertEquals(HttpStatus.UNAUTHORIZED, response.getStatusCode());
    }

    // --- Tests getUnreadCount ---

    @Test
    void testGetUnreadCount() {
        mockAuthenticatedUser();
        when(notificationRepository.countByUserIdAndIsReadFalse(testUser.getId())).thenReturn(5L);

        ResponseEntity<Map<String, Long>> response = notificationController.getUnreadCount();

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals(5L, response.getBody().get("count"));
    }

    // --- Tests markAsRead ---

    @Test
    void testMarkAsRead_Success() {
        mockAuthenticatedUser();
        Long notifId = 100L;
        Notification notification = new Notification();
        notification.setId(notifId);
        notification.setUser(testUser);
        notification.setRead(false);

        when(notificationRepository.findById(notifId)).thenReturn(Optional.of(notification));
        when(notificationRepository.save(any(Notification.class))).thenAnswer(i -> i.getArgument(0));

        ResponseEntity<Notification> response = notificationController.markAsRead(notifId);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertTrue(response.getBody().isRead());
        verify(notificationRepository).save(notification);
    }

    @Test
    void testMarkAsRead_NotFound() {
        mockAuthenticatedUser();
        when(notificationRepository.findById(99L)).thenReturn(Optional.empty());

        ResponseEntity<Notification> response = notificationController.markAsRead(99L);
        assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode());
    }

    @Test
    void testMarkAsRead_Forbidden() {
        mockAuthenticatedUser();
        User otherUser = new User();
        otherUser.setId(2L); // ID différent

        Notification notification = new Notification();
        notification.setId(100L);
        notification.setUser(otherUser); // Appartient à un autre utilisateur

        when(notificationRepository.findById(100L)).thenReturn(Optional.of(notification));

        ResponseEntity<Notification> response = notificationController.markAsRead(100L);
        assertEquals(HttpStatus.FORBIDDEN, response.getStatusCode());
    }

    // --- Tests markAllAsRead ---

    @Test
    void testMarkAllAsRead() {
        mockAuthenticatedUser();
        Notification n1 = new Notification(); n1.setRead(false);
        Notification n2 = new Notification(); n2.setRead(false);
        List<Notification> notifications = Arrays.asList(n1, n2);

        when(notificationRepository.findByUserIdOrderByCreatedAtDesc(testUser.getId()))
                .thenReturn(notifications);

        ResponseEntity<Map<String, String>> response = notificationController.markAllAsRead();

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals("All notifications marked as read", response.getBody().get("message"));

        // Vérifie que save a été appelé pour chaque notification
        verify(notificationRepository, times(2)).save(any(Notification.class));
        assertTrue(n1.isRead());
        assertTrue(n2.isRead());
    }

    // --- Tests deleteNotification ---

    @Test
    void testDeleteNotification_Success() {
        mockAuthenticatedUser();
        Notification notification = new Notification();
        notification.setId(100L);
        notification.setUser(testUser);

        when(notificationRepository.findById(100L)).thenReturn(Optional.of(notification));

        ResponseEntity<Void> response = notificationController.deleteNotification(100L);

        assertEquals(HttpStatus.NO_CONTENT, response.getStatusCode());
        verify(notificationRepository).delete(notification);
    }

    @Test
    void testDeleteNotification_Forbidden() {
        mockAuthenticatedUser();
        User otherUser = new User();
        otherUser.setId(2L);
        Notification notification = new Notification();
        notification.setId(100L);
        notification.setUser(otherUser);

        when(notificationRepository.findById(100L)).thenReturn(Optional.of(notification));

        ResponseEntity<Void> response = notificationController.deleteNotification(100L);
        assertEquals(HttpStatus.FORBIDDEN, response.getStatusCode());
        verify(notificationRepository, never()).delete(any());
    }

    // --- Tests clearAllNotifications ---

    @Test
    void testClearAllNotifications() {
        mockAuthenticatedUser();

        ResponseEntity<Map<String, String>> response = notificationController.clearAllNotifications();

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals("All notifications cleared", response.getBody().get("message"));
        verify(notificationRepository).deleteByUserId(testUser.getId());
    }

    // --- Tests createNotification ---

    @Test
    void testCreateNotification_Success() {
        mockAuthenticatedUser();
        Map<String, String> request = new HashMap<>();
        request.put("title", "New Title");
        request.put("message", "New Message");
        request.put("type", "info");

        when(notificationRepository.save(any(Notification.class))).thenAnswer(i -> i.getArgument(0));

        ResponseEntity<Notification> response = notificationController.createNotification(request);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals("New Title", response.getBody().getTitle());
        assertEquals("info", response.getBody().getType());
    }

    @Test
    void testCreateNotification_BadRequest() {
        mockAuthenticatedUser();
        Map<String, String> request = new HashMap<>();
        // Manque title et message

        ResponseEntity<Notification> response = notificationController.createNotification(request);
        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
    }

    // --- Tests initSampleNotifications ---

    @Test
    void testInitSamples_Created() {
        mockAuthenticatedUser();
        // Simule qu'il n'y a pas encore de notifications
        when(notificationRepository.findByUserIdOrderByCreatedAtDesc(testUser.getId()))
                .thenReturn(Collections.emptyList());

        ResponseEntity<Map<String, String>> response = notificationController.initSampleNotifications();

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals("Sample notifications created", response.getBody().get("message"));
        // Vérifie que 5 notifications ont été sauvegardées
        verify(notificationRepository, times(5)).save(any(Notification.class));
    }

    @Test
    void testInitSamples_AlreadyExists() {
        mockAuthenticatedUser();
        // Simule qu'il y a déjà des notifications
        when(notificationRepository.findByUserIdOrderByCreatedAtDesc(testUser.getId()))
                .thenReturn(Collections.singletonList(new Notification()));

        ResponseEntity<Map<String, String>> response = notificationController.initSampleNotifications();

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals("User already has notifications", response.getBody().get("message"));
        // Vérifie qu'aucune nouvelle sauvegarde n'a été faite
        verify(notificationRepository, never()).save(any(Notification.class));
    }
}