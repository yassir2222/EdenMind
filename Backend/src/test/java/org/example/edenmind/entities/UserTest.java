package org.example.edenmind.entities;

import org.junit.jupiter.api.Test;
import java.time.LocalDate;
import static org.junit.jupiter.api.Assertions.*;

class UserTest {

    @Test
    void testLombokGettersAndSetters() {
        User user = new User();

        user.setEmail("test@test.com");
        user.setFirstName("John");
        user.setLastName("Doe");
        user.setBirthday(LocalDate.of(1990, 1, 1));
        user.setChildrenCount(2);

        assertEquals("test@test.com", user.getEmail());
        assertEquals("John", user.getFirstName());
        assertEquals("Doe", user.getLastName());
        assertEquals(LocalDate.of(1990, 1, 1), user.getBirthday());
        assertEquals(2, user.getChildrenCount());
    }

    @Test
    void testEqualsAndHashCode() {
        // Avec @Data, equals se base sur tous les champs
        User u1 = new User();
        u1.setId(1L);
        u1.setEmail("a@a.com");

        User u2 = new User();
        u2.setId(1L);
        u2.setEmail("a@a.com");

        assertEquals(u1, u2);
        assertEquals(u1.hashCode(), u2.hashCode());

        // Si on change un champ, ils ne doivent plus être égaux
        u2.setEmail("b@b.com");
        assertNotEquals(u1, u2);
    }

    @Test
    void testAllArgsConstructor() {
        // Vérification que le constructeur complet existe (généré par Lombok)
        User user = new User(
                1L, "email@test.com", "pass", "John", "Doe", "0600000000",
                "Bio", "url", LocalDate.now(), "Single", "Dev", "35h", 0,
                null, null, "France"
        );

        assertNotNull(user);
        assertEquals("John", user.getFirstName());
    }
}