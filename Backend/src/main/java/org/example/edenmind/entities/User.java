package org.example.edenmind.entities;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false)
    private String firstName;

    @Column(nullable = false)
    private String lastName;

    private String phoneNumber;

    @Column(columnDefinition = "TEXT")
    private String bio;

    private String avatarUrl;

    private LocalDate birthday;
    private String familySituation;
    private String workType;
    private String workHours;
    private Integer childrenCount;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String country;
}
