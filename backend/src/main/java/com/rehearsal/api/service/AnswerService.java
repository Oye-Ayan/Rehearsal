package com.rehearsal.api.service;

import com.rehearsal.api.domain.Answer;
import com.rehearsal.api.domain.Question;
import com.rehearsal.api.domain.User;
import com.rehearsal.api.dto.AnswerRequest;
import com.rehearsal.api.repository.AnswerRepository;
import com.rehearsal.api.repository.QuestionRepository;
import com.rehearsal.api.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
public class AnswerService {

    private final AnswerRepository answerRepository;
    private final QuestionRepository questionRepository;
    private final UserRepository userRepository;
    private final GroqFeedbackService feedbackService;

    public AnswerService(AnswerRepository answerRepository, QuestionRepository questionRepository,
            UserRepository userRepository, GroqFeedbackService feedbackService) {
        this.answerRepository = answerRepository;
        this.questionRepository = questionRepository;
        this.userRepository = userRepository;
        this.feedbackService = feedbackService;
    }

    @Transactional
    public Answer saveAnswer(String userEmail, Long questionId, AnswerRequest request) {
        // Validate user
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Validate question exists
        Question question = questionRepository.findById(questionId)
                .orElseThrow(() -> new RuntimeException("Question not found"));

        // Verify the user owns the session this question belongs to
        if (!question.getSession().getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Unauthorized: You do not own this session.");
        }

        // Check if answer already exists, if so update it, else create new
        Answer answer = answerRepository.findByQuestionId(questionId)
                .orElse(new Answer());

        answer.setQuestion(question);
        answer.setTranscriptText(request.getTranscriptText());
        answer.setWpm(request.getWpm());
        answer.setFillerWordCount(request.getFillerWordCount());
        answer.setFillerWordRate(request.getFillerWordRate());
        answer.setPauseCount(request.getPauseCount());
        answer.setPauseDurationTotal(request.getPauseDurationTotal());
        answer.setSpeakingRatio(request.getSpeakingRatio());
        answer.setMediaRef(request.getMediaRef());
        answer.setRecordedAt(LocalDateTime.now());

        // Generate AI feedback synchronously before saving
        String aiFeedback = feedbackService.generateFeedback(question.getText(), request.getTranscriptText());
        answer.setAiFeedback(aiFeedback);

        return answerRepository.save(answer);
    }
}
