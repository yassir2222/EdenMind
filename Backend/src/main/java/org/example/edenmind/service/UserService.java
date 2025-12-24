package org.example.edenmind.service;


import org.example.edenmind.entities.User;
import org.example.edenmind.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private org.example.edenmind.repositories.EmotionLogRepository emotionLogRepository;

    @Autowired
    private org.example.edenmind.repositories.NotificationRepository notificationRepository;

    @Autowired
    private org.example.edenmind.repositories.ConversationRepository conversationRepository;

    @Autowired
    private org.example.edenmind.repositories.MessageRepository messageRepository;


    public List<User> getAllUsers() {
        return userRepository.findAll();
    }


    public User getUserById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé avec l'id: " + id));
    }





    public User createUser(User user) {
        // Vérifie si l'email existe déjà
        if (userRepository.existsByEmail(user.getEmail())) {
            throw new RuntimeException("Cet email existe déjà: " + user.getEmail());
        }

        // Sauvegarde l'utilisateur dans la base de données
        return userRepository.save(user);
    }


    public User updateUser(Long id, User userDetails) {
        User user = getUserById(id);

        user.setFirstName(userDetails.getFirstName());
        user.setLastName(userDetails.getLastName());
        user.setPhoneNumber(userDetails.getPhoneNumber());
        user.setBio(userDetails.getBio());
        user.setAvatarUrl(userDetails.getAvatarUrl());
        user.setBirthday(userDetails.getBirthday());
        user.setFamilySituation(userDetails.getFamilySituation());
        user.setWorkType(userDetails.getWorkType());
        user.setWorkHours(userDetails.getWorkHours());
        user.setChildrenCount(userDetails.getChildrenCount());
        user.setCountry(userDetails.getCountry());

        return userRepository.save(user);
    }


    @org.springframework.transaction.annotation.Transactional
    public void deleteUser(Long id) {
        User user = getUserById(id);
        
        // Cascading delete: clean up dependent data first to avoid foreign key violations
        
        // 1. Delete Messages (linked to conversations)
        // We need to find conversations first to delete their messages efficiently, 
        // OR rely on messageRepository if it had a direct deleteByUserId (it doesn't seem to based on my check, it has countByConversationUserId)
        // Actually, let's look at ConversationRepository. 
        // To be safe and efficient, we can iterate conversations or use a custom query.
        // But wait, messageRepository.deleteByConversationId exists.
        
        List<org.example.edenmind.entities.Conversation> userConversations = conversationRepository.findByUserIdOrderByUpdatedAtDesc(id);
        for (org.example.edenmind.entities.Conversation conv : userConversations) {
            messageRepository.deleteByConversationId(conv.getId());
        }
        
        // 2. Delete Conversations
        conversationRepository.deleteAll(userConversations);
        
        // 3. Delete Notifications
        notificationRepository.deleteByUserId(id);
        
        // 4. Delete Emotion Logs
        emotionLogRepository.deleteByUserId(id);
        
        // 5. Finally, delete the User
        userRepository.delete(user);
    }
}