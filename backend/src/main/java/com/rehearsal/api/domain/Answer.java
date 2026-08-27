package com.rehearsal.api.domain;

import jakarta.persistence.*;
import java.time.LocalDateTime;

import com.fasterxml.jackson.annotation.JsonIgnore;

@Entity
@Table(name = "answers")
public class Answer extends BaseEntity {

    @JsonIgnore
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "question_id", nullable = false)
    private Question question;

    private String mediaRef;

    @Column(columnDefinition = "TEXT")
    private String transcriptText;

    private Integer wpm;
    private Integer fillerWordCount;
    private Double fillerWordRate;
    private Integer pauseCount;
    private Double pauseDurationTotal;
    private Double speakingRatio;

    @Column(columnDefinition = "TEXT")
    private String aiFeedback;

    private LocalDateTime recordedAt;

    // Getters and Setters

    public Question getQuestion() {
        return question;
    }

    public void setQuestion(Question question) {
        this.question = question;
    }

    public String getMediaRef() {
        return mediaRef;
    }

    public void setMediaRef(String mediaRef) {
        this.mediaRef = mediaRef;
    }

    public String getTranscriptText() {
        return transcriptText;
    }

    public void setTranscriptText(String transcriptText) {
        this.transcriptText = transcriptText;
    }

    public Integer getWpm() {
        return wpm;
    }

    public void setWpm(Integer wpm) {
        this.wpm = wpm;
    }

    public Integer getFillerWordCount() {
        return fillerWordCount;
    }

    public void setFillerWordCount(Integer fillerWordCount) {
        this.fillerWordCount = fillerWordCount;
    }

    public Double getFillerWordRate() {
        return fillerWordRate;
    }

    public void setFillerWordRate(Double fillerWordRate) {
        this.fillerWordRate = fillerWordRate;
    }

    public Integer getPauseCount() {
        return pauseCount;
    }

    public void setPauseCount(Integer pauseCount) {
        this.pauseCount = pauseCount;
    }

    public Double getPauseDurationTotal() {
        return pauseDurationTotal;
    }

    public void setPauseDurationTotal(Double pauseDurationTotal) {
        this.pauseDurationTotal = pauseDurationTotal;
    }

    public Double getSpeakingRatio() {
        return speakingRatio;
    }

    public void setSpeakingRatio(Double speakingRatio) {
        this.speakingRatio = speakingRatio;
    }

    public String getAiFeedback() {
        return aiFeedback;
    }

    public void setAiFeedback(String aiFeedback) {
        this.aiFeedback = aiFeedback;
    }

    public LocalDateTime getRecordedAt() {
        return recordedAt;
    }

    public void setRecordedAt(LocalDateTime recordedAt) {
        this.recordedAt = recordedAt;
    }
}
