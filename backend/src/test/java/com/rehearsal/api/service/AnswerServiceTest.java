package com.rehearsal.api.service;

import com.rehearsal.api.domain.Answer;
import com.rehearsal.api.domain.PracticeSession;
import com.rehearsal.api.domain.Question;
import com.rehearsal.api.domain.User;
import com.rehearsal.api.dto.AnswerRequest;
import com.rehearsal.api.repository.AnswerRepository;
import com.rehearsal.api.repository.QuestionRepository;
import com.rehearsal.api.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class AnswerServiceTest {

    @Mock
    private AnswerRepository answerRepository;
    @Mock
    private QuestionRepository questionRepository;
    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private AnswerService answerService;

    private User mockUser;
    private PracticeSession mockSession;
    private Question mockQuestion;

    @BeforeEach
    void setUp() {
        mockUser = new User();
        mockUser.setId(1L);
        mockUser.setEmail("test@example.com");

        mockSession = new PracticeSession();
        mockSession.setId(1L);
        mockSession.setUser(mockUser);

        mockQuestion = new Question();
        mockQuestion.setId(1L);
        mockQuestion.setSession(mockSession);
    }

    @Test
    void saveAnswer_ShouldSaveSuccessfully() {
        // Arrange
        AnswerRequest req = new AnswerRequest();
        req.setTranscriptText("Um, I like coding.");
        req.setWpm(120);
        req.setFillerWordCount(2);
        req.setFillerWordRate(5.0);

        when(userRepository.findByEmail("test@example.com")).thenReturn(Optional.of(mockUser));
        when(questionRepository.findById(1L)).thenReturn(Optional.of(mockQuestion));
        when(answerRepository.findByQuestionId(1L)).thenReturn(Optional.empty());
        when(answerRepository.save(any(Answer.class))).thenAnswer(i -> i.getArguments()[0]);

        // Act
        Answer saved = answerService.saveAnswer("test@example.com", 1L, req);

        // Assert
        assertNotNull(saved);
        assertEquals("Um, I like coding.", saved.getTranscriptText());
        assertEquals(120, saved.getWpm());
        assertEquals(2, saved.getFillerWordCount());
        assertEquals(5.0, saved.getFillerWordRate());
        verify(answerRepository, times(1)).save(any(Answer.class));
    }
}
