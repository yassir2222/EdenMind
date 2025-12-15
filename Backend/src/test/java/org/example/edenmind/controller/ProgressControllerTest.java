package org.example.edenmind.controller;
import org.example.edenmind.entities.User;
import org.example.edenmind.repositories.ConversationRepository;
import org.example.edenmind.repositories.EmotionLogRepository;
import org.example.edenmind.repositories.MessageRepository;
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

import java.time.LocalDateTime;
import java.util.Map;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.when;

class ProgressControllerTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private EmotionLogRepository emotionLogRepository;

    @Mock
    private ConversationRepository conversationRepository;

    @Mock
    private MessageRepository messageRepository;

    // Bien que non utilisé explicitement dans le code métier fourni,
    // il est autowired, donc on le mock pour éviter les NullPointerException si le code évolue
    @Mock
    private NotificationRepository notificationRepository;

    @Mock
    private SecurityContext securityContext;

    @Mock
    private Authentication authentication;

    @InjectMocks
    private ProgressController progressController;

    private User testUser;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);

        testUser = new User();
        testUser.setId(1L);
        testUser.setEmail("test@example.com");
        testUser.setFirstName("John");
        testUser.setLastName("Doe");
        testUser.setCreatedAt(LocalDateTime.now().minusDays(10)); // Membre depuis 10 jours

        // Configuration du contexte de sécurité mocké
        when(securityContext.getAuthentication()).thenReturn(authentication);
        SecurityContextHolder.setContext(securityContext);
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    private void mockAuthenticatedUser() {
        when(authentication.isAuthenticated()).thenReturn(true);
        when(authentication.getName()).thenReturn(testUser.getEmail());
        when(userRepository.findByEmail(testUser.getEmail())).thenReturn(Optional.of(testUser));
    }

    @Test
    void testGetProgress_Unauthorized() {
        when(authentication.isAuthenticated()).thenReturn(false);

        ResponseEntity<Map<String, Object>> response = progressController.getProgress();

        assertEquals(HttpStatus.UNAUTHORIZED, response.getStatusCode());
    }

    @Test
    void testGetProgress_NewUser_NoActivity() {
        // Scénario : Nouvel utilisateur sans aucune activité
        mockAuthenticatedUser();

        // Mocks retournant 0
        when(emotionLogRepository.countByUserEmail(testUser.getEmail())).thenReturn(0L);
        when(conversationRepository.countByUserId(testUser.getId())).thenReturn(0L);
        when(messageRepository.countByConversationUserId(testUser.getId())).thenReturn(0L);

        // Act
        ResponseEntity<Map<String, Object>> response = progressController.getProgress();
        Map<String, Object> body = response.getBody();

        // Assert
        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(body);

        assertEquals(1L, body.get("userId"));
        assertEquals("John Doe", body.get("userName"));
        assertEquals(0L, body.get("totalMoodLogs"));
        assertEquals(0, body.get("moodStreak"));
        assertEquals(0, body.get("wellnessScore")); // Score attendu à 0

        // Vérification des Achievements (tous verrouillés)
        Map<String, Object>[] achievements = (Map<String, Object>[]) body.get("achievements");
        for (Map<String, Object> achievement : achievements) {
            assertFalse((Boolean) achievement.get("unlocked"), "Achievement " + achievement.get("name") + " should be locked");
        }
    }

    @Test
    void testGetProgress_ActiveUser_HighStats() {
        // Scénario : Utilisateur très actif (30+ logs, 10+ conversations)
        mockAuthenticatedUser();

        when(emotionLogRepository.countByUserEmail(testUser.getEmail())).thenReturn(35L);
        when(conversationRepository.countByUserId(testUser.getId())).thenReturn(15L);
        when(messageRepository.countByConversationUserId(testUser.getId())).thenReturn(100L);

        // Act
        ResponseEntity<Map<String, Object>> response = progressController.getProgress();
        Map<String, Object> body = response.getBody();

        // Assert
        assertEquals(HttpStatus.OK, response.getStatusCode());

        assertEquals(35L, body.get("totalMoodLogs"));
        assertEquals(15L, body.get("totalConversations"));
        assertEquals(30, body.get("moodStreak")); // Max logique défini dans calculateMoodStreak pour > 30 logs

        // Vérification du Wellness Score (devrait être élevé)
        int score = (int) body.get("wellnessScore");
        assertTrue(score > 50, "Wellness score should be high for active user");

        // Vérification des Achievements (tous déverrouillés)
        Map<String, Object>[] achievements = (Map<String, Object>[]) body.get("achievements");
        for (Map<String, Object> achievement : achievements) {
            assertTrue((Boolean) achievement.get("unlocked"), "Achievement " + achievement.get("name") + " should be unlocked");
        }
    }

    @Test
    void testGetProgress_IntermediateUser() {
        // Scénario : Utilisateur intermédiaire (8 logs, 5 conversations)
        // Teste spécifiquement la logique "Week Warrior" et "Streak = 7"
        mockAuthenticatedUser();

        when(emotionLogRepository.countByUserEmail(testUser.getEmail())).thenReturn(8L);
        when(conversationRepository.countByUserId(testUser.getId())).thenReturn(5L);

        // Act
        ResponseEntity<Map<String, Object>> response = progressController.getProgress();
        Map<String, Object> body = response.getBody();

        // Assert
        assertEquals(8L, body.get("totalMoodLogs"));
        assertEquals(7, body.get("moodStreak")); // Logique interne : 8 logs -> retourne 7 (car >=7 mais <14)

        // Vérification spécifique des achievements
        Map<String, Object>[] achievements = (Map<String, Object>[]) body.get("achievements");

        // Helper pour trouver un achievement par nom
        boolean weekWarriorUnlocked = isAchievementUnlocked(achievements, "Week Warrior");
        boolean conversationStarterUnlocked = isAchievementUnlocked(achievements, "Conversation Starter");
        boolean monthlyMasterUnlocked = isAchievementUnlocked(achievements, "Monthly Master");

        assertTrue(weekWarriorUnlocked, "Week Warrior should be unlocked");
        assertTrue(conversationStarterUnlocked, "Conversation Starter should be unlocked");
        assertFalse(monthlyMasterUnlocked, "Monthly Master should still be locked");
    }

    @Test
    void testCalculateMoodStreak_LogicCoverage() {
        // Ce test couvre spécifiquement les branches if/else de la méthode privée calculateMoodStreak
        // via l'appel public getProgress

        mockAuthenticatedUser();

        // Cas 1: 0 logs -> Streak 0
        when(emotionLogRepository.countByUserEmail(testUser.getEmail())).thenReturn(0L);
        assertEquals(0, (int) progressController.getProgress().getBody().get("moodStreak"));

        // Cas 2: 4 logs -> Streak 4 (min(logs, 7))
        when(emotionLogRepository.countByUserEmail(testUser.getEmail())).thenReturn(4L);
        assertEquals(4, (int) progressController.getProgress().getBody().get("moodStreak"));

        // Cas 3: 7 logs -> Streak 7
        when(emotionLogRepository.countByUserEmail(testUser.getEmail())).thenReturn(7L);
        assertEquals(7, (int) progressController.getProgress().getBody().get("moodStreak"));

        // Cas 4: 15 logs -> Streak 14
        when(emotionLogRepository.countByUserEmail(testUser.getEmail())).thenReturn(15L);
        assertEquals(14, (int) progressController.getProgress().getBody().get("moodStreak"));

        // Cas 5: 35 logs -> Streak 30
        when(emotionLogRepository.countByUserEmail(testUser.getEmail())).thenReturn(35L);
        assertEquals(30, (int) progressController.getProgress().getBody().get("moodStreak"));
    }

    @Test
    void testCalculateWellnessScore_DaysZero() {
        // Couvre la branche "if (days > 0)" dans calculateWellnessScore
        // Si l'utilisateur vient de s'inscrire aujourd'hui (days = 0)

        mockAuthenticatedUser();
        testUser.setCreatedAt(LocalDateTime.now()); // Créé à l'instant

        when(emotionLogRepository.countByUserEmail(testUser.getEmail())).thenReturn(1L);

        // Act
        ResponseEntity<Map<String, Object>> response = progressController.getProgress();

        // Assert
        assertNotNull(response.getBody());
        // Pas d'erreur de division par zéro
        assertEquals(0L, response.getBody().get("daysSinceRegistration"));
    }

    // Méthode helper pour les tests
    private boolean isAchievementUnlocked(Map<String, Object>[] achievements, String achievementName) {
        for (Map<String, Object> achievement : achievements) {
            if (achievement.get("name").equals(achievementName)) {
                return (Boolean) achievement.get("unlocked");
            }
        }
        return false;
    }
}
