package com.rehearsal.api.service;

import com.rehearsal.api.domain.PracticeSession;
import com.rehearsal.api.domain.Question;
import com.rehearsal.api.domain.Resume;
import com.rehearsal.api.domain.User;
import com.rehearsal.api.repository.PracticeSessionRepository;
import com.rehearsal.api.repository.QuestionRepository;
import com.rehearsal.api.repository.ResumeRepository;
import com.rehearsal.api.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class MatchService {

    private final EmbeddingService embeddingService;
    private final ResumeRepository resumeRepository;
    private final PracticeSessionRepository sessionRepository;
    private final UserRepository userRepository;
    private final QuestionGenerationService questionGenerationService;
    private final QuestionRepository questionRepository;

    public MatchService(EmbeddingService embeddingService, ResumeRepository resumeRepository, PracticeSessionRepository sessionRepository, UserRepository userRepository, QuestionGenerationService questionGenerationService, QuestionRepository questionRepository) {
        this.embeddingService = embeddingService;
        this.resumeRepository = resumeRepository;
        this.sessionRepository = sessionRepository;
        this.userRepository = userRepository;
        this.questionGenerationService = questionGenerationService;
        this.questionRepository = questionRepository;
    }

    @Transactional
    public PracticeSession createSessionAndMatch(String userEmail, Long resumeId, String jobDescriptionText) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        Resume resume = resumeRepository.findById(resumeId)
                .orElseThrow(() -> new IllegalArgumentException("Resume not found"));

        if (!resume.getUser().getId().equals(user.getId())) {
            throw new IllegalArgumentException("Unauthorized access to resume");
        }

        // Get Embeddings
        float[] resumeEmbedding = embeddingService.getEmbedding(resume.getRawText());
        float[] jdEmbedding = embeddingService.getEmbedding(jobDescriptionText);

        // Compute Match Score (0 to 100)
        double similarity = embeddingService.cosineSimilarity(resumeEmbedding, jdEmbedding);
        int matchScore = (int) Math.round(Math.max(0, Math.min(1.0, similarity)) * 100);

        PracticeSession session = new PracticeSession();
        session.setUser(user);
        session.setResume(resume);
        session.setJobDescriptionText(jobDescriptionText);
        session.setMatchScore(matchScore);

        session = sessionRepository.save(session);
        
        // Phase 2: Generate Questions using Groq LLM
        List<Question> questions = questionGenerationService.generateQuestions(session, resume.getRawText(), jobDescriptionText, 5);
        questions = questionRepository.saveAll(questions);
        session.setQuestions(questions);
        
        return session;
    }
}
