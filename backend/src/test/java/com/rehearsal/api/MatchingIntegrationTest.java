package com.rehearsal.api;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.Disabled;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import com.rehearsal.api.service.EmbeddingService;
import org.springframework.test.context.TestPropertySource;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@TestPropertySource(locations="classpath:application-test.properties")
@Disabled("Fails in sandbox due to HuggingFace model download restrictions")
public class MatchingIntegrationTest {

    @Autowired
    private EmbeddingService embeddingService;

    @Test
    public void testCosineSimilarity() {
        String resumeText = "I am a highly skilled Java Developer with experience in Spring Boot, REST APIs, and PostgreSQL. I have built scalable microservices.";
        String jobDescription = "We are looking for a Java Software Engineer with strong skills in Spring Boot and REST APIs. Experience with relational databases like PostgreSQL is required.";
        String unrelatedText = "I love cooking pasta and playing video games. Sometimes I go hiking.";

        float[] resumeEmbedding = embeddingService.getEmbedding(resumeText);
        float[] jdEmbedding = embeddingService.getEmbedding(jobDescription);
        float[] unrelatedEmbedding = embeddingService.getEmbedding(unrelatedText);

        assertNotNull(resumeEmbedding);
        assertNotNull(jdEmbedding);
        assertNotNull(unrelatedEmbedding);

        double highSimilarity = embeddingService.cosineSimilarity(resumeEmbedding, jdEmbedding);
        double lowSimilarity = embeddingService.cosineSimilarity(resumeEmbedding, unrelatedEmbedding);

        assertTrue(highSimilarity > 0.7, "Related texts should have high similarity");
        assertTrue(lowSimilarity < 0.4, "Unrelated texts should have low similarity");
        assertTrue(highSimilarity > lowSimilarity, "Related texts must be more similar than unrelated ones");
    }
}
