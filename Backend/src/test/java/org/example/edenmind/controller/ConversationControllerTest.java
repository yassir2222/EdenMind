package org.example.edenmind.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.example.edenmind.entities.Conversation;
import org.example.edenmind.entities.Message;
import org.example.edenmind.service.ConversationService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class ConversationControllerTest {

    private MockMvc mockMvc;

    @Mock
    private ConversationService conversationService;

    @InjectMocks
    private ConversationController conversationController;

    private ObjectMapper objectMapper = new ObjectMapper();

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        mockMvc = MockMvcBuilders.standaloneSetup(conversationController).build();
    }

    @Test
    void testGetUserConversations() throws Exception {
        when(conversationService.getUserConversations(anyLong())).thenReturn(Collections.emptyList());

        mockMvc.perform(get("/api/conversations/user/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray());
    }

    @Test
    void testGetConversationById() throws Exception {
        Conversation conversation = new Conversation();
        conversation.setId(1L);
        conversation.setTitle("Test Conversation");

        when(conversationService.getConversationById(1L)).thenReturn(conversation);

        mockMvc.perform(get("/api/conversations/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.title").value("Test Conversation"));
    }

    @Test
    void testCreateConversation() throws Exception {
        Map<String, String> request = new HashMap<>();
        request.put("title", "Test Chat");
        
        Conversation conversation = new Conversation();
        conversation.setTitle("Test Chat");

        when(conversationService.createConversation(anyLong(), anyString())).thenReturn(conversation);

        mockMvc.perform(post("/api/conversations/user/1")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.title").value("Test Chat"));
    }
    
    @Test
    void testDeleteConversation() throws Exception {
        doNothing().when(conversationService).deleteConversation(anyLong());

        mockMvc.perform(delete("/api/conversations/1"))
                .andExpect(status().isNoContent());
    }

    @Test
    void testGetConversationMessages() throws Exception {
        when(conversationService.getConversationMessages(anyLong())).thenReturn(Collections.emptyList());

        mockMvc.perform(get("/api/conversations/1/messages"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray());
    }

    @Test
    void testAddMessage() throws Exception {
        Map<String, String> request = new HashMap<>();
        request.put("content", "Hello");
        request.put("senderType", "USER");

        Message message = new Message();
        message.setContent("Hello");
        message.setSenderType("USER");

        when(conversationService.addMessage(anyLong(), anyString(), anyString())).thenReturn(message);

        mockMvc.perform(post("/api/conversations/1/messages")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.content").value("Hello"));
    }
}

