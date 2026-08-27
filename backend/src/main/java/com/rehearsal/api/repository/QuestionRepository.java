package com.rehearsal.api.repository;

import com.rehearsal.api.domain.Question;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface QuestionRepository extends JpaRepository<Question, Long> {
    List<Question> findBySessionIdOrderByOrderIndexAsc(Long sessionId);
}
