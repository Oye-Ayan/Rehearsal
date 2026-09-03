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
        
        List<String> keywords = extractKeywords(resume.getRawText(), jobDescriptionText);
        session.setMatchKeywords(String.join(", ", keywords));

        session = sessionRepository.save(session);
        
        // Phase 2: Generate Questions using Groq LLM
        List<Question> questions = questionGenerationService.generateQuestions(session, resume.getRawText(), jobDescriptionText, 5);
        questions = questionRepository.saveAll(questions);
        session.setQuestions(questions);
        
        return session;
    }

    @Transactional
    public PracticeSession createSessionWithoutResume(String userEmail, String jobDescriptionText, String userDetails) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        PracticeSession session = new PracticeSession();
        session.setUser(user);
        session.setResume(null);
        session.setJobDescriptionText(jobDescriptionText);
        session.setMatchScore(0); // No resume to match against

        session = sessionRepository.save(session);

        // Use userDetails as the "resume text" for question generation context
        String contextText = (userDetails != null && !userDetails.trim().isEmpty())
                ? userDetails
                : "The candidate did not provide additional details.";
        List<Question> questions = questionGenerationService.generateQuestions(session, contextText, jobDescriptionText, 5);
        questions = questionRepository.saveAll(questions);
        session.setQuestions(questions);

        return session;
    }

    @Transactional
    public List<Question> generateMoreQuestions(PracticeSession session, int numQuestions) {
        String resumeText = session.getResume() != null ? session.getResume().getRawText() : "No resume provided.";
        String jdText = session.getJobDescriptionText();
        
        // Get existing question count for ordering
        int existingCount = session.getQuestions().size();
        
        List<Question> newQuestions = questionGenerationService.generateQuestions(session, resumeText, jdText, numQuestions);
        // Adjust order indices
        for (int i = 0; i < newQuestions.size(); i++) {
            newQuestions.get(i).setOrderIndex(existingCount + i + 1);
        }
        newQuestions = questionRepository.saveAll(newQuestions);
        session.getQuestions().addAll(newQuestions);
        
        return newQuestions;
    }

    private List<String> extractKeywords(String text1, String text2) {
        if (text1 == null || text2 == null) return List.of();
        
        String[] words1 = text1.toLowerCase().replaceAll("[^a-z0-9\\s]", "").split("\\s+");
        String[] words2 = text2.toLowerCase().replaceAll("[^a-z0-9\\s]", "").split("\\s+");
        
        java.util.Set<String> set1 = new java.util.HashSet<>(java.util.Arrays.asList(words1));
        java.util.Set<String> set2 = new java.util.HashSet<>(java.util.Arrays.asList(words2));
        
        set1.retainAll(set2);
        
        // Remove common stop words
        java.util.Set<String> stopWords = java.util.Set.of(
            "the", "and", "a", "to", "of", "in", "i", "is", "that", "it", "on", "you", "this", "for", "with",
            "are", "as", "be", "was", "or", "at", "by", "an", "have", "from", "which", "not", "but", "all", "we",
            "can", "will", "my", "your", "has", "do", "they", "their", "our", "would", "about", "what", "so", "if",
            "we", "us", "am", "been", "there", "when", "who", "more", "also", "any", "some", "other", "into", "than",
            "only", "new", "its", "up", "out", "how", "over", "like", "most", "such", "well", "where", "down", "should",
            "experience", "team", "work", "skills", "years", "knowledge", "ability", "including", "using", "development",
            "strong", "required", "preferred", "design", "management", "support", "working", "understanding", "business"
        );
        
        set1.removeAll(stopWords);
        
        // Filter short words
        set1.removeIf(w -> w.length() < 3);
        
        // Return top 10 matched words
        return set1.stream().limit(10).toList();
    }
}
