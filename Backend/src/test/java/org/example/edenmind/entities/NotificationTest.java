package org.example.edenmind.entities;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class NotificationTest {

    @Test
    void testConstructorAndDefaults() {
        User user = new User();
        String title = "Rappel";
        String msg = "Il est temps de méditer";
        String type = "reminder";

        Notification notif = new Notification(user, title, msg, type);

        assertEquals(user, notif.getUser());
        assertEquals(title, notif.getTitle());
        assertEquals(msg, notif.getMessage());
        assertEquals(type, notif.getType());

        // Test crucial : isRead doit être false par défaut (défini dans l'entité)
        assertFalse(notif.isRead());
    }

    @Test
    void testLifecycleOnCreate() {
        Notification notif = new Notification();
        notif.onCreate();
        assertNotNull(notif.getCreatedAt());
    }

    @Test
    void testMarkAsRead() {
        Notification notif = new Notification();
        notif.setRead(true);
        assertTrue(notif.isRead());
    }
}