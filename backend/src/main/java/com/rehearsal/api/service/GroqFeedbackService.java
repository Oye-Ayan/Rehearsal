package com.rehearsal.api.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class GroqFeedbackService {

    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;

    @Value("${groq.api.url}")
    private String apiUrl;

    @Value("${groq.api.key}")
    private String apiKey;

    @Value("${groq.model}")
    private String modelName;

    public GroqFeedbackService(RestTemplate restTemplate, ObjectMapper objectMapper) {
        this.restTemplate = restTemplate;
        this.objectMapper = objectMapper;
    }

    public String generateFeedback(String questionText, String transcriptText) {
        if (transcriptText == null || transcriptText.trim().isEmpty()) {
            return "No transcript provided to generate feedback.";
        }

        String prompt = buildPrompt(questionText, transcriptText);
        
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(apiKey);

        Map<String, Object> message = new HashMap<>();
        message.put("role", "user");
        message.put("content", prompt);

        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("model", modelName);
        requestBody.put("messages", List.of(message));
        requestBody.put("temperature", 0.7);
        // We can just get standard text back, no need for JSON mode
        
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

        try {
            ResponseEntity<String> response = restTemplate.postForEntity(apiUrl, entity, String.class);
            return parseResponse(response.getBody());
        } catch (Exception e) {
            e.printStackTrace();
            return "Unable to generate AI feedback at this time. Keep practicing your delivery and pacing.";
        }
    }

    private String buildPrompt(String question, String transcript) {
        return String.format(
            "You are an expert interview coach. A candidate was asked the following interview question:\n" +
            "Question: \"%s\"\n\n" +
            "They answered with this transcript:\n" +
            "Answer: \"%s\"\n\n" +
            "Provide 2-3 sentences of highly constructive feedback on their answer. " +
            "Do NOT judge their hireability. Focus purely on structure, clarity, and how well they answered the prompt.", 
            question, transcript
        );
    }

    private String parseResponse(String jsonResponse) {
        try {
            JsonNode root = objectMapper.readTree(jsonResponse);
            return root.path("choices").get(0).path("message").path("content").asText().trim();
        } catch (JsonProcessingException e) {
            e.printStackTrace();
            return "Unable to parse AI feedback response.";
        }
    }
}
