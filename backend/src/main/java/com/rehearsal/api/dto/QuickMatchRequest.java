package com.rehearsal.api.dto;

public class QuickMatchRequest {
    private String jobDescriptionText;
    private String userDetails;

    public String getJobDescriptionText() { return jobDescriptionText; }
    public void setJobDescriptionText(String jobDescriptionText) { this.jobDescriptionText = jobDescriptionText; }

    public String getUserDetails() { return userDetails; }
    public void setUserDetails(String userDetails) { this.userDetails = userDetails; }
}
