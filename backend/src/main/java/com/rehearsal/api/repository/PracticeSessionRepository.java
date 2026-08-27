package com.rehearsal.api.repository;

import com.rehearsal.api.domain.PracticeSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PracticeSessionRepository extends JpaRepository<PracticeSession, Long> {
    List<PracticeSession> findByUserId(Long userId);
    List<PracticeSession> findByUserEmailOrderByCreatedAtDesc(String email);
}
