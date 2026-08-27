package com.rehearsal.api.service;

import com.rehearsal.api.domain.Resume;
import com.rehearsal.api.domain.User;
import com.rehearsal.api.repository.ResumeRepository;
import com.rehearsal.api.repository.UserRepository;
import org.apache.pdfbox.Loader;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.LocalDateTime;

@Service
public class ResumeParsingService {

    private final ResumeRepository resumeRepository;
    private final UserRepository userRepository;

    public ResumeParsingService(ResumeRepository resumeRepository, UserRepository userRepository) {
        this.resumeRepository = resumeRepository;
        this.userRepository = userRepository;
    }

    public Resume uploadAndParseResume(String userEmail, MultipartFile file) throws IOException {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        String rawText = extractTextFromPdf(file);

        Resume resume = new Resume();
        resume.setUser(user);
        resume.setRawText(rawText);
        resume.setParsedAt(LocalDateTime.now());
        resume.setFileRef(file.getOriginalFilename());

        return resumeRepository.save(resume);
    }

    private String extractTextFromPdf(MultipartFile file) throws IOException {
        try (PDDocument document = Loader.loadPDF(file.getBytes())) {
            PDFTextStripper stripper = new PDFTextStripper();
            return stripper.getText(document);
        }
    }
}
