package org.example.edenmind.service;

import org.example.edenmind.entities.User;
import org.example.edenmind.repositories.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.time.LocalDate;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private UserService userService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void testGetAllUsers() {
        // Arrange
        User user1 = new User();
        user1.setId(1L);
        User user2 = new User();
        user2.setId(2L);
        when(userRepository.findAll()).thenReturn(Arrays.asList(user1, user2));

        // Act
        List<User> result = userService.getAllUsers();

        // Assert
        assertEquals(2, result.size());
        verify(userRepository, times(1)).findAll();
    }

    @Test
    void testGetUserById_Success() {
        // Arrange
        User user = new User();
        user.setId(1L);
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));

        // Act
        User foundUser = userService.getUserById(1L);

        // Assert
        assertNotNull(foundUser);
        assertEquals(1L, foundUser.getId());
    }

    @Test
    void testGetUserById_NotFound() {
        // Arrange
        when(userRepository.findById(1L)).thenReturn(Optional.empty());

        // Act & Assert
        RuntimeException exception = assertThrows(RuntimeException.class, () -> userService.getUserById(1L));
        assertEquals("Utilisateur non trouvé avec l'id: 1", exception.getMessage());
    }

    @Test
    void testCreateUser_Success() {
        // Arrange
        User user = new User();
        user.setEmail("test@example.com");

        when(userRepository.existsByEmail("test@example.com")).thenReturn(false);
        when(userRepository.save(any(User.class))).thenReturn(user);

        // Act
        User savedUser = userService.createUser(user);

        // Assert
        assertNotNull(savedUser);
        assertEquals("test@example.com", savedUser.getEmail());
        verify(userRepository, times(1)).save(user);
    }

    @Test
    void testCreateUser_EmailExists() {
        // Arrange
        User user = new User();
        user.setEmail("existing@example.com");

        when(userRepository.existsByEmail("existing@example.com")).thenReturn(true);

        // Act & Assert
        RuntimeException exception = assertThrows(RuntimeException.class, () -> userService.createUser(user));
        assertEquals("Cet email existe déjà: existing@example.com", exception.getMessage());
        verify(userRepository, never()).save(any(User.class));
    }

    @Test
    void testUpdateUser() {
        // Arrange
        Long userId = 1L;

        // Utilisateur existant en base
        User existingUser = new User();
        existingUser.setId(userId);
        existingUser.setFirstName("OldName");

        // Détails de la mise à jour (contient les nouvelles valeurs)
        User userDetails = new User();
        userDetails.setFirstName("NewName");
        userDetails.setLastName("NewLast");
        userDetails.setPhoneNumber("123456789");
        userDetails.setBio("New Bio");
        userDetails.setAvatarUrl("http://avatar.com/img.png");
        userDetails.setBirthday(LocalDate.of(1990, 1, 1));
        userDetails.setFamilySituation("Single");
        userDetails.setWorkType("Developer");
        userDetails.setWorkHours("40h");
        userDetails.setChildrenCount(0);
        userDetails.setCountry("Morocco");

        when(userRepository.findById(userId)).thenReturn(Optional.of(existingUser));
        when(userRepository.save(any(User.class))).thenAnswer(i -> i.getArgument(0));

        // Act
        User updatedUser = userService.updateUser(userId, userDetails);

        // Assert
        // Vérification que TOUS les setters ont bien été appelés
        assertEquals("NewName", updatedUser.getFirstName());
        assertEquals("NewLast", updatedUser.getLastName());
        assertEquals("123456789", updatedUser.getPhoneNumber());
        assertEquals("New Bio", updatedUser.getBio());
        assertEquals("http://avatar.com/img.png", updatedUser.getAvatarUrl());
        assertEquals(LocalDate.of(1990, 1, 1), updatedUser.getBirthday());
        assertEquals("Single", updatedUser.getFamilySituation());
        assertEquals("Developer", updatedUser.getWorkType());
        assertEquals("40h", updatedUser.getWorkHours());
        assertEquals(0, updatedUser.getChildrenCount());
        assertEquals("Morocco", updatedUser.getCountry());

        verify(userRepository, times(1)).save(existingUser);
    }

    @Test
    void testDeleteUser() {
        // Arrange
        Long userId = 1L;
        User user = new User();
        user.setId(userId);

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        doNothing().when(userRepository).delete(user);

        // Act
        userService.deleteUser(userId);

        // Assert
        verify(userRepository, times(1)).delete(user);
    }
}