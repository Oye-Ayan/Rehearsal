package com.rehearsal.api.controller;

// Previous: Basic controller with match, getSession, history, and summary endpoints.

import com.rehearsal.api.domain.PracticeSession;
import com.rehearsal.api.domain.Question;
import com.rehearsal.api.dto.MatchRequest;
import com.rehearsal.api.dto.QuickMatchRequest;
import com.rehearsal.api.service.MatchService;
import com.rehearsal.api.service.PdfExportService;
import com.rehearsal.api.repository.PracticeSessionRepository;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/sessions")
public class PracticeSessionController {

    private final MatchService matchService;
    private final PracticeSessionRepository practiceSessionRepository;
    private final PdfExportService pdfExportService;

    public PracticeSessionController(MatchService matchService, PracticeSessionRepository practiceSessionRepository, PdfExportService pdfExportService) {
        this.matchService = matchService;
        this.practiceSessionRepository = practiceSessionRepository;
        this.pdfExportService = pdfExportService;
    }

    @PostMapping("/match")
    public ResponseEntity<PracticeSession> createSessionAndMatch(@RequestBody MatchRequest request, Authentication authentication) {
        String userEmail = authentication.getName();
        PracticeSession session = matchService.createSessionAndMatch(userEmail, request.getResumeId(), request.getJobDescriptionText());
        return ResponseEntity.ok(session);
    }

    @PostMapping("/quick-match")
    public ResponseEntity<PracticeSession> createQuickSession(@RequestBody QuickMatchRequest request, Authentication authentication) {
        String userEmail = authentication.getName();
        PracticeSession session = matchService.createSessionWithoutResume(userEmail, request.getJobDescriptionText(), request.getUserDetails());
        return ResponseEntity.ok(session);
    }

    @GetMapping("/{id}")
    public ResponseEntity<PracticeSession> getSession(@PathVariable Long id, Authentication authentication) {
        return practiceSessionRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/history")
    public ResponseEntity<List<PracticeSession>> getSessionHistory(Authentication authentication) {
        String userEmail = authentication.getName();
        List<PracticeSession> sessions = practiceSessionRepository.findByUserEmailOrderByCreatedAtDesc(userEmail);
        return ResponseEntity.ok(sessions);
    }

    @PostMapping("/{id}/summary")
    public ResponseEntity<PracticeSession> generateSessionSummary(@PathVariable Long id, Authentication authentication, @Autowired com.rehearsal.api.service.GroqFeedbackService groqService) {
        PracticeSession session = practiceSessionRepository.findById(id).orElse(null);
        if (session == null) return ResponseEntity.notFound().build();

        if (session.getActionPlan() != null && !session.getActionPlan().isEmpty()) {
            return ResponseEntity.ok(session); // already generated
        }

        StringBuilder qaBuilder = new StringBuilder();
        for (com.rehearsal.api.domain.Question q : session.getQuestions()) {
            if (q.getAnswer() != null && q.getAnswer().getTranscriptText() != null && !q.getAnswer().getTranscriptText().trim().isEmpty()) {
                qaBuilder.append("Q: ").append(q.getText()).append("\n");
                qaBuilder.append("A: ").append(q.getAnswer().getTranscriptText()).append("\n\n");
            }
        }

        if (qaBuilder.length() == 0) {
            session.setActionPlan("No answers recorded. Ensure you grant Microphone permission to capture your answers.");
            practiceSessionRepository.save(session);
            return ResponseEntity.ok(session);
        }

        String actionPlan = groqService.generateActionPlan(qaBuilder.toString());
        session.setActionPlan(actionPlan);
        practiceSessionRepository.save(session);
        return ResponseEntity.ok(session);
    }

    // ── More Questions ──
    @PostMapping("/{id}/more-questions")
    public ResponseEntity<List<Question>> generateMoreQuestions(@PathVariable Long id, Authentication authentication) {
        PracticeSession session = practiceSessionRepository.findById(id).orElse(null);
        if (session == null) return ResponseEntity.notFound().build();
        
        List<Question> newQuestions = matchService.generateMoreQuestions(session, 3);
        return ResponseEntity.ok(newQuestions);
    }

    // ── PDF Export ──
    @GetMapping("/{id}/export-pdf")
    public ResponseEntity<byte[]> exportSessionPdf(@PathVariable Long id, Authentication authentication) {
        PracticeSession session = practiceSessionRepository.findById(id).orElse(null);
        if (session == null) return ResponseEntity.notFound().build();

        byte[] pdfBytes = pdfExportService.generateSessionPdf(session);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_PDF);
        headers.setContentDispositionFormData("attachment", "rehearsal_session_" + id + ".pdf");

        return ResponseEntity.ok().headers(headers).body(pdfBytes);
    }

    // ── Delete Session ──
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteSession(@PathVariable Long id, Authentication authentication) {
        PracticeSession session = practiceSessionRepository.findById(id).orElse(null);
        if (session == null) return ResponseEntity.notFound().build();
        
        practiceSessionRepository.delete(session);
        return ResponseEntity.ok().build();
    }

    // ── Pin/Unpin Session ──
    @PutMapping("/{id}/pin")
    public ResponseEntity<PracticeSession> togglePin(@PathVariable Long id, Authentication authentication) {
        PracticeSession session = practiceSessionRepository.findById(id).orElse(null);
        if (session == null) return ResponseEntity.notFound().build();
        
        session.setPinned(!session.isPinned());
        practiceSessionRepository.save(session);
        return ResponseEntity.ok(session);
    }
}
