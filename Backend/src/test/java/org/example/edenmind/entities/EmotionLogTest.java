package org.example.edenmind.entities;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class EmotionLogTest {

    @Test
    void testCustomConstructor() {
        User user = new User();
        String type = "Joie";
        String activities = "Sport, Lecture";
        String note = "Bonne journée";

        EmotionLog log = new EmotionLog(user, type, activities, note);

        assertEquals(user, log.getUser());
        assertEquals(type, log.getEmotionType());
        assertEquals(activities, log.getActivities());
        assertEquals(note, log.getNote());

        // Test crucial : Vérifier la valeur par défaut définie dans le constructeur
        assertEquals(5, log.getIntensity());
    }

    @Test
    void testLifecycleOnCreate() {
        EmotionLog log = new EmotionLog();
        assertNull(log.getRecordedAt());

        log.onCreate();

        assertNotNull(log.getRecordedAt());
    }

    @Test
    void testSetters() {
        EmotionLog log = new EmotionLog();
        log.setIntensity(8);
        log.setTriggerEvent("Réunion");

        assertEquals(8, log.getIntensity());
        assertEquals("Réunion", log.getTriggerEvent());
    }
}