package org.example.edenmind.rag;

import dev.langchain4j.data.document.Document;
import dev.langchain4j.data.segment.TextSegment;
import dev.langchain4j.model.embedding.EmbeddingModel;
import dev.langchain4j.store.embedding.EmbeddingStore;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;

import java.io.File;

import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

class DocumentLoaderTest {

    @Mock
    private EmbeddingStore<TextSegment> embeddingStore;

    @Mock
    private EmbeddingModel embeddingModel;

    @Mock
    private ResourceLoader resourceLoader;

    @Mock
    private Resource resource;

    @InjectMocks
    private DocumentLoader documentLoader;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void ingestDocuments_ResourceExists_IngestsDocument() throws Exception {
        // Arrange
        when(resourceLoader.getResource(anyString())).thenReturn(resource);
        when(resource.exists()).thenReturn(true);
        
        // Mock file behavior
        File tempFile = File.createTempFile("test_anxiety", ".txt"); // Throws IOException
        tempFile.deleteOnExit();
        when(resource.getFile()).thenReturn(tempFile); // Throws IOException

        // Act
        documentLoader.ingestDocuments();

        // Assert
        verify(resourceLoader).getResource(anyString());
        verify(resource).getFile(); // Throws IOException
    }

    @Test
    void ingestDocuments_ResourceDoesNotExist_DoesNothing() throws Exception { // Added throws Exception
        // Arrange
        when(resourceLoader.getResource(anyString())).thenReturn(resource);
        when(resource.exists()).thenReturn(false);

        // Act
        documentLoader.ingestDocuments();

        // Assert
        verify(resourceLoader).getResource(anyString());
        verify(resource, never()).getFile(); // Throws IOException
    }

    @Test
    void ingestDocuments_ExceptionThrown_LogsError() {
        // Arrange
        when(resourceLoader.getResource(anyString())).thenThrow(new RuntimeException("Loader Error"));

        // Act
        // This should not throw, but catch and log
        documentLoader.ingestDocuments();

        // Assert
        verify(resourceLoader).getResource(anyString());
    }
}
