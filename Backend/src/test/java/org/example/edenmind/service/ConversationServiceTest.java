package org.example.edenmind.service;

import org.example.edenmind.entities.Conversation;
import org.example.edenmind.entities.User;
import org.example.edenmind.repositories.ConversationRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class ConversationServiceTest {

    @Mock
    private ConversationRepository conversationRepository;

    @InjectMocks
    private ConversationService conversationService;

    @Mock
    private UserService userService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void testCreateConversation() {
        Conversation conversation = new Conversation();
        conversation.setTitle("Test Conversation");
        User user = new User();
        user.setId(1L);
        
        when(userService.getUserById(1L)).thenReturn(user);
        when(conversationRepository.save(any(Conversation.class))).thenAnswer(i -> i.getArgument(0));
        
        Conversation result = conversationService.createConversation(1L, "Test Conversation");
        assertEquals("Test Conversation", result.getTitle());
    }

    @Test
    void testGetUserConversations() {
        Conversation conv1 = new Conversation();
        Conversation conv2 = new Conversation();
        
        when(conversationRepository.findByUserIdOrderByUpdatedAtDesc(1L))
                .thenReturn(Arrays.asList(conv1, conv2));
        
        List<Conversation> conversations = conversationService.getUserConversations(1L);
        assertEquals(2, conversations.size());
    }

    @Test
    void testDeleteConversation() {
        Conversation conversation = new Conversation();
        conversation.setId(1L);
        when(conversationRepository.findById(1L)).thenReturn(Optional.of(conversation));
        doNothing().when(conversationRepository).delete(conversation);
        
        conversationService.deleteConversation(1L);
        verify(conversationRepository, times(1)).delete(conversation);
    }
    
    @Test
    void testGetConversationById() {
        Conversation conversation = new Conversation();
        conversation.setId(1L);
        when(conversationRepository.findById(1L)).thenReturn(Optional.of(conversation));
        
        Conversation result = conversationService.getConversationById(1L);
        assertNotNull(result);
        assertEquals(1L, result.getId());
    }
}
