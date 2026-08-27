package com.rehearsal.api.controller;

import com.rehearsal.api.domain.PracticeSession;
import com.rehearsal.api.dto.MatchRequest;
import com.rehearsal.api.service.MatchService;
import com.rehearsal.api.repository.PracticeSessionRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/sessions")
public class PracticeSessionController {

    private final MatchService matchService;
    private final PracticeSessionRepository practiceSessionRepository;

    public PracticeSessionController(MatchService matchService, PracticeSessionRepository practiceSessionRepository) {
        this.matchService = matchService;
        this.practiceSessionRepository = practiceSessionRepository;
    }

    @PostMapping("/match")
    public ResponseEntity<PracticeSession> createSessionAndMatch(@RequestBody MatchRequest request, Authentication authentication) {
        String userEmail = authentication.getName();
        PracticeSession session = matchService.createSessionAndMatch(userEmail, request.getResumeId(), request.getJobDescriptionText());
        return ResponseEntity.ok(session);
    }

    @GetMapping("/{id}")
    public ResponseEntity<PracticeSession> getSession(@PathVariable Long id, Authentication authentication) {
        return practiceSessionRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}
