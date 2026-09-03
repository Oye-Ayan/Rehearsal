package com.rehearsal.api.service;

import com.rehearsal.api.repository.PracticeSessionRepository;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
public class SessionCleanupService {

    private final PracticeSessionRepository sessionRepository;

    public SessionCleanupService(PracticeSessionRepository sessionRepository) {
        this.sessionRepository = sessionRepository;
    }

    /**
     * Runs every day at 3:00 AM to delete unpinned sessions older than 7 days.
     */
    @Scheduled(cron = "0 0 3 * * *")
    @Transactional
    public void cleanupExpiredSessions() {
        LocalDateTime cutoff = LocalDateTime.now().minusDays(7);
        int deleted = sessionRepository.deleteByPinnedFalseAndCreatedAtBefore(cutoff);
        if (deleted > 0) {
            System.out.println("[SessionCleanup] Deleted " + deleted + " expired sessions.");
        }
    }
}
