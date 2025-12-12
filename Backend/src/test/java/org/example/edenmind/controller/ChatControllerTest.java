package org.example.edenmind.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.example.edenmind.entities.Conversation;
import org.example.edenmind.entities.EmotionLog;
import org.example.edenmind.entities.Message;
import org.example.edenmind.entities.User;
import org.example.edenmind.rag.RagService;
import org.example.edenmind.repositories.ConversationRepository;
import org.example.edenmind.repositories.EmotionLogRepository;
import org.example.edenmind.repositories.MessageRepository;
import org.example.edenmind.repositories.UserRepository;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.http.MediaType;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.time.LocalDateTime;
import java.util.*;

import static org.hamcrest.Matchers.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
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

    private User testUser;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        mockMvc = MockMvcBuilders.standaloneSetup(chatController).build();

        testUser = new User();
        testUser.setId(1L);
        testUser.setEmail("test@example.com");
        testUser.setFirstName("Test");
        testUser.setLastName("User");
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    private void mockAuthenticatedUser() {
        Authentication authentication = mock(Authentication.class);
        when(authentication.getName()).thenReturn("test@example.com");
        SecurityContext securityContext = mock(SecurityContext.class);
        when(securityContext.getAuthentication()).thenReturn(authentication);
        SecurityContextHolder.setContext(securityContext);

        when(userRepository.findByEmail("test@example.com")).thenReturn(Optional.of(testUser));
    }

    // --- getConversations Tests ---

    @Test
    void testGetConversations_Success() throws Exception {
        mockAuthenticatedUser();
        when(conversationRepository.findByUserIdOrderByUpdatedAtDesc(1L)).thenReturn(Collections.emptyList());

        mockMvc.perform(get("/api/chat/conversations"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(0)));
    }

    @Test
    void testGetConversations_Unauthenticated() throws Exception {
        // No auth setup calls
        mockMvc.perform(get("/api/chat/conversations"))
                .andExpect(status().isUnauthorized());
    }

    // --- getMessages Tests ---

    @Test
    void testGetMessages_Success() throws Exception {
        mockAuthenticatedUser();
        Conversation conversation = new Conversation();
        conversation.setId(10L);
        conversation.setUser(testUser);

        when(conversationRepository.findById(10L)).thenReturn(Optional.of(conversation));
        when(messageRepository.findByConversationIdOrderBySentAtAsc(10L)).thenReturn(Collections.emptyList());

        mockMvc.perform(get("/api/chat/conversations/10/messages"))
                .andExpect(status().isOk());
    }

    @Test
    void testGetMessages_Unauthenticated() throws Exception {
        mockMvc.perform(get("/api/chat/conversations/10/messages"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void testGetMessages_NotFound() throws Exception {
        mockAuthenticatedUser();
        when(conversationRepository.findById(99L)).thenReturn(Optional.empty());

        mockMvc.perform(get("/api/chat/conversations/99/messages"))
                .andExpect(status().isNotFound());
    }

    @Test
    void testGetMessages_Forbidden() throws Exception {
        mockAuthenticatedUser();
        User otherUser = new User();
        otherUser.setId(2L);
        Conversation conversation = new Conversation();
        conversation.setId(10L);
        conversation.setUser(otherUser);

        when(conversationRepository.findById(10L)).thenReturn(Optional.of(conversation));

        mockMvc.perform(get("/api/chat/conversations/10/messages"))
                .andExpect(status().isForbidden());
    }

    // --- Chat (Query) Tests ---

    @Test
    void testChat_EmptyQuery() throws Exception {
        Map<String, Object> request = new HashMap<>();
        request.put("query", "   ");

        mockMvc.perform(post("/api/chat/query")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").exists());
    }

    @Test
    void testChat_Stateless_Success() throws Exception {
        // No auth setup -> Stateless
        Map<String, Object> request = new HashMap<>();
        request.put("query", "Hello");

        when(ragService.ask(eq("Hello"), eq(""))).thenReturn("Stateless Answer");

        mockMvc.perform(post("/api/chat/query")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.answer", is("Stateless Answer")));
        
        verify(conversationRepository, never()).save(any());
        verify(messageRepository, never()).save(any());
    }

    @Test
    void testChat_NewConversation_Success() throws Exception {
        mockAuthenticatedUser();
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
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.conversationId", is(100)));

        verify(messageRepository, times(2)).save(any(Message.class));
    }

    @Test
    void testChat_ExistingConversation_Success() throws Exception {
        mockAuthenticatedUser();
        Conversation conversation = new Conversation();
        conversation.setId(100L);
        conversation.setUser(testUser);

        Map<String, Object> request = new HashMap<>();
        request.put("query", "Follow up");
        request.put("conversationId", 100);

        when(conversationRepository.findById(100L)).thenReturn(Optional.of(conversation));
        when(ragService.ask(anyString(), anyString())).thenReturn("Follow up answer");

        mockMvc.perform(post("/api/chat/query")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.answer", is("Follow up answer")));
        
        // At least once because the controller calls setUpdatedAt and save
        verify(conversationRepository, atLeastOnce()).save(conversation); 
    }

    @Test
    void testChat_ConversationNotFound() throws Exception {
        mockAuthenticatedUser();
        Map<String, Object> request = new HashMap<>();
        request.put("query", "Hello");
        request.put("conversationId", 999);

        when(conversationRepository.findById(999L)).thenReturn(Optional.empty());

        mockMvc.perform(post("/api/chat/query")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.error", containsString("not found")));
    }

    @Test
    void testChat_ConversationForbidden() throws Exception {
        mockAuthenticatedUser();
        User otherUser = new User();
        otherUser.setId(2L);
        Conversation conversation = new Conversation();
        conversation.setId(100L);
        conversation.setUser(otherUser);

        Map<String, Object> request = new HashMap<>();
        request.put("query", "Hello");
        request.put("conversationId", 100);

        when(conversationRepository.findById(100L)).thenReturn(Optional.of(conversation));

        mockMvc.perform(post("/api/chat/query")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.error", containsString("Access denied")));
    }
    
    @Test
    void testChat_WithFullUserContext() throws Exception {
        mockAuthenticatedUser();
        testUser.setBio("My Bio");
        testUser.setWorkType("Developer");
        testUser.setFamilySituation("Single");

        EmotionLog log1 = new EmotionLog();
        log1.setEmotionType("JOY"); 
        log1.setRecordedAt(LocalDateTime.now());
        log1.setNote("Good day");
        
        when(emotionLogRepository.findByUserEmailOrderByRecordedAtDesc("test@example.com"))
                .thenReturn(Collections.singletonList(log1));
        
        when(ragService.ask(eq("Hi"), anyString())).thenReturn("Personalized Hi");
        
        when(conversationRepository.save(any(Conversation.class))).thenAnswer(i -> {
             Conversation c = i.getArgument(0);
             c.setId(101L);
             return c;
        });

        Map<String, Object> request = new HashMap<>();
        request.put("query", "Hi");

        mockMvc.perform(post("/api/chat/query")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk());
             
        verify(ragService).ask(eq("Hi"), contains("My Bio"));
        verify(ragService).ask(eq("Hi"), contains("Developer"));
        verify(ragService).ask(eq("Hi"), contains("JOY"));
    }

    @Test
    void testChat_Exception() throws Exception {
        mockAuthenticatedUser();
        when(ragService.ask(anyString(), anyString())).thenThrow(new RuntimeException("RAG Error"));
        // When save is called, mock it properly to proceed if save is called before exception (it is not, but just in case)
        lenient().when(conversationRepository.save(any(Conversation.class))).thenReturn(new Conversation());


        Map<String, Object> request = new HashMap<>();
        request.put("query", "Error");

        mockMvc.perform(post("/api/chat/query")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isInternalServerError())
                .andExpect(jsonPath("$.error", is("RAG Error")));
    }
}

