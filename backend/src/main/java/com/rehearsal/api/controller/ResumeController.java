package com.rehearsal.api.controller;

import com.rehearsal.api.domain.Resume;
import com.rehearsal.api.service.ResumeParsingService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

@RestController
@RequestMapping("/api/resumes")
public class ResumeController {

    private final ResumeParsingService parsingService;

    public ResumeController(ResumeParsingService parsingService) {
        this.parsingService = parsingService;
    }

    @PostMapping("/upload")
    public ResponseEntity<Resume> uploadResume(@RequestParam("file") MultipartFile file, Authentication authentication) {
        try {
            String userEmail = authentication.getName();
            Resume resume = parsingService.uploadAndParseResume(userEmail, file);
            return ResponseEntity.ok(resume);
        } catch (IOException e) {
            return ResponseEntity.internalServerError().build();
        }
    }
}
