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

import java.awt.Color;
import java.io.ByteArrayOutputStream;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Service
public class PdfExportService {

    private static final float MARGIN = 45;

    public byte[] generateSessionPdf(PracticeSession session) {
        return generateSessionPdf(session, session.getId().intValue());
    }

    public byte[] generateSessionPdf(PracticeSession session, int userSessionNumber) {
        try (PDDocument document = new PDDocument()) {

            PDType1Font fontBold = new PDType1Font(Standard14Fonts.FontName.HELVETICA_BOLD);
            PDType1Font fontNormal = new PDType1Font(Standard14Fonts.FontName.HELVETICA);
            PDType1Font fontOblique = new PDType1Font(Standard14Fonts.FontName.HELVETICA_OBLIQUE);

            float pageWidth = PDRectangle.A4.getWidth();
            float pageHeight = PDRectangle.A4.getHeight();
            float usableWidth = pageWidth - 2 * MARGIN;

            PDPage currentPage = new PDPage(PDRectangle.A4);
            document.addPage(currentPage);
            PDPageContentStream cs = new PDPageContentStream(document, currentPage);
            float y = pageHeight - MARGIN;

            // Colors
            Color primaryDark = new Color(15, 23, 42);      // Slate 900
            Color textPrimary = new Color(30, 41, 59);      // Slate 800
            Color textSecondary = new Color(100, 116, 139); // Slate 500
            Color accentBlue = new Color(37, 99, 235);      // Blue 600
            Color cardBg = new Color(248, 250, 252);        // Slate 50
            Color cardBorder = new Color(226, 232, 240);    // Slate 200

            // ── Top Header Banner Accent ──
            cs.setNonStrokingColor(primaryDark);
            cs.addRect(MARGIN, y - 48, usableWidth, 48);
            cs.fill();

            cs.setNonStrokingColor(Color.WHITE);
            cs.beginText();
            cs.setFont(fontBold, 16);
            cs.newLineAtOffset(MARGIN + 16, y - 30);
            cs.showText("REHEARSAL  |  INTERVIEW REPORT");
            cs.endText();

            y -= 64;

            // ── Session Meta Info Card ──
            cs.setNonStrokingColor(cardBg);
            cs.setStrokingColor(cardBorder);
            cs.setLineWidth(1.0f);
            cs.addRect(MARGIN, y - 54, usableWidth, 54);
            cs.fillAndStroke();

            String sessionTitle = "Session #" + userSessionNumber;
            String sessionDate = session.getCreatedAt() != null
                    ? session.getCreatedAt().format(DateTimeFormatter.ofPattern("EEEE, MMM d, yyyy  h:mm a"))
                    : "Date N/A";
            String scoreText = (session.getMatchScore() != null ? session.getMatchScore() + "%" : "N/A");

            // Session Title & Date
            cs.setNonStrokingColor(textPrimary);
            cs.beginText();
            cs.setFont(fontBold, 14);
            cs.newLineAtOffset(MARGIN + 14, y - 22);
            cs.showText(sessionTitle);
            cs.endText();

            cs.setNonStrokingColor(textSecondary);
            cs.beginText();
            cs.setFont(fontNormal, 10);
            cs.newLineAtOffset(MARGIN + 14, y - 40);
            cs.showText(sessionDate);
            cs.endText();

            // Match Score Badge on Right
            cs.setNonStrokingColor(accentBlue);
            cs.beginText();
            cs.setFont(fontBold, 18);
            cs.newLineAtOffset(pageWidth - MARGIN - 80, y - 24);
            cs.showText(scoreText);
            cs.endText();

            cs.setNonStrokingColor(textSecondary);
            cs.beginText();
            cs.setFont(fontBold, 9);
            cs.newLineAtOffset(pageWidth - MARGIN - 80, y - 38);
            cs.showText("MATCH SCORE");
            cs.endText();

            y -= 74;

            // ── Section Title: Questions & Coaching ──
            cs.setNonStrokingColor(primaryDark);
            cs.beginText();
            cs.setFont(fontBold, 12);
            cs.newLineAtOffset(MARGIN, y);
            cs.showText("QUESTION ANALYSIS & COACHING");
            cs.endText();
            y -= 14;

            List<Question> questions = session.getQuestions();
            if (questions != null && !questions.isEmpty()) {
                for (int i = 0; i < questions.size(); i++) {
                    Question q = questions.get(i);

                    if (y < MARGIN + 120) {
                        cs.close();
                        currentPage = new PDPage(PDRectangle.A4);
                        document.addPage(currentPage);
                        cs = new PDPageContentStream(document, currentPage);
                        y = pageHeight - MARGIN;
                    }

                    // Question Header
                    String category = q.getCategory() != null ? q.getCategory().toUpperCase() : "GENERAL";
                    cs.setNonStrokingColor(accentBlue);
                    cs.beginText();
                    cs.setFont(fontBold, 10);
                    cs.newLineAtOffset(MARGIN, y);
                    cs.showText("Q" + (i + 1) + " • " + category);
                    cs.endText();
                    y -= 14;

                    // Question Text
                    cs.setNonStrokingColor(textPrimary);
                    y = drawWrappedText(cs, fontBold, 11, q.getText(), MARGIN, y, usableWidth, 14, textPrimary);
                    y -= 6;

                    // User Answer
                    String answerText = "No answer recorded.";
                    if (q.getAnswer() != null && q.getAnswer().getTranscriptText() != null && !q.getAnswer().getTranscriptText().trim().isEmpty()) {
                        answerText = "\"" + q.getAnswer().getTranscriptText().trim() + "\"";
                    }

                    cs.setNonStrokingColor(textSecondary);
                    cs.beginText();
                    cs.setFont(fontBold, 9);
                    cs.newLineAtOffset(MARGIN + 10, y);
                    cs.showText("YOUR ANSWER:");
                    cs.endText();
                    y -= 12;

                    y = drawWrappedText(cs, fontOblique, 10, answerText, MARGIN + 10, y, usableWidth - 10, 13, textPrimary);
                    y -= 6;

                    // AI Feedback
                    if (q.getAnswer() != null && q.getAnswer().getAiFeedback() != null && !q.getAnswer().getAiFeedback().trim().isEmpty()) {
                        cs.setNonStrokingColor(accentBlue);
                        cs.beginText();
                        cs.setFont(fontBold, 9);
                        cs.newLineAtOffset(MARGIN + 10, y);
                        cs.showText("AI COACHING FEEDBACK:");
                        cs.endText();
                        y -= 12;

                        y = drawWrappedText(cs, fontNormal, 9.5f, q.getAnswer().getAiFeedback().trim(), MARGIN + 10, y, usableWidth - 10, 13, textPrimary);
                    }

                    y -= 16;

                    // Divider line
                    cs.setStrokingColor(cardBorder);
                    cs.setLineWidth(0.5f);
                    cs.moveTo(MARGIN, y);
                    cs.lineTo(pageWidth - MARGIN, y);
                    cs.stroke();
                    y -= 16;
                }
            }

            // ── Section: Action Plan ──
            if (session.getActionPlan() != null && !session.getActionPlan().trim().isEmpty()) {
                if (y < MARGIN + 100) {
                    cs.close();
                    currentPage = new PDPage(PDRectangle.A4);
                    document.addPage(currentPage);
                    cs = new PDPageContentStream(document, currentPage);
                    y = pageHeight - MARGIN;
                }

                cs.setNonStrokingColor(primaryDark);
                cs.beginText();
                cs.setFont(fontBold, 12);
                cs.newLineAtOffset(MARGIN, y);
                cs.showText("TAILORED ACTION PLAN");
                cs.endText();
                y -= 14;

                y = drawWrappedText(cs, fontNormal, 10, session.getActionPlan().trim(), MARGIN, y, usableWidth, 14, textPrimary);
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

    private float drawWrappedText(PDPageContentStream cs, PDType1Font font, float fontSize, String text, float x, float y, float maxWidth, float lineHeight, Color textColor) throws Exception {
        if (text == null || text.isEmpty()) return y;

        List<String> lines = wrapText(text, font, fontSize, maxWidth);
        cs.setNonStrokingColor(textColor);

        for (String line : lines) {
            if (y < MARGIN) return y;
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
        String[] paragraphs = text.split("\n");
        for (String para : paragraphs) {
            String[] words = para.split("\\s+");
            StringBuilder currentLine = new StringBuilder();
            for (String word : words) {
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
        return input.replaceAll("[^\\x20-\\x7E]", "");
    }
}
