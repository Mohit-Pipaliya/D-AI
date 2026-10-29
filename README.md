# D AI — Privacy-First, Voice-First AI Assistant

> **"Hey D"** — Your intelligent companion across macOS, Android, Windows, and iOS.

![Platform](https://img.shields.io/badge/Platforms-macOS%20%7C%20Android%20%7C%20Windows%20%7C%20iOS-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?logo=flutter)
![FastAPI](https://img.shields.io/badge/FastAPI-0.111+-009688?logo=fastapi)
![License](https://img.shields.io/badge/License-Private-red)

## 🎯 What is D?

D (pronounced "Dee") is a privacy-first, voice-first AI assistant that combines the best of Siri, Google Assistant, and Jarvis. It features:

- **Triple Activation:** Wake phrase ("Hey D"), wake word ("D"), and double-clap detection
- **Voice-First Design:** Natural conversations with streaming STT/TTS and voice barge-in
- **Privacy by Design:** Wake word and clap detection run 100% on-device. Zero audio leaves your device before activation
- **Cross-Platform:** macOS (menu bar), Android (foreground service), Windows (system tray), iOS (Siri Shortcuts)
- **Multilingual:** Hindi, English, Hinglish, and Gujarati with auto language detection
- **Smart Memory:** Long-term context with local vector search, user-controlled and exportable
- **OS Automation:** Control apps, files, and system settings with safety confirmations

## 📁 Project Structure

```
D/
├── lib/                    # Flutter client (Clean Architecture + Riverpod)
│   ├── core/               # Shared infrastructure (theme, routing, network, storage)
│   └── features/           # Feature modules (chat, activation, speech, tts, memory, etc.)
├── backend/                # FastAPI backend proxy (JWT, OpenAI, SSE streaming)
│   ├── app/                # Application code
│   └── tests/              # Backend test suite
├── test/                   # Flutter test suite
├── macos/                  # macOS native runner & menu bar agent
├── android/                # Android native runner & foreground service
├── windows/                # Windows native runner & system tray
├── ios/                    # iOS native runner & App Intents
├── assets/                 # Shaders, icons, audio, Porcupine models
├── docs/                   # Architecture docs and diagrams
└── .github/workflows/      # CI/CD pipelines
```

## 🚀 Quick Start

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.24+
- [Python](https://www.python.org/downloads/) 3.12+
- [Docker](https://www.docker.com/products/docker-desktop/) (optional, for backend)
- Xcode (for macOS/iOS builds)
- Android Studio / Android SDK (for Android builds)

### 1. Clone & Setup Flutter Client

```bash
cd D
flutter pub get
```

### 2. Setup Backend

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
# Edit .env with your configuration
```

### 3. Run Backend

```bash
# With Docker (recommended)
cd backend
docker-compose up -d

# Or directly
cd backend
source .venv/bin/activate
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 4. Run Flutter Client

```bash
# macOS
flutter run -d macos

# Android (connect device or start emulator)
flutter run -d android

# All available devices
flutter devices
flutter run -d <device-id>
```

### 5. Run Tests

```bash
# Flutter tests
flutter test

# Backend tests
cd backend
pytest tests/ -v

# Lint checks
flutter analyze
cd backend && ruff check .
```

## 🔑 API Keys Required (by Phase)

| Key | Phase | Provider |
|-----|-------|----------|
| OpenAI API Key | Phase 2 (Chat) | [platform.openai.com](https://platform.openai.com) |
| Deepgram API Key | Phase 3 (STT) | [console.deepgram.com](https://console.deepgram.com) |
| ElevenLabs API Key | Phase 4 (TTS) | [elevenlabs.io](https://elevenlabs.io) |
| Picovoice AccessKey | Phase 5 (Wake Word) | [console.picovoice.ai](https://console.picovoice.ai) |

> **Note:** API keys are NEVER stored in the client app. All keys live in the backend `.env` file and are proxied through the FastAPI backend with JWT authentication.

## 🏗️ Architecture

See [docs/architecture.md](docs/architecture.md) for the complete system architecture, data-flow diagrams, security model, and platform strategies.

## 🔒 Privacy & Security

- Wake word and clap detection: **100% on-device**
- Audio before activation: **never recorded, never transmitted**
- Camera/emotion features: **opt-in, on-device only, frames never saved**
- API keys: **backend-only, never in client**
- Cloud sync: **end-to-end encrypted (AES-256-GCM), server cannot decrypt**
- Memory: **user-controlled CRUD + export, hard exclusion of passwords/financial/health data**
- Automation: **typed tool schemas, destructive actions require confirmation, full audit log**

## 📋 Development Phases

- [x] Phase 0 — Architecture Design
- [ ] Phase 1 — Project Scaffold ← **Current**
- [ ] Phase 2 — Chat + OpenAI via Backend
- [ ] Phase 3 — Speech to Text
- [ ] Phase 4 — Text to Speech
- [ ] Phase 5 — Activation (Wake Word + Clap)
- [ ] Phase 6 — Background Service
- [ ] Phase 7 — UI Screens
- [ ] Phase 8 — Siri-Style Reactive Orb
- [ ] Phase 9 — Long-Term Memory
- [ ] Phase 10 — Personality Engine
- [ ] Phase 11 — macOS Automation
- [ ] Phase 12 — Windows Automation
- [ ] Phase 13 — Face & Emotion Detection
- [ ] Phase 14 — Notifications
- [ ] Phase 15 — Cloud Sync
- [ ] Phase 16 — Security Audit
- [ ] Phase 17 — Production Release

