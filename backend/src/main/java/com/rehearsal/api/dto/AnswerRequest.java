package com.rehearsal.api.dto;

public class AnswerRequest {
    private String transcriptText;
    private Integer wpm;
    private Integer fillerWordCount;
    private Double fillerWordRate;
    private Integer pauseCount;
    private Double pauseDurationTotal;
    private Double speakingRatio;
    private String mediaRef;

    // Getters and Setters

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

    public String getMediaRef() {
        return mediaRef;
    }

    public void setMediaRef(String mediaRef) {
        this.mediaRef = mediaRef;
    }
}
