package org.example.edenmind.Exception;
import org.example.edenmind.exception.GlobalExceptionHandler;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.MockitoAnnotations;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.time.LocalDateTime;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class GlobalExceptionHandlerTest {

    @InjectMocks
    private GlobalExceptionHandler globalExceptionHandler;

    private MockMvc mockMvc;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);

        // On configure MockMvc avec un contrôleur de test ET notre handler d'exception
        mockMvc = MockMvcBuilders.standaloneSetup(new TestController())
                .setControllerAdvice(globalExceptionHandler)
                .build();
    }

    /**
     * Test direct de la méthode Java (sans passer par MockMvc)
     * Utile pour vérifier les détails internes de la Map retournée
     */
    @Test
    void testHandleGlobalException_DirectCall() {
        // Arrange
        String errorMessage = "Erreur critique";
        Exception exception = new RuntimeException(errorMessage);

        // Act
        ResponseEntity<Object> response = globalExceptionHandler.handleGlobalException(exception);

        // Assert
        assertNotNull(response);
        assertEquals(HttpStatus.INTERNAL_SERVER_ERROR, response.getStatusCode());

        @SuppressWarnings("unchecked")
        Map<String, Object> body = (Map<String, Object>) response.getBody();

        assertNotNull(body);
        assertEquals(errorMessage, body.get("message"));
        assertEquals("Internal Server Error", body.get("error"));
        assertNotNull(body.get("timestamp"));
        assertTrue(body.get("timestamp") instanceof LocalDateTime);
    }

    /**
     * Test via MockMvc pour simuler le cycle de vie complet Spring MVC
     * Vérifie que l'exception est bien interceptée lors d'une requête HTTP
     */
    @Test
    void testHandleGlobalException_ViaMockMvc() throws Exception {
        mockMvc.perform(get("/test/exception"))
                .andExpect(status().isInternalServerError())
                .andExpect(jsonPath("$.message").value("Erreur simulée pour le test"))
                .andExpect(jsonPath("$.error").value("Internal Server Error"))
                .andExpect(jsonPath("$.timestamp").exists());
    }

    // Contrôleur interne factice pour déclencher l'exception
    @RestController
    static class TestController {
        @GetMapping("/test/exception")
        public void throwException() {
            throw new RuntimeException("Erreur simulée pour le test");
        }
    }
}
