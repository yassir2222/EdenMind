package org.example.edenmind.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.example.edenmind.entities.Conversation;
import org.example.edenmind.entities.Message;
import org.example.edenmind.entities.User;
import org.example.edenmind.rag.RagService;
import org.example.edenmind.repositories.ConversationRepository;
import org.example.edenmind.repositories.EmotionLogRepository;
import org.example.edenmind.repositories.MessageRepository;
import org.example.edenmind.repositories.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.util.*;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class ChatControllerTest {

    private MockMvc mockMvc;

    @Mock
    private RagService ragService;

    @Mock
    private UserRepository userRepository;

    @Mock
    private ConversationRepository conversationRepository;

    @Mock
    private MessageRepository messageRepository;
    
    @Mock
    private EmotionLogRepository emotionLogRepository;

    @InjectMocks
    private ChatController chatController;

    private ObjectMapper objectMapper = new ObjectMapper();

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        mockMvc = MockMvcBuilders.standaloneSetup(chatController).build();
        
        // Mock Security Context
        User user = new User();
        user.setId(1L);
        user.setEmail("test@example.com");
        
        Authentication authentication = mock(Authentication.class);
        when(authentication.getName()).thenReturn("test@example.com");
        SecurityContext securityContext = mock(SecurityContext.class);
        when(securityContext.getAuthentication()).thenReturn(authentication);
        SecurityContextHolder.setContext(securityContext);
        
        when(userRepository.findByEmail("test@example.com")).thenReturn(Optional.of(user));
    }

    @Test
    void testGetConversations_Success() throws Exception {
        when(conversationRepository.findByUserIdOrderByUpdatedAtDesc(1L)).thenReturn(Collections.emptyList());

        mockMvc.perform(get("/api/chat/conversations"))
                .andExpect(status().isOk());
    }
    
    @Test
    void testGetMessages_Success() throws Exception {
        Conversation conversation = new Conversation();
        conversation.setId(10L);
        User user = new User();
        user.setId(1L);
        conversation.setUser(user);
        
        when(conversationRepository.findById(10L)).thenReturn(Optional.of(conversation));
        when(messageRepository.findByConversationIdOrderBySentAtAsc(10L)).thenReturn(Collections.emptyList());

        mockMvc.perform(get("/api/chat/conversations/10/messages"))
                .andExpect(status().isOk());
    }

    @Test
    void testChat_NewConversation() throws Exception {
        Map<String, Object> request = new HashMap<>();
        request.put("query", "Hello");
        
        when(ragService.ask(anyString(), anyString())).thenReturn("Hello there!");
        when(conversationRepository.save(any(Conversation.class))).thenAnswer(i -> {
            Conversation c = i.getArgument(0);
            c.setId(100L);
            return c;
        });

        mockMvc.perform(post("/api/chat/query")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk());
        
        verify(messageRepository, times(2)).save(any(Message.class)); // 1 User, 1 Bot
    }
}
