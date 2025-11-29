package org.example.edenmind.controller;

import org.example.edenmind.entities.Conversation;
import org.example.edenmind.entities.Message;
import org.example.edenmind.service.ConversationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;


@RestController
@RequestMapping("/api/conversations")
public class ConversationController {

    @Autowired
    private ConversationService conversationService;


    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Conversation>> getUserConversations(@PathVariable Long userId) {
        List<Conversation> conversations = conversationService.getUserConversations(userId);
        return ResponseEntity.ok(conversations);
    }


    @GetMapping("/{id}")
    public ResponseEntity<Conversation> getConversationById(@PathVariable Long id) {
        Conversation conversation = conversationService.getConversationById(id);
        return ResponseEntity.ok(conversation);
    }


    @PostMapping("/user/{userId}")
    public ResponseEntity<Conversation> createConversation(
            @PathVariable Long userId,
            @RequestBody Map<String, String> request) {

        String title = request.get("title");
        Conversation conversation = conversationService.createConversation(userId, title);
        return ResponseEntity.status(HttpStatus.CREATED).body(conversation);
    }


    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteConversation(@PathVariable Long id) {
        conversationService.deleteConversation(id);
        return ResponseEntity.noContent().build();
    }


    @GetMapping("/{id}/messages")
    public ResponseEntity<List<Message>> getConversationMessages(@PathVariable Long id) {
        List<Message> messages = conversationService.getConversationMessages(id);
        return ResponseEntity.ok(messages);
    }


    @PostMapping("/{id}/messages")
    public ResponseEntity<Message> addMessage(
            @PathVariable Long id,
            @RequestBody Map<String, String> request) {

        String content = request.get("content");
        String senderType = request.get("senderType");

        Message message = conversationService.addMessage(id, content, senderType);
        return ResponseEntity.status(HttpStatus.CREATED).body(message);
    }
}
