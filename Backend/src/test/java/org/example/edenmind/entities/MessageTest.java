package org.example.edenmind.entities;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class MessageTest {

    @Test
    void testConstructor() {
        Conversation conv = new Conversation();
        String content = "Bonjour";
        String sender = "USER";

        Message message = new Message(conv, content, sender);

        assertEquals(conv, message.getConversation());
        assertEquals(content, message.getContent());
        assertEquals(sender, message.getSenderType());
    }

    @Test
    void testLifecycleOnCreate() {
        Message message = new Message();
        assertNull(message.getSentAt());

        message.onCreate();

        assertNotNull(message.getSentAt());
    }
}
