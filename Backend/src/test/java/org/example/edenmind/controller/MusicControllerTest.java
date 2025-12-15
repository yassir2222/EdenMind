package org.example.edenmind.controller;
import org.example.edenmind.controller.MusicController.TrackDto;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.core.io.Resource;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Comparator;
import java.util.stream.Stream;

import static org.hamcrest.Matchers.*;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class MusicControllerTest {

    private MockMvc mockMvc;
    private MusicController musicController;
    private final Path MUSIC_DIR = Paths.get("music");

    @BeforeEach
    void setUp() throws IOException {
        musicController = new MusicController();
        mockMvc = MockMvcBuilders.standaloneSetup(musicController).build();

        // Nettoyage préventif et création du dossier music pour le test
        deleteMusicDirectory();
        Files.createDirectories(MUSIC_DIR);
    }

    @AfterEach
    void tearDown() throws IOException {
        // Nettoyage après chaque test
        deleteMusicDirectory();
    }

    // Helper pour supprimer le dossier récursivement
    private void deleteMusicDirectory() throws IOException {
        if (Files.exists(MUSIC_DIR)) {
            try (Stream<Path> walk = Files.walk(MUSIC_DIR)) {
                walk.sorted(Comparator.reverseOrder())
                        .map(Path::toFile)
                        .forEach(File::delete);
            }
        }
    }

    // Helper pour créer un fichier dummy MP3
    private void createDummyMp3(String filename, int sizeBytes) throws IOException {
        Path file = MUSIC_DIR.resolve(filename);
        byte[] content = new byte[sizeBytes]; // Contenu vide mais taille définie
        Files.write(file, content);
    }

    @Test
    void testGetAllTracks_Success() throws Exception {
        // Arrange : Création de fichiers avec différents noms pour tester le parsing et la catégorisation

        // 1. Meditation (contient "healing") + Formatage (tirets -> espaces)
        createDummyMp3("healing-frequency-track.mp3", 128000 * 60); // ~1 minute (128kbps approx)

        // 2. Motivation (contient "happy") + Formatage (suppression numéros finaux)
        createDummyMp3("happy-morning-123.mp3", 128000 * 120); // ~2 minutes

        // 3. Relaxation (contient "balance")
        createDummyMp3("chakra-balance.mp3", 1000); // Très court

        // 4. Ambient (défaut)
        createDummyMp3("random-noise.mp3", 1000);

        // Act & Assert
        mockMvc.perform(get("/api/music/tracks"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(4)))

                // Vérification Track 1 : Categorisation Meditation
                .andExpect(jsonPath("$[?(@.fileName == 'healing-frequency-track.mp3')].category").value("meditation"))
                .andExpect(jsonPath("$[?(@.fileName == 'healing-frequency-track.mp3')].title").value("Healing Frequency Track"))
                .andExpect(jsonPath("$[?(@.fileName == 'healing-frequency-track.mp3')].duration").value("8 min"))

                // Vérification Track 2 : Categorisation Motivation + suppression suffixe num
                .andExpect(jsonPath("$[?(@.fileName == 'happy-morning-123.mp3')].category").value("motivation"))
                .andExpect(jsonPath("$[?(@.fileName == 'happy-morning-123.mp3')].title").value("Happy Morning"))
                .andExpect(jsonPath("$[?(@.fileName == 'happy-morning-123.mp3')].duration").value("16 min"))

                // Vérification Track 3 : Relaxation
                .andExpect(jsonPath("$[?(@.fileName == 'chakra-balance.mp3')].category").value("relaxation"))

                // Vérification Track 4 : Ambient (défaut)
                .andExpect(jsonPath("$[?(@.fileName == 'random-noise.mp3')].category").value("ambient"));
    }

    @Test
    void testGetAllTracks_EmptyDirectory() throws Exception {
        // Le dossier existe mais est vide
        mockMvc.perform(get("/api/music/tracks"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(0)));
    }

    @Test
    void testGetAllTracks_NoDirectory() throws Exception {
        // Suppression du dossier pour simuler son absence
        deleteMusicDirectory();

        mockMvc.perform(get("/api/music/tracks"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(0)));
    }

    @Test
    void testStreamMusic_Success() throws Exception {
        // Arrange
        String filename = "stream-test.mp3";
        createDummyMp3(filename, 1024);

        // Act & Assert
        mockMvc.perform(get("/api/music/stream/" + filename))
                .andExpect(status().isOk())
                .andExpect(content().contentType("audio/mpeg"))
                .andExpect(header().string("Content-Disposition", "inline; filename=\"" + filename + "\""))
                .andExpect(header().string("Content-Length", "1024"));
    }

    @Test
    void testStreamMusic_FileNotFound() throws Exception {
        // Arrange : Le fichier n'existe pas

        // Act & Assert
        mockMvc.perform(get("/api/music/stream/non-existent.mp3"))
                .andExpect(status().isNotFound());
    }

    @Test
    void testStreamMusic_Error() throws Exception {
        // Test de la branche catch(Exception) du stream
        // On passe un nom de fichier invalide qui pourrait causer une erreur système ou path traversal (selon l'OS)
        // Note : C'est difficile à provoquer sans Mocking statique, mais on teste la robustesse.
        // Ici, on vérifie surtout que le endpoint ne crash pas si on envoie n'importe quoi.

        // Si on envoie un null byte par exemple, ou un chemin vide (si le router le permet)
        // Pour ce test simple, on s'assure juste que le 404 est géré,
        // ou 500 si on arrivait à casser le Path.resolve (rare sans mock).

        // Une manière de "tricker" le test pour couvrir le catch serait complexe sans Mockito-inline.
        // Ce test-ci valide le comportement standard "Not Found".
        mockMvc.perform(get("/api/music/stream/../secret.txt"))
                .andExpect(status().isNotFound());
        // Note: Spring Security ou Tomcat bloquent souvent le path traversal avant,
        // donc ce test valide surtout la sécurité par défaut.
    }

    /**
     * Test direct des Getters/Setters du DTO pour atteindre 100% de couverture sur la classe interne
     */
    @Test
    void testTrackDto() {
        TrackDto dto = new TrackDto();

        dto.setId(1);
        assertEquals(1, dto.getId());

        dto.setFileName("file.mp3");
        assertEquals("file.mp3", dto.getFileName());

        dto.setTitle("Title");
        assertEquals("Title", dto.getTitle());

        dto.setDuration("3 min");
        assertEquals("3 min", dto.getDuration());

        dto.setDurationSeconds(180);
        assertEquals(180, dto.getDurationSeconds());

        dto.setCategory("ambient");
        assertEquals("ambient", dto.getCategory());

        dto.setUrl("http://url");
        assertEquals("http://url", dto.getUrl());
    }
}
