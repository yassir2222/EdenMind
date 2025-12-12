package org.example.edenmind.controller;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.MockedStatic;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import static org.mockito.ArgumentMatchers.any;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class FileUploadControllerTest {

    private MockMvc mockMvc;

    @InjectMocks
    private FileUploadController fileUploadController;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        mockMvc = MockMvcBuilders.standaloneSetup(fileUploadController).build();
    }

    @Test
    void testUploadFile_Success_DirectoryExists() throws Exception {
        MockMultipartFile file = new MockMultipartFile("file", "test.txt", "text/plain", "content".getBytes());
        
        try (MockedStatic<Files> mockedFiles = Mockito.mockStatic(Files.class)) {
            mockedFiles.when(() -> Files.exists(any(Path.class))).thenReturn(true);
            mockedFiles.when(() -> Files.copy(any(InputStream.class), any(Path.class))).thenReturn(1L);

            mockMvc.perform(multipart("/api/uploads").file(file))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.url").exists());
        }
    }

    @Test
    void testUploadFile_Success_DirectoryDoesNotExist() throws Exception {
        MockMultipartFile file = new MockMultipartFile("file", "test.txt", "text/plain", "content".getBytes());

        try (MockedStatic<Files> mockedFiles = Mockito.mockStatic(Files.class)) {
            mockedFiles.when(() -> Files.exists(any(Path.class))).thenReturn(false);
            mockedFiles.when(() -> Files.createDirectories(any(Path.class))).thenReturn(Paths.get("uploads"));
            mockedFiles.when(() -> Files.copy(any(InputStream.class), any(Path.class))).thenReturn(1L);

            mockMvc.perform(multipart("/api/uploads").file(file))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.url").exists());
            
            mockedFiles.verify(() -> Files.createDirectories(any(Path.class)));
        }
    }

    @Test
    void testUploadFile_IOException() throws Exception {
        MockMultipartFile file = new MockMultipartFile("file", "test.txt", "text/plain", "content".getBytes());

        try (MockedStatic<Files> mockedFiles = Mockito.mockStatic(Files.class)) {
            mockedFiles.when(() -> Files.exists(any(Path.class))).thenReturn(true);
            mockedFiles.when(() -> Files.copy(any(InputStream.class), any(Path.class))).thenThrow(new IOException("Disk error"));

            mockMvc.perform(multipart("/api/uploads").file(file))
                    .andExpect(status().isInternalServerError())
                    .andExpect(jsonPath("$.error").value("Failed to upload file"));
        }
    }
}

