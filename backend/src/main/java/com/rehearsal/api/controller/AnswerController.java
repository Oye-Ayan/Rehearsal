package com.rehearsal.api.controller;

import com.rehearsal.api.domain.Answer;
import com.rehearsal.api.dto.AnswerRequest;
import com.rehearsal.api.service.AnswerService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/questions")
@CrossOrigin(origins = "*", maxAge = 3600)
public class AnswerController {

    private final AnswerService answerService;

    public AnswerController(AnswerService answerService) {
        this.answerService = answerService;
    }

    @PostMapping("/{questionId}/answers")
    public ResponseEntity<?> submitAnswer(
            Authentication authentication,
            @PathVariable Long questionId,
            @RequestBody AnswerRequest request) {
        
        try {
            Answer savedAnswer = answerService.saveAnswer(authentication.getName(), questionId, request);
            return ResponseEntity.ok(savedAnswer);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error: " + e.getMessage());
        }
    }
}
