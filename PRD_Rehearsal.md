# Product Requirements Document
## Rehearsal — AI-Assisted Mock Interview & Speech Analytics Platform

**Author:** Muhammad Ayan Khan
**Version:** 1.0
**Date:** August 2026
**Status:** Draft — Planning Phase

---

## 1. Overview

### 1.1 Problem Statement
Job seekers preparing for interviews have no low-cost, private way to practice against a *specific* job description and get objective feedback on how they actually speak — pacing, filler words, pauses, structure. Existing mock-interview tools either use generic question banks unrelated to the target role, or promise pseudo-scientific "confidence scores" from facial/tonal analysis that are neither reliable nor ethical to present as judgments about a candidate.

### 1.2 Solution Summary
Rehearsal lets a candidate upload a resume and a target job description. The system:
1. Computes a semantic match score between resume and JD (real NLP, embeddings-based).
2. Generates a tailored set of interview questions using an LLM, grounded in the JD and resume content.
3. Lets the candidate record video/audio answers per question inside the Flutter app.
4. Transcribes the answer on-device and computes **objective speech metrics** — words per minute, filler word rate, pause duration, speaking-vs-silence ratio.
5. Presents results back to the candidate as a practice report, with no subjective "confidence" or "hireability" scoring.

### 1.3 Explicit Non-Goals
- No sentiment/emotion/confidence scoring from voice tone or facial expression.
- No claim of predicting hireability or making pass/fail judgments about a person.
- No fine-tuning of BERT or any model from scratch — pretrained embedding models only.
- No cloud-paid STT/LLM dependency that costs money to demo (use free tiers only).
- Not a recruiter-facing hiring tool in v1 — this is a **self-practice tool for candidates**, which sidesteps the ethical/legal issues of automated candidate scoring entirely.

### 1.4 Target User
Job seekers (students, early-career developers, career switchers) who want structured, role-specific interview practice without paying for a career coach.

---

## 2. Goals & Success Criteria

| Goal | Metric |
|---|---|
| Demonstrate real NLP engineering | Working embedding-based JD-resume match, explainable output |
| Demonstrate LLM integration done well | Reliable structured question generation, not just raw prompt-and-hope |
| Demonstrate full-stack mobile + backend skill | End-to-end recording → upload → processing → report flow works reliably |
| Ship something real | Published on Play Store, at least soft-launched |
| Zero recurring cost | Runs entirely on free tiers / on-device processing |

---

## 3. System Architecture

```
┌─────────────────────┐        ┌──────────────────────────┐        ┌────────────────────┐
│   Flutter App        │ REST   │   Grails 7 / Spring Boot  │        │   Postgres DB       │
│   (Android/iOS)       │◄──────►│   Backend (Java 21)        │◄──────►│   (Candidates,       │
│                       │        │                            │        │    Sessions, Scores) │
│  - Resume upload      │        │  - Resume parsing service  │        │                      │
│  - JD input           │        │  - Embedding service (DJL) │        └────────────────────┘
│  - Recording (camera/ │        │  - Question-gen service    │
│    record packages)   │        │    (LLM API client)        │        ┌────────────────────┐
│  - On-device STT       │        │  - Speech metrics service  │◄──────►│  Object Storage      │
│  - Report UI           │        │  - Auth (JWT)               │        │  (video/audio blobs, │
└─────────────────────┘        └──────────────────────────┘        │  S3-compatible free  │
                                                                          │  tier, e.g. Cloudflare│
                                                                          │  R2 / Supabase)       │
                                                                          └────────────────────┘
```

**Key architectural decisions:**
- **On-device STT and metric pre-computation** in Flutter (via platform speech APIs) keeps raw audio mostly client-side, reduces backend load, and avoids paid cloud STT.
- **DJL (Deep Java Library) in the Grails service layer** runs the embedding model natively on the JVM — no Python microservice needed, keeps the stack unified.
- **LLM calls for question generation** go through a free-tier provider (e.g., Groq or Gemini free tier), isolated behind a `QuestionGenerationService` interface so the provider can be swapped without touching callers.
- **Video/audio storage** uses a free-tier S3-compatible bucket; only the final transcript + computed metrics are stored in Postgres, not raw media analysis.

---

## 4. Functional Requirements

### 4.1 Resume & JD Ingestion
- **FR-1**: User uploads resume (PDF/DOCX) via Flutter app.
- **FR-2**: Backend extracts raw text from resume (Apache PDFBox / POI for DOCX).
- **FR-3**: User pastes or types a target job description (plain text field, min/max length validation).
- **FR-4**: Backend stores parsed resume text and JD text against the candidate's profile.

### 4.2 Resume-JD Semantic Matching
- **FR-5**: Backend generates sentence embeddings for resume text and JD text using a pretrained model (e.g., `all-MiniLM-L6-v2` via DJL/ONNX runtime).
- **FR-6**: System computes cosine similarity between resume and JD embeddings to produce a 0-100 match score.
- **FR-7**: System extracts and surfaces top overlapping skill/keyword terms between resume and JD (simple TF-IDF or keyword extraction) as explainability for the score — never show a bare number without justification.
- **FR-8**: Match result is returned to the app and displayed with the score and the supporting keyword overlap.

### 4.3 LLM-Generated Interview Questions
- **FR-9**: Backend sends JD text (and optionally resume highlights) to an LLM with a structured prompt requesting N interview questions in JSON format (question text, category: technical/behavioral/situational).
- **FR-10**: Backend validates and parses the LLM's JSON response; on malformed output, retries once with a stricter prompt, then falls back to a small static question bank by category.
- **FR-11**: Generated question set is persisted against the session so the same set can be reused across a practice attempt.
- **FR-12**: User can regenerate the question set (rate-limited to avoid excessive LLM calls).

### 4.4 Video/Audio Recording
- **FR-13**: For each question, user can record a video (with audio) response using the `camera` and `record` Flutter packages.
- **FR-14**: Recording UI shows a live timer and a configurable max duration (e.g., 3 minutes) per answer.
- **FR-15**: Recordings are chunked and uploaded in the background as they complete, with retry-on-failure logic; user is not blocked waiting for upload before moving to the next question.
- **FR-16**: Upload progress is visible; failed uploads are queued for retry when connectivity returns.

### 4.5 Transcription & Speech Metrics
- **FR-17**: After recording, audio is transcribed on-device using the platform speech-to-text API (Android `SpeechRecognizer` / iOS `Speech` framework), or Whisper.cpp locally as a fallback for offline use.
- **FR-18**: From the transcript and audio timing data, the app/backend computes:
  - Words per minute (WPM)
  - Filler word count and rate (configurable filler word list: "um", "uh", "like", "you know", etc.)
  - Pause count and total pause duration (silence gaps above a threshold, e.g., >1.5s)
  - Speaking time vs. total response time ratio
- **FR-19**: Computed metrics are sent to the backend and stored against the session/question.
- **FR-20**: No metric is framed as a judgment of the candidate — labels are descriptive ("Your filler word rate was X per minute") not evaluative ("Your confidence score is low").

### 4.6 Practice Report
- **FR-21**: After completing all questions in a session, user sees a report screen: resume-JD match score, per-question speech metrics, and simple trend view if they've done multiple sessions (e.g., filler word rate over time).
- **FR-22**: User can review their own recorded video per question alongside the transcript.
- **FR-23**: User can delete a session and its associated media at any time (privacy control).

### 4.7 Auth & Profile
- **FR-24**: Email/password or Google sign-in, JWT-based session auth.
- **FR-25**: User profile stores resume history and past practice sessions.

---

## 5. Non-Functional Requirements

- **NFR-1 (Cost)**: No component may require a paid API key or paid infrastructure tier to run a full demo.
- **NFR-2 (Privacy)**: Video/audio is user-owned; user can delete it; nothing is shared with third parties. Since this is self-practice (not employer-facing scoring), consent/privacy concerns are far lower than a recruiter-facing tool — but deletion and local-first transcription should still be implemented to keep it defensible.
- **NFR-3 (Reliability)**: Upload of large video files must survive flaky mobile connections (chunked, resumable).
- **NFR-4 (Performance)**: Embedding inference for matching should complete in well under 2 seconds server-side per request.
- **NFR-5 (Portability)**: Backend logic (embedding service, metrics service) should be cleanly separated behind interfaces so the LLM provider or embedding model can be swapped later without major rework.

---

## 6. Data Model (high-level)

- **User**: id, email, auth info, created_at
- **Resume**: id, user_id, raw_text, parsed_at, file_ref
- **Session**: id, user_id, resume_id, job_description_text, match_score, created_at
- **Question**: id, session_id, text, category, order_index
- **Answer**: id, question_id, media_ref (video/audio blob URL), transcript_text, wpm, filler_word_count, filler_word_rate, pause_count, pause_duration_total, speaking_ratio, recorded_at

---

## 7. Tech Stack

| Layer | Choice |
|---|---|
| Mobile | Flutter (camera, record, speech_to_text or platform channels) |
| Backend | Grails 7.0.0 / Spring Boot, Java 21 |
| ML inference (JVM) | Deep Java Library (DJL) with ONNX runtime, pretrained MiniLM embeddings |
| LLM | Free-tier hosted LLM API (e.g., Groq, Gemini) behind an internal interface |
| DB | PostgreSQL |
| Object storage | S3-compatible free tier (Cloudflare R2 / Supabase Storage) |
| Auth | JWT |
| IDE | Antigravity |

---

## 8. Phased Delivery Plan

**Phase 1 — Core backend + matching (2-3 weeks)**
- Grails project setup, auth, resume upload + parsing
- Embedding service via DJL, match score endpoint
- Unit tests for parsing and scoring

**Phase 2 — Question generation (1-2 weeks)**
- LLM client integration, prompt design, JSON validation/retry logic
- Static fallback question bank

**Phase 3 — Flutter recording flow (2-3 weeks)**
- Camera/record integration, timer UI, chunked background upload
- Basic session flow: question list → record → next

**Phase 4 — Speech metrics (2 weeks)**
- On-device STT integration
- WPM/filler/pause computation, backend persistence

**Phase 5 — Report UI + polish (1-2 weeks)**
- Report screen, session history, delete/privacy controls
- Play Store packaging and submission

**Total estimate:** ~9-12 weeks part-time.

---

## 9. Open Questions / Risks

- **Risk**: On-device STT accuracy varies by device/accent — mitigate by allowing manual transcript correction before metrics are computed.
- **Risk**: LLM free-tier rate limits could throttle question generation under any real usage — mitigate with caching/regeneration limits and a static fallback bank.
- **Risk**: DJL model load time/cold start on low-resource hosting (e.g., Render free tier) — mitigate by benchmarking early and keeping the model small (MiniLM, not a larger BERT variant).
- **Open question**: Should filler-word list be language/accent configurable for v1, or English-only to start? (Recommend English-only for v1 to control scope.)

---

## 10. Portfolio Framing

Suggested one-line description for the portfolio site:

> "Rehearsal — an AI-assisted mock interview platform: Flutter app with on-device speech transcription, a Grails/Java 21 backend running JVM-native NLP inference (DJL) for resume-JD semantic matching, and an LLM-driven question generation pipeline — built with zero paid infrastructure."
