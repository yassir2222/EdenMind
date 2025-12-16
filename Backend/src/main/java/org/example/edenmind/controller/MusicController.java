package org.example.edenmind.controller;

import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
@Slf4j
@RestController
@RequestMapping("/api/music")
@CrossOrigin(origins = {"http://localhost:4200", "http://localhost:60826"})
public class MusicController {
    private static final Logger logger = LoggerFactory.getLogger(MusicController.class);
    private Path getMusicPath() {
        Path relativePath = Paths.get("music");
        if (Files.exists(relativePath) && Files.isDirectory(relativePath)) {
            return relativePath;
        }
        return relativePath;
    }

    @GetMapping("/tracks")
    public ResponseEntity<List<TrackDto>> getAllTracks() {
        List<TrackDto> tracks = new ArrayList<>();
        
        try {
            Path musicPath = getMusicPath();
            System.out.println("Looking for music in: " + musicPath.toAbsolutePath());

            if (!Files.exists(musicPath) || !Files.isDirectory(musicPath)) {
                logger.info("Music folder not found");
                return ResponseEntity.ok(tracks);
            }

            File musicDir = musicPath.toFile();
            File[] files = musicDir.listFiles((dir, name) -> name.toLowerCase().endsWith(".mp3"));
            
            if (files == null || files.length == 0) {
                logger.info("No MP3 files found");
                return ResponseEntity.ok(tracks);
            }

            logger.info("Found " + files.length + " MP3 files");

            for (File file : files) {
                String fileName = file.getName();
                String displayName = formatTrackName(fileName);
                
                long size = file.length();
                int estimatedSeconds = (int) (size * 8 / 128000);
                int minutes = Math.max(1, estimatedSeconds / 60);
                
                TrackDto track = new TrackDto();
                track.setId(fileName.hashCode() & Integer.MAX_VALUE);
                track.setFileName(fileName);
                track.setTitle(displayName);
                track.setDuration(minutes + " min");
                track.setDurationSeconds(estimatedSeconds);
                track.setCategory(categorizeTrack(fileName));
                track.setUrl("/api/music/stream/" + fileName);
                
                tracks.add(track);
                logger.info("Added track: " + displayName);
            }

            return ResponseEntity.ok(tracks);
        } catch (Exception e) {
            System.err.println("Error loading tracks: " + e.getMessage());
            return ResponseEntity.ok(tracks);
        }
    }

    @GetMapping("/stream/{fileName:.+}")
    public ResponseEntity<Resource> streamMusic(@PathVariable String fileName) {
        try {
            Path musicPath = getMusicPath();
            Path filePath = musicPath.resolve(fileName);
            File file = filePath.toFile();

            logger.info("Streaming file: " + filePath.toAbsolutePath());

            if (!file.exists() || !file.isFile()) {
                logger.info("File not found: " + filePath.toAbsolutePath());
                return ResponseEntity.notFound().build();
            }

            Resource resource = new FileSystemResource(file);
            
            return ResponseEntity.ok()
                    .contentType(MediaType.parseMediaType("audio/mpeg"))
                    .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + fileName + "\"")
                    .header(HttpHeaders.ACCEPT_RANGES, "bytes")
                    .header(HttpHeaders.CONTENT_LENGTH, String.valueOf(file.length()))
                    .body(resource);
        } catch (Exception e) {
            System.err.println("Error streaming file: " + e.getMessage());
            return ResponseEntity.internalServerError().build();
        }
    }

    private String formatTrackName(String fileName) {
        String name = fileName.replaceAll("(?i)\\.mp3$", "");
        name = name.replaceAll("-\\d+$", "");
        String[] words = name.split("-");
        StringBuilder result = new StringBuilder();
        for (String word : words) {
            if (!word.isEmpty()) {
                result.append(Character.toUpperCase(word.charAt(0)))
                      .append(word.substring(1).toLowerCase())
                      .append(" ");
            }
        }
        return result.toString().trim();
    }

    private String categorizeTrack(String fileName) {
        String lowerName = fileName.toLowerCase();
        if (lowerName.contains("healing") || lowerName.contains("bowl") || lowerName.contains("tibetan") || lowerName.contains("sacred") || lowerName.contains("frequency")) {
            return "meditation";
        } else if (lowerName.contains("motivational") || lowerName.contains("uplifting") || lowerName.contains("positive") || lowerName.contains("happy")) {
            return "motivation";
        } else if (lowerName.contains("balance") || lowerName.contains("equilibrium") || lowerName.contains("soundscape")) {
            return "relaxation";
        } else {
            return "ambient";
        }
    }

    // Simple DTO class
    public static class TrackDto {
        private int id;
        private String fileName;
        private String title;
        private String duration;
        private int durationSeconds;
        private String category;
        private String url;

        public int getId() { return id; }
        public void setId(int id) { this.id = id; }
        
        public String getFileName() { return fileName; }
        public void setFileName(String fileName) { this.fileName = fileName; }
        
        public String getTitle() { return title; }
        public void setTitle(String title) { this.title = title; }
        
        public String getDuration() { return duration; }
        public void setDuration(String duration) { this.duration = duration; }
        
        public int getDurationSeconds() { return durationSeconds; }
        public void setDurationSeconds(int durationSeconds) { this.durationSeconds = durationSeconds; }
        
        public String getCategory() { return category; }
        public void setCategory(String category) { this.category = category; }
        
        public String getUrl() { return url; }
        public void setUrl(String url) { this.url = url; }
    }
}
