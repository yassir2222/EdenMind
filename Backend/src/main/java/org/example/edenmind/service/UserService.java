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


    public void deleteUser(Long id) {
        User user = getUserById(id);
        userRepository.delete(user);
    }
}