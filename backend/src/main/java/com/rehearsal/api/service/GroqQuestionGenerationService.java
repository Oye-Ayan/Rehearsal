package com.rehearsal.api.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.rehearsal.api.domain.PracticeSession;
import com.rehearsal.api.domain.Question;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class GroqQuestionGenerationService implements QuestionGenerationService {

    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;

    @Value("${groq.api.url}")
    private String apiUrl;

    @Value("${groq.api.key}")
    private String apiKey;

    @Value("${groq.model}")
    private String modelName;

    public GroqQuestionGenerationService(RestTemplate restTemplate, ObjectMapper objectMapper) {
        this.restTemplate = restTemplate;
        this.objectMapper = objectMapper;
    }

    @Override
    public List<Question> generateQuestions(PracticeSession session, String resumeText, String jobDescriptionText, int numQuestions) {
        
        String prompt = buildPrompt(resumeText, jobDescriptionText, numQuestions);
        
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
        requestBody.put("response_format", Map.of("type", "json_object"));

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

        try {
            ResponseEntity<String> response = restTemplate.postForEntity(apiUrl, entity, String.class);
            return parseResponse(response.getBody(), session);
        } catch (Exception e) {
            e.printStackTrace();
            return generateFallbackQuestions(session, numQuestions);
        }
    }

    private String buildPrompt(String resume, String jd, int num) {
        return String.format(
            "You are an expert technical interviewer. I will provide a candidate's resume and a job description. " +
            "Your task is to generate %d highly relevant interview questions tailored to assessing this candidate's fit for the role. " +
            "Output the response in strict JSON format like this:\n" +
            "{\n" +
            "  \"questions\": [\n" +
            "    {\"content\": \"Question 1 text here\", \"type\": \"TECHNICAL\"},\n" +
            "    {\"content\": \"Question 2 text here\", \"type\": \"BEHAVIORAL\"}\n" +
            "  ]\n" +
            "}\n\n" +
            "Resume:\n%s\n\nJob Description:\n%s", 
            num, resume, jd
        );
    }

    private List<Question> parseResponse(String jsonResponse, PracticeSession session) {
        List<Question> questions = new ArrayList<>();
        try {
            JsonNode root = objectMapper.readTree(jsonResponse);
            String content = root.path("choices").get(0).path("message").path("content").asText();
            
            JsonNode questionsNode = objectMapper.readTree(content).path("questions");
            if (questionsNode.isArray()) {
                int order = 1;
                for (JsonNode qNode : questionsNode) {
                    Question q = new Question();
                    q.setText(qNode.path("content").asText());
                    q.setCategory(qNode.path("type").asText("GENERAL"));
                    q.setOrderIndex(order++);
                    q.setSession(session);
                    questions.add(q);
                }
            }
        } catch (JsonProcessingException e) {
            e.printStackTrace();
        }
        return questions;
    }

    private List<Question> generateFallbackQuestions(PracticeSession session, int num) {
        List<Question> questions = new ArrayList<>();
        for (int i = 1; i <= num; i++) {
            Question q = new Question();
            q.setText("Could you walk me through a complex problem you solved recently?");
            q.setCategory("BEHAVIORAL");
            q.setOrderIndex(i);
            q.setSession(session);
            questions.add(q);
        }
        return questions;
    }
}
