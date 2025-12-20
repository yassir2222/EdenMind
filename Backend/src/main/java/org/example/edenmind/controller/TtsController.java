package org.example.edenmind.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.Map;

@RestController
@RequestMapping("/api/tts")
@CrossOrigin(origins = "*")
public class TtsController {

    private static final String ELEVENLABS_API_KEY = "sk_469186e434f40cb3421f09d0759049f93446250c935efb10";
    private static final String ELEVENLABS_BASE_URL = "https://api.elevenlabs.io/v1";

    // Bella - Soft, warm, cheerful young female voice
    private static final String DEFAULT_VOICE_ID = "EXAVITQu4vr4xnSDxMaL";

    private final HttpClient httpClient = HttpClient.newHttpClient();
    private final ObjectMapper objectMapper = new ObjectMapper();

    @PostMapping("/speak")
    public ResponseEntity<byte[]> speak(@RequestBody Map<String, Object> request) {
        try {
            String text = (String) request.getOrDefault("text", "");
            String voiceId = (String) request.getOrDefault("voiceId", DEFAULT_VOICE_ID);

            if (text.isEmpty()) {
                return ResponseEntity.badRequest().build();
            }

            Map<String, Object> body = Map.of(
                    "text", text,
                    "model_id", "eleven_multilingual_v2",
                    "voice_settings", Map.of(
                            "stability", 0.4,
                            "similarity_boost", 0.8,
                            "style", 0.7,
                            "use_speaker_boost", true));

            String jsonBody = objectMapper.writeValueAsString(body);

            HttpRequest elevenLabsRequest = HttpRequest.newBuilder()
                    .uri(URI.create(ELEVENLABS_BASE_URL + "/text-to-speech/" + voiceId))
                    .header("Accept", "audio/mpeg")
                    .header("Content-Type", "application/json")
                    .header("xi-api-key", ELEVENLABS_API_KEY)
                    .POST(HttpRequest.BodyPublishers.ofString(jsonBody))
                    .build();

            HttpResponse<byte[]> response = httpClient.send(elevenLabsRequest, HttpResponse.BodyHandlers.ofByteArray());

            if (response.statusCode() == 200) {
                HttpHeaders responseHeaders = new HttpHeaders();
                responseHeaders.setContentType(MediaType.parseMediaType("audio/mpeg"));
                return new ResponseEntity<>(response.body(), responseHeaders, HttpStatus.OK);
            } else {
                System.err.println("ElevenLabs Error: " + response.statusCode() + " - " + new String(response.body()));
                return ResponseEntity.status(response.statusCode()).build();
            }

        } catch (Exception e) {
            System.err.println("TTS Error: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}
