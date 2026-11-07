# Sahaayi AI Engine Microservice

The **Sahaayi AI Engine** is a dedicated, GPU/CPU-optimized microservice executing acoustic, visual, and language models for the Sahaayi platform.

## Scope of Capabilities
1. **Malayalam Automatic Speech Recognition (ASR)**: AI4Bharat IndicConformer and OpenAI Whisper.
2. **Text-to-Speech (TTS)**: AI4Bharat Indic-TTS and Project Vaani DhVaani.
3. **OCR & Document Extraction**: Tesseract OCR (Malayalam/English) & PaddleOCR.
4. **LLM Structuring & Intent**: Google Gemini API integration.
5. **Fall Detection Classifier**: TensorFlow Lite sensor fusion.

## Local Running
```bash
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8001 --reload
```
