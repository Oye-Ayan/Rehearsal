package com.rehearsal.api.service;

import com.rehearsal.api.domain.PracticeSession;
import com.rehearsal.api.domain.Question;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.pdmodel.font.PDType1Font;
import org.apache.pdfbox.pdmodel.font.Standard14Fonts;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Service
public class PdfExportService {

    private static final float MARGIN = 50;
    private static final float LINE_HEIGHT = 16;
    private static final float TITLE_LINE_HEIGHT = 24;

    public byte[] generateSessionPdf(PracticeSession session) {
        try (PDDocument document = new PDDocument()) {

            PDType1Font fontBold = new PDType1Font(Standard14Fonts.FontName.HELVETICA_BOLD);
            PDType1Font fontNormal = new PDType1Font(Standard14Fonts.FontName.HELVETICA);
            PDType1Font fontItalic = new PDType1Font(Standard14Fonts.FontName.HELVETICA_OBLIQUE);

            float pageWidth = PDRectangle.A4.getWidth();
            float pageHeight = PDRectangle.A4.getHeight();
            float usableWidth = pageWidth - 2 * MARGIN;

            // We will track pages and y position manually
            PDPage currentPage = new PDPage(PDRectangle.A4);
            document.addPage(currentPage);
            PDPageContentStream cs = new PDPageContentStream(document, currentPage);
            float y = pageHeight - MARGIN;

            // ── Title ──
            y = drawText(cs, fontBold, 20, "Rehearsal - Interview Report", MARGIN, y, usableWidth);
            y -= 8;
            y = drawText(cs, fontNormal, 10, "Session #" + session.getId() + "  |  " +
                    (session.getCreatedAt() != null ? session.getCreatedAt().format(DateTimeFormatter.ofPattern("MMM d, yyyy h:mm a")) : "Unknown Date"), MARGIN, y, usableWidth);
            y -= 6;
            y = drawText(cs, fontNormal, 10, "Match Score: " + (session.getMatchScore() != null ? session.getMatchScore() + "%" : "N/A"), MARGIN, y, usableWidth);
            y -= 20;

            // ── Line separator ──
            cs.setLineWidth(0.5f);
            cs.moveTo(MARGIN, y);
            cs.lineTo(pageWidth - MARGIN, y);
            cs.stroke();
            y -= 20;

            // ── Questions & Answers ──
            List<Question> questions = session.getQuestions();
            if (questions != null) {
                for (int i = 0; i < questions.size(); i++) {
                    Question q = questions.get(i);

                    // Check if we need a new page
                    if (y < MARGIN + 100) {
                        cs.close();
                        currentPage = new PDPage(PDRectangle.A4);
                        document.addPage(currentPage);
                        cs = new PDPageContentStream(document, currentPage);
                        y = pageHeight - MARGIN;
                    }

                    // Question
                    y = drawText(cs, fontBold, 12, "Q" + (i + 1) + ": " + q.getText(), MARGIN, y, usableWidth);
                    y -= 6;

                    // Answer
                    String answerText = "No answer recorded.";
                    if (q.getAnswer() != null && q.getAnswer().getTranscriptText() != null && !q.getAnswer().getTranscriptText().trim().isEmpty()) {
                        answerText = q.getAnswer().getTranscriptText();
                    }
                    y = drawText(cs, fontNormal, 10, "A: " + answerText, MARGIN + 10, y, usableWidth - 10);
                    y -= 6;

                    // Feedback
                    if (q.getAnswer() != null && q.getAnswer().getAiFeedback() != null) {
                        y = drawText(cs, fontItalic, 9, "Feedback: " + q.getAnswer().getAiFeedback(), MARGIN + 10, y, usableWidth - 10);
                    }
                    y -= 16;
                }
            }

            // ── Action Plan ──
            if (session.getActionPlan() != null && !session.getActionPlan().isEmpty()) {
                if (y < MARGIN + 80) {
                    cs.close();
                    currentPage = new PDPage(PDRectangle.A4);
                    document.addPage(currentPage);
                    cs = new PDPageContentStream(document, currentPage);
                    y = pageHeight - MARGIN;
                }

                y -= 10;
                cs.setLineWidth(0.5f);
                cs.moveTo(MARGIN, y);
                cs.lineTo(pageWidth - MARGIN, y);
                cs.stroke();
                y -= 16;

                y = drawText(cs, fontBold, 14, "Action Plan", MARGIN, y, usableWidth);
                y -= 8;
                y = drawText(cs, fontNormal, 10, session.getActionPlan(), MARGIN, y, usableWidth);
            }

            cs.close();

            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            document.save(baos);
            return baos.toByteArray();

        } catch (Exception e) {
            e.printStackTrace();
            return new byte[0];
        }
    }

    /**
     * Draw wrapped text and return the new y position.
     */
    private float drawText(PDPageContentStream cs, PDType1Font font, float fontSize, String text, float x, float y, float maxWidth) throws Exception {
        if (text == null || text.isEmpty()) return y;

        List<String> lines = wrapText(text, font, fontSize, maxWidth);
        float lineHeight = fontSize + 4;

        for (String line : lines) {
            if (y < MARGIN) return y; // Can't fit more on this page
            cs.beginText();
            cs.setFont(font, fontSize);
            cs.newLineAtOffset(x, y);
            cs.showText(line);
            cs.endText();
            y -= lineHeight;
        }
        return y;
    }

    private List<String> wrapText(String text, PDType1Font font, float fontSize, float maxWidth) throws Exception {
        List<String> lines = new ArrayList<>();
        // Handle newlines in text
        String[] paragraphs = text.split("\n");
        for (String para : paragraphs) {
            String[] words = para.split("\\s+");
            StringBuilder currentLine = new StringBuilder();
            for (String word : words) {
                // Sanitize word - replace characters not in WinAnsiEncoding
                word = sanitize(word);
                String test = currentLine.length() == 0 ? word : currentLine + " " + word;
                float width = font.getStringWidth(test) / 1000 * fontSize;
                if (width > maxWidth && currentLine.length() > 0) {
                    lines.add(currentLine.toString());
                    currentLine = new StringBuilder(word);
                } else {
                    if (currentLine.length() > 0) currentLine.append(" ");
                    currentLine.append(word);
                }
            }
            if (currentLine.length() > 0) {
                lines.add(currentLine.toString());
            }
        }
        return lines;
    }

    private String sanitize(String input) {
        if (input == null) return "";
        // Replace common problematic characters
        return input.replaceAll("[^\\x20-\\x7E]", "");
    }
}
