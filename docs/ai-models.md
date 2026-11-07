# Sahaayi AI Models & Integration Registry

This registry catalogues all open-source and proprietary models utilized in Sahaayi.

---

## 1. Automatic Speech Recognition (ASR)

### A. AI4Bharat IndicConformer
- **Source**: [github.com/AI4Bharat/IndicConformerASR](https://github.com/AI4Bharat/IndicConformerASR)
- **License**: MIT
- **Languages**: Malayalam (`ml`), English (`en`), and Indian multilingual mixing.
- **Role**: Primary batch and near-line transcription for voice inputs.
- **Inference**: PyTorch / ONNX Runtime.

### B. Project Vaani (IISc Bangalore) — SraVaani-0.5-live
- **Source**: [vaani.iisc.ac.in/models](https://vaani.iisc.ac.in/models)
- **Role**: Evaluated for streaming live transcription of regional accents.
- **Deployment**: Microservice hosted on internal AI Engine (`:8001`).

### C. Whisper.cpp (OpenAI Whisper Port)
- **Source**: [github.com/ggml-org/whisper.cpp](https://github.com/ggml-org/whisper.cpp)
- **License**: MIT
- **Role**: Embedded/edge offline fallback for voice command recognition when cloud connectivity is unavailable.

---

## 2. Text-to-Speech (TTS)

### A. AI4Bharat Indic-TTS
- **Source**: [github.com/AI4Bharat/Indic-TTS](https://github.com/AI4Bharat/Indic-TTS)
- **License**: MIT
- **Role**: Natural Malayalam prosody, polite elder-focused intonation.
- **Voices**: Female / Male native Malayalam acoustic models.

### B. Project Vaani DhVaani
- **Source**: [vaani.iisc.ac.in](https://vaani.iisc.ac.in)
- **Role**: Multilingual streaming voice synthesis for screen reading.

### C. Android Local TextToSpeech (On-Device Fallback)
- **Engine**: Google Speech Services / Android TTS Engine (`flutter_tts`).
- **Role**: Zero-latency, zero-bandwidth basic screen reading.

---

## 3. Optical Character Recognition (OCR)

### A. Tesseract OCR 5.x
- **Language Packs**: `mal.traineddata`, `eng.traineddata`.
- **License**: Apache 2.0.
- **Role**: Extraction of printed characters from identity cards, certificates, and government letters.

### B. PaddleOCR
- **Role**: Complex document layout parsing, multi-column bank passbooks, and table recognition.

---

## 4. Large Language Models (LLM)

### Google Gemini API (`gemini-1.5-flash` & `gemini-1.5-pro`)
- **Integration**: `google-generativeai` SDK.
- **Roles**:
  1. *Entity Structuring*: Converting noisy OCR text into strictly validated JSON schemas.
  2. *Semantic Field Alignment*: Matching third-party form labels with verified profile keys.
  3. *Intent Classification*: Determining user intent from voice utterances.
  4. *Prescription Clarification*: Formatting dosage instructions in simple Malayalam (explicitly prohibited from modifying prescribed dosages).

---

## 5. Fall Detection & Sensor Classification

### TrustFall & Custom TFLite Model
- **Source**: Inspired by [github.com/Niyko/TrustFall](https://github.com/Niyko/TrustFall).
- **Framework**: TensorFlow Lite running on Android.
- **Inputs**: Tri-axial acceleration ($a_x, a_y, a_z$), gyroscope ($g_x, g_y, g_z$), Signal Magnitude Area (SMA), jerk metrics.
- **Safety Disclaimer**: Experimental feature requiring countdown confirmation before dispatch.
