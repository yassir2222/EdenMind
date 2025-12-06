package org.example.edenmind.rag;

import dev.langchain4j.data.document.Document;
import dev.langchain4j.data.document.loader.FileSystemDocumentLoader;
import dev.langchain4j.data.document.parser.TextDocumentParser;
import dev.langchain4j.data.segment.TextSegment;
import dev.langchain4j.model.embedding.EmbeddingModel;
import dev.langchain4j.store.embedding.EmbeddingStore;
import dev.langchain4j.store.embedding.EmbeddingStoreIngestor;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.stereotype.Component;

import java.io.File;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

@Component
public class DocumentLoader {

    @Autowired
    private EmbeddingStore<TextSegment> embeddingStore;

    @Autowired
    private EmbeddingModel embeddingModel;

    @Autowired
    private ResourceLoader resourceLoader;

    @PostConstruct
    public void ingestDocuments() {
        try {
            // Load documents from resources/documents
            // Note: For simplicity in this demo, we assume a directory exists or we load a specific file
            // In a real app, you might want to load from a DB or external storage
            
            String documentPath = "classpath:documents/anxiety_info.txt";
            Resource resource = resourceLoader.getResource(documentPath);
            
            if (resource.exists()) {
                 File file = resource.getFile();
                 Document document = FileSystemDocumentLoader.loadDocument(file.toPath(), new TextDocumentParser());
                 
                 EmbeddingStoreIngestor ingestor = EmbeddingStoreIngestor.builder()
                        .embeddingStore(embeddingStore)
                        .embeddingModel(embeddingModel)
                        .build();
                 
                 ingestor.ingest(document);
                 System.out.println("Document ingested: " + file.getName());
            } else {
                System.out.println("No documents found to ingest at " + documentPath);
            }

        } catch (Exception e) {
            System.err.println("Error ingesting documents: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
