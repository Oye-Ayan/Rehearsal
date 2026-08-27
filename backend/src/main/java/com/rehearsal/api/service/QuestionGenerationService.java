package com.rehearsal.api.service;

import com.rehearsal.api.domain.Question;
import com.rehearsal.api.domain.PracticeSession;

import java.util.List;

public interface QuestionGenerationService {
    List<Question> generateQuestions(PracticeSession session, String resumeText, String jobDescriptionText, int numQuestions);
}
