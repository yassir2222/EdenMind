package org.example.edenmind.repositories;

import org.example.edenmind.entities.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);

    boolean existsByEmail(String email);

     Optional<User> findByKeycloakId(String keycloakId);
}
