package org.example.edenmind.service;


import org.example.edenmind.entities.Conversation;
import org.example.edenmind.entities.Message;
import org.example.edenmind.entities.User;
import org.example.edenmind.repositories.ConversationRepository;
import org.example.edenmind.repositories.MessageRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * Service pour gérer les conversations
 */
@Service
public class ConversationService {

    @Autowired
    private ConversationRepository conversationRepository;

    @Autowired
    private MessageRepository messageRepository;

    @Autowired
    private UserService userService;

    /**
     * Récupère toutes les conversations d'un utilisateur
     */
    public List<Conversation> getUserConversations(Long userId) {
        return conversationRepository.findByUserIdOrderByUpdatedAtDesc(userId);
    }

    /**
     * Récupère une conversation par son ID
     */
    public Conversation getConversationById(Long id) {
        return conversationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Conversation non trouvée avec l'id: " + id));
    }

    /**
     * Crée une nouvelle conversation
     */
    public Conversation createConversation(Long userId, String title) {
        User user = userService.getUserById(userId);

        Conversation conversation = new Conversation();
        conversation.setUser(user);
        conversation.setTitle(title);

        return conversationRepository.save(conversation);
    }

    /**
     * Supprime une conversation
     */
    public void deleteConversation(Long id) {
        Conversation conversation = getConversationById(id);
        conversationRepository.delete(conversation);
    }

    /**
     * Récupère tous les messages d'une conversation
     */
    public List<Message> getConversationMessages(Long conversationId) {
        return messageRepository.findByConversationIdOrderBySentAtAsc(conversationId);
    }

    /**
     * Ajoute un message à une conversation
     */
    public Message addMessage(Long conversationId, String content, String senderType) {
        Conversation conversation = getConversationById(conversationId);

        Message message = new Message();
        message.setConversation(conversation);
        message.setContent(content);
        message.setSenderType(senderType);

        return messageRepository.save(message);
    }
}