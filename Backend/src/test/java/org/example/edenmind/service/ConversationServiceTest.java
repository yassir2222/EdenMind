package org.example.edenmind.service;

import org.example.edenmind.entities.Conversation;
import org.example.edenmind.entities.Message;
import org.example.edenmind.entities.User;
import org.example.edenmind.repositories.ConversationRepository;
import org.example.edenmind.repositories.MessageRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class ConversationServiceTest {

    @Mock
    private ConversationRepository conversationRepository;

    @Mock
    private MessageRepository messageRepository; // Ajout du mock pour les messages

    @Mock
    private UserService userService;

    @InjectMocks
    private ConversationService conversationService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    // --- Tests pour Conversation ---

    @Test
    void testCreateConversation() {
        // Arrange
        Long userId = 1L;
        String title = "Test Conversation";
        User user = new User();
        user.setId(userId);

        Conversation savedConversation = new Conversation();
        savedConversation.setId(10L);
        savedConversation.setUser(user);
        savedConversation.setTitle(title);

        when(userService.getUserById(userId)).thenReturn(user);
        when(conversationRepository.save(any(Conversation.class))).thenReturn(savedConversation);

        // Act
        Conversation result = conversationService.createConversation(userId, title);

        // Assert
        assertNotNull(result);
        assertEquals(title, result.getTitle());
        assertEquals(user, result.getUser());
        verify(userService, times(1)).getUserById(userId);
        verify(conversationRepository, times(1)).save(any(Conversation.class));
    }

    @Test
    void testGetUserConversations() {
        // Arrange
        Long userId = 1L;
        Conversation conv1 = new Conversation();
        Conversation conv2 = new Conversation();
        List<Conversation> expectedList = Arrays.asList(conv1, conv2);

        when(conversationRepository.findByUserIdOrderByUpdatedAtDesc(userId))
                .thenReturn(expectedList);

        // Act
        List<Conversation> conversations = conversationService.getUserConversations(userId);

        // Assert
        assertEquals(2, conversations.size());
        verify(conversationRepository, times(1)).findByUserIdOrderByUpdatedAtDesc(userId);
    }

    @Test
    void testGetConversationById_Success() {
        // Arrange
        Long convId = 1L;
        Conversation conversation = new Conversation();
        conversation.setId(convId);

        when(conversationRepository.findById(convId)).thenReturn(Optional.of(conversation));

        // Act
        Conversation result = conversationService.getConversationById(convId);

        // Assert
        assertNotNull(result);
        assertEquals(convId, result.getId());
    }

    @Test
    void testGetConversationById_NotFound_ThrowsException() {
        // Ce test couvre la branche "orElseThrow"
        // Arrange
        Long convId = 99L;
        when(conversationRepository.findById(convId)).thenReturn(Optional.empty());

        // Act & Assert
        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            conversationService.getConversationById(convId);
        });

        assertEquals("Conversation non trouvée avec l'id: " + convId, exception.getMessage());
    }

    @Test
    void testDeleteConversation() {
        // Arrange
        Long convId = 1L;
        Conversation conversation = new Conversation();
        conversation.setId(convId);

        when(conversationRepository.findById(convId)).thenReturn(Optional.of(conversation));
        doNothing().when(conversationRepository).delete(conversation);

        // Act
        conversationService.deleteConversation(convId);

        // Assert
        verify(conversationRepository, times(1)).findById(convId);
        verify(conversationRepository, times(1)).delete(conversation);
    }

    // --- Tests pour Message (Nouveaux ajouts) ---

    @Test
    void testGetConversationMessages() {
        // Arrange
        Long convId = 1L;
        Message msg1 = new Message();
        Message msg2 = new Message();
        List<Message> expectedMessages = Arrays.asList(msg1, msg2);

        when(messageRepository.findByConversationIdOrderBySentAtAsc(convId))
                .thenReturn(expectedMessages);

        // Act
        List<Message> result = conversationService.getConversationMessages(convId);

        // Assert
        assertNotNull(result);
        assertEquals(2, result.size());
        verify(messageRepository, times(1)).findByConversationIdOrderBySentAtAsc(convId);
    }

    @Test
    void testAddMessage() {
        // Arrange
        Long convId = 1L;
        String content = "Hello World";
        String senderType = "user";

        Conversation conversation = new Conversation();
        conversation.setId(convId);

        // On doit mocker la récupération de la conversation car addMessage l'appelle
        when(conversationRepository.findById(convId)).thenReturn(Optional.of(conversation));

        // On mock le save pour qu'il retourne l'objet passé en argument
        when(messageRepository.save(any(Message.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // Act
        Message result = conversationService.addMessage(convId, content, senderType);

        // Assert
        assertNotNull(result);
        assertEquals(content, result.getContent());
        assertEquals(senderType, result.getSenderType());
        assertEquals(conversation, result.getConversation());

        verify(conversationRepository, times(1)).findById(convId);
        verify(messageRepository, times(1)).save(any(Message.class));
    }
}