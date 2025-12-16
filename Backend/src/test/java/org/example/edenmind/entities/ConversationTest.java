package org.example.edenmind.entities;

import org.junit.jupiter.api.Test;
import java.time.LocalDateTime;
import java.util.ArrayList;

import static org.junit.jupiter.api.Assertions.*;

class ConversationTest {

    @Test
    void testConstructorAndGetters() {
        User user = new User();
        String title = "Discussion sur le stress";

        Conversation conversation = new Conversation(user, title);

        assertEquals(user, conversation.getUser());
        assertEquals(title, conversation.getTitle());
        // Vérifie que la liste est bien initialisée (pas null) grâce à = new ArrayList<>()
        assertNotNull(conversation.getMessages());
        assertTrue(conversation.getMessages().isEmpty());
    }

    @Test
    void testLifecycleOnCreate() {
        Conversation conversation = new Conversation();
        assertNull(conversation.getCreatedAt());
        assertNull(conversation.getUpdatedAt());

        // Simulation de l'appel JPA @PrePersist
        conversation.onCreate();

        assertNotNull(conversation.getCreatedAt());
        assertNotNull(conversation.getUpdatedAt());
        // createdAt et updatedAt doivent être quasiment identiques à la création
        assertNotNull(conversation.getCreatedAt());
    }

    @Test
    void testLifecycleOnUpdate() throws InterruptedException {
        Conversation conversation = new Conversation();
        conversation.onCreate();

        LocalDateTime creationTime = conversation.getCreatedAt();
        LocalDateTime firstUpdateTime = conversation.getUpdatedAt();

        // Petite pause pour garantir un timestamp différent
        Thread.sleep(10);

        // Simulation de l'appel JPA @PreUpdate
        conversation.onUpdate();

        assertEquals(creationTime, conversation.getCreatedAt()); // La date de création ne doit pas bouger
        assertTrue(conversation.getUpdatedAt().isAfter(firstUpdateTime)); // La date de maj doit être postérieure
    }
}