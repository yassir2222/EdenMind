package org.example.edenmind.controller;

import org.example.edenmind.entities.Conversation;
import org.example.edenmind.entities.EmotionLog;
import org.example.edenmind.entities.Message;
import org.example.edenmind.entities.User;
import org.example.edenmind.rag.RagService;
import org.example.edenmind.repositories.ConversationRepository;
import org.example.edenmind.repositories.EmotionLogRepository;
import org.example.edenmind.repositories.MessageRepository;
import org.example.edenmind.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/chat")
public class ChatController {

    public ChatController() {
        System.out.println("ChatController: Bean Initialized!");
    }

    @Autowired
    private RagService ragService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private EmotionLogRepository emotionLogRepository;

    @Autowired
    private ConversationRepository conversationRepository;

    @Autowired
    private MessageRepository messageRepository;

    @GetMapping("/conversations")
    public ResponseEntity<List<Conversation>> getConversations() {
        User user = getAuthenticatedUser();
        if (user == null) {
            return ResponseEntity.status(401).build();
        }
        return ResponseEntity.ok(conversationRepository.findByUserIdOrderByUpdatedAtDesc(user.getId()));
    }

    @GetMapping("/conversations/{id}/messages")
    public ResponseEntity<List<Message>> getMessages(@PathVariable Long id) {
        User user = getAuthenticatedUser();
        if (user == null) {
            return ResponseEntity.status(401).build();
        }

        Optional<Conversation> conversationOpt = conversationRepository.findById(id);
        if (conversationOpt.isPresent()) {
            Conversation conversation = conversationOpt.get();
            if (!conversation.getUser().getId().equals(user.getId())) {
                return ResponseEntity.status(403).build();
            }
            return ResponseEntity.ok(messageRepository.findByConversationIdOrderBySentAtAsc(id));
        }
        return ResponseEntity.notFound().build();
    }

    @PostMapping("/query")
    public ResponseEntity<Map<String, Object>> chat(@RequestBody Map<String, Object> request) {
        System.out.println("ChatController: Received chat query");
        String query = (String) request.get("query");
        Long conversationId = request.get("conversationId") != null ? ((Number) request.get("conversationId")).longValue() : null;

        if (query == null || query.trim().isEmpty()) {
            return ResponseEntity.badRequest().body(Collections.singletonMap("error", "Query cannot be empty"));
        }

        try {
            User user = getAuthenticatedUser();
            if (user == null) {
                // If no user context (should be handled by security), act stateless
                 String answer = ragService.ask(query, "");
                 return ResponseEntity.ok(Collections.singletonMap("answer", answer));
            }

            Conversation conversation;
            if (conversationId != null) {
                Optional<Conversation> convOpt = conversationRepository.findById(conversationId);
                if (convOpt.isPresent()) {
                    conversation = convOpt.get();
                    if (!conversation.getUser().getId().equals(user.getId())) {
                         return ResponseEntity.status(403).body(Collections.singletonMap("error", "Access denied to conversation"));
                    }
                } else {
                     return ResponseEntity.status(404).body(Collections.singletonMap("error", "Conversation not found"));
                }
            } else {
                // Determine a title (first 30 chars of query)
                String title = query.length() > 30 ? query.substring(0, 30) + "..." : query;
                conversation = new Conversation(user, title);
                conversation = conversationRepository.save(conversation);
            }

            // Save User Message
            Message userMsg = new Message(conversation, query, "USER");
            messageRepository.save(userMsg);

            // Construct User Context
            StringBuilder userContext = new StringBuilder();
            userContext.append("User Profile:\n");
            userContext.append("Name: ").append(user.getFirstName()).append(" ").append(user.getLastName()).append("\n");
            if (user.getBio() != null) userContext.append("Bio: ").append(user.getBio()).append("\n");
            if (user.getFamilySituation() != null) userContext.append("Family: ").append(user.getFamilySituation()).append("\n");
            if (user.getWorkType() != null) userContext.append("Work: ").append(user.getWorkType()).append("\n");
            
            // Fetch recent mood logs
            List<EmotionLog> recentMoods = emotionLogRepository.findByUserEmailOrderByRecordedAtDesc(user.getEmail());
            if (!recentMoods.isEmpty()) {
                userContext.append("\nRecent Mood Logs:\n");
                for (int i = 0; i < Math.min(recentMoods.size(), 5); i++) {
                    EmotionLog log = recentMoods.get(i);
                    userContext.append("- ").append(log.getRecordedAt().toLocalDate())
                              .append(": ").append(log.getEmotionType());
                    if (log.getNote() != null && !log.getNote().isEmpty()) {
                        userContext.append(" (Note: ").append(log.getNote()).append(")");
                    }
                    userContext.append("\n");
                }
            }
            
            // Add previous messages context? (Optional, maybe limited to last few)
            // For now, relying on single query + user context

            String answer = ragService.ask(query, userContext.toString());

            // Save Bot Message
            Message botMsg = new Message(conversation, answer, "BOT");
            messageRepository.save(botMsg);

            // Update conversation updated_at
            // conversationRepository.save(conversation); // Handled by @PreUpdate if we modify it, otherwise explicit save needed if we want to bump timestamp
             conversation.setUpdatedAt(java.time.LocalDateTime.now());
             conversationRepository.save(conversation);


            Map<String, Object> response = new HashMap<>();
            response.put("answer", answer);
            response.put("conversationId", conversation.getId());
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body(Collections.singletonMap("error", e.getMessage()));
        }
    }

    private User getAuthenticatedUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = null;
        if (authentication != null && authentication.getPrincipal() instanceof UserDetails) {
            email = ((UserDetails) authentication.getPrincipal()).getUsername();
        } else if (authentication != null) {
            email = authentication.getName();
        }

        if (email != null) {
            return userRepository.findByEmail(email).orElse(null);
        }
        return null;
    }

}
