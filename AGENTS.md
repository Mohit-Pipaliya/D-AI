# D AI — Master System Prompt & Engineering Rules
> Privacy-first, voice-first, production-grade cross-platform AI assistant ("D" / "Dee").

## 1. Product Identity & Persona
- **Name:** "D" (pronounced "Dee").
- **Display name, wake phrases, and persona name:** Must be defined as a single centralized configurable constant (`AppConstants.appName`, etc.) across both Flutter and backend codebases. Never hard-code "D" across features.
- **Experience Feel:** Siri + Google Assistant + Jarvis combined. Smooth voice-first interaction with glassmorphism UI and a reactive glowing orb; text chat as secondary.
- **Activation Modes (all 3 supported, individually configurable in Settings):**
  1. Wake phrase `"Hey D"` (primary, high reliability, default enabled).
  2. Wake word `"D"` (single-syllable, optional, default disabled, lower sensitivity with warning for false triggers).
  3. Clap activation: Double clap (2 claps within 300–800 ms window) as default; single clap optional with sensitivity warning.
- **Languages:** Hindi (`hi`), English (`en`), Hinglish (`en-IN` / `hi-Latn`), Gujarati (`gu`). D replies in the language / mixture spoken by the user.
- **Voice Response Constraint:** Maximum 2 concise lines for voice output. Longer responses are displayed on the visual card with D speaking a concise summary.

---

## 2. Target Platforms & Priority
1. **MVP (Phase 1–10):** macOS (Apple Silicon native) + Android (API 26–34+).
2. **Phase 2:** Windows (x64 / ARM64).
3. **Phase 3:** iOS (strictly adhering to Apple sandbox limits; Siri Shortcuts / App Intents fallback).

---

## 3. Technology Stack
- **Frontend:** Flutter (v3.22+), Riverpod (code generation / StateNotifier / AsyncNotifier), MVVM with Clean Architecture, Repository pattern, GoRouter.
- **Backend:** FastAPI (Python 3.12), Pydantic v2, async/await, JWT authentication, SQLite / PostgreSQL with Alembic migrations.
- **Database:** SQLite (local-first via Drift / sqflite) with end-to-end encrypted (E2EE) optional cloud sync.
- **Wake Word Engine:** Porcupine (Picovoice) custom on-device keyword models (`.ppn`).
- **Clap Detection Engine:** Custom on-device DSP detector (short-window RMS energy, spectral flatness, high-frequency energy ratio, adaptive noise floor tracking; 0% cloud dependence).
- **LLM Engine:** OpenAI through FastAPI backend proxy only. Never connect client directly to OpenAI.
- **Speech Stack:**
  - Streaming STT: Deepgram Nova-2 / Whisper API with fallback to platform native offline speech recognizers.
  - Streaming TTS: ElevenLabs / OpenAI TTS / Google Cloud TTS with fallback to `flutter_tts` offline.
  - Voice Barge-In: Real-time interruption upon VAD activity or wake detection.

---

## 4. Non-Negotiable Engineering Rules

1. **Vertical Slices & Approval:**
   Work in small vertical slices. One phase at a time. Before coding any phase, state the plan, files to be created/modified, and acceptance criteria. Wait for user approval before generating code.

2. **Backend Proxy & Zero Client Secrets:**
   API keys never live in the Flutter client. All LLM calls and third-party cloud AI APIs go through the FastAPI backend with JWT auth, rate limiting, per-user token budgets, retry with exponential backoff, and timeouts. Secrets reside in environment variables or OS secure storage (`flutter_secure_storage`, Keyring, Keychain).

3. **Just-In-Time Permissions & Graceful Degradation:**
   All permissions (Microphone, Camera, Notifications, Accessibility, Automation, Screen Recording) must be requested just-in-time with clear contextual explanations. The app must degrade gracefully without crashing when permissions are denied.

4. **Audio Privacy & Visual Indicators:**
   Wake word and clap detection run 100% on-device. Zero audio packets leave the device prior to activation. Display an unambiguous, system-wide listening indicator whenever the microphone is capturing audio.

5. **Automation Safety & Sandboxing:**
   No arbitrary shell execution (`eval`, un-sanitized `sh -c` is prohibited). All automated actions use typed tool schemas with JSON Schema validation. Destructive actions (file delete/move/overwrite, system configuration changes, sending messages) require explicit biometric or voice/UI confirmation. Every action is logged in an immutable local SQLite audit log. All external and LLM text is treated as untrusted (prompt-injection shielded).

6. **Camera & Emotion Privacy (Opt-in Only):**
   Camera features (presence, face count, position, emotion estimate) are strictly opt-in and process frames on-device in ephemeral memory. No video or frames are saved or uploaded. Emotion detection is explicitly labeled an "estimate", requires >= 70% confidence, uses a temporal cooldown (>= 5s), rejects repeated triggers, and can be disabled instantly.

7. **Long-Term Memory Privacy & Control:**
   Users have full CRUD visibility over memories: view, search, edit, delete individual items, or export to JSON. Hard exclusions: NEVER store passwords, financial credentials, credit cards, or health records.

8. **Latency Budgets:**
   Target < 2.0s time-to-first-audio (TTFA) on standard broadband/4G: Wake -> Streaming STT -> Streaming LLM -> Streaming TTS chunk playback with barge-in support.

9. **Quality & Testing:**
   Every feature must include unit tests (and integration tests where appropriate), comprehensive error handling, offline state behavior, and privacy-safe structured logging (sanitized of PII and audio data).

10. **Platform Honesty:**
    Never simulate or fake platform capabilities. Accurately respect OS boundaries (iOS background microphone restrictions, Android 14 foreground service types, macOS Accessibility entitlements). Provide documented OS-native alternatives (e.g. Siri Shortcuts for iOS).

11. **UI & Accessibility:**
    Glassmorphism design language, adaptive dark and light themes, dynamic Siri-style audio-reactive orb (CustomPainter/GLSL shaders), full localization readiness (`intl` with `en`, `hi`, `gu`), screen reader accessibility labels, and dynamic type support.

12. **Code Cleanliness:**
    Strict linting (`flutter_lints` / `ruff`), strict null safety, zero dead code, modular files (< 300 LOC where practical), descriptive naming, doc comments on public interfaces, and feature-first clean architecture directory hierarchy.

---

## 5. End-of-Phase Output Requirements
Every phase response must conclude with:
- **What was built:** Clear summary of features and components implemented.
- **How to run and test it:** Exact shell commands for backend, Flutter, and unit test suites.
- **Known limitations and platform caveats:** Honest technical trade-offs.
- **Requirements for next phase:** API keys, accounts, real hardware devices needed.

