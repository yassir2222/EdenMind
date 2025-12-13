package org.example.edenmind.repositories;

import org.example.edenmind.entities.Message;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Repository
public interface MessageRepository extends JpaRepository<Message, Long> {

    List<Message> findByConversationIdOrderBySentAtAsc(Long conversationId);
    
    @Modifying
    @Transactional
    void deleteByConversationId(Long conversationId);
    
    long countByConversationUserId(Long userId);
}
