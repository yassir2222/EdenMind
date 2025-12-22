package org.example.edenmind.entities;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "emotion_logs")
public class EmotionLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private String emotionType;

    @Column(nullable = true)
    private Integer intensity;

    @Column(columnDefinition = "TEXT")
    private String note;

    @Column(name = "trigger_event")
    private String triggerEvent;
    
    @Column(name = "activities")
    private String activities; // Comma separated list

    @Column(name = "source")
    private String source; // MANUAL or FACE_ANALYSIS

    @Column(name = "confidence")
    private Double confidence; // Confidence score for face analysis (0-100)

    @Column(updatable = false)
    private LocalDateTime recordedAt;

    public EmotionLog() {
    }

    public EmotionLog(User user, String emotionType, String activities, String note) {
        this.user = user;
        this.emotionType = emotionType;
        this.activities = activities;
        this.note = note;
        this.intensity = 5; // Default
    }

    @PrePersist
    protected void onCreate() {
        recordedAt = LocalDateTime.now();
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public String getEmotionType() {
        return emotionType;
    }

    public void setEmotionType(String emotionType) {
        this.emotionType = emotionType;
    }

    public Integer getIntensity() {
        return intensity;
    }

    public void setIntensity(Integer intensity) {
        this.intensity = intensity;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public String getTriggerEvent() {
        return triggerEvent;
    }

    public void setTriggerEvent(String triggerEvent) {
        this.triggerEvent = triggerEvent;
    }

    public String getActivities() {
        return activities;
    }

    public void setActivities(String activities) {
        this.activities = activities;
    }

    public LocalDateTime getRecordedAt() {
        return recordedAt;
    }

    public void setRecordedAt(LocalDateTime recordedAt) {
        this.recordedAt = recordedAt;
    }

    public String getSource() {
        return source;
    }

    public void setSource(String source) {
        this.source = source;
    }

    public Double getConfidence() {
        return confidence;
    }

    public void setConfidence(Double confidence) {
        this.confidence = confidence;
    }
}