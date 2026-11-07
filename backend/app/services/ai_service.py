from __future__ import annotations
import base64
import logging
from typing import Dict, Any, List, Optional
import httpx

from app.core.config import settings

logger = logging.getLogger(__name__)


class AIService:
    @staticmethod
    async def transcribe_speech(audio_bytes: bytes, filename: str = "audio.wav", language: str = "ml") -> Dict[str, Any]:
        """Call AI Engine ASR endpoint to transcribe speech."""
        url = f"{settings.AI_ENGINE_URL}/asr/transcribe"
        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                files = {"file": (filename, audio_bytes, "audio/wav")}
                data = {"language": language}
                response = await client.post(url, files=files, data=data)
                if response.status_code == 200:
                    return response.json()
        except Exception as exc:
            logger.warning("AI Engine ASR failed or unavailable: %s. Using fallback parser.", exc)

        # Fallback heuristic for development/offline testing
        return {
            "transcribed_text": "നമസ്കാരം സഹായി, എനിക്ക് സഹായം വേണം.",
            "language": language,
            "confidence": 0.85,
            "duration_seconds": 1.5,
            "engine": "fallback"
        }

    @staticmethod
    async def synthesize_speech(text: str, language: str = "ml", speed: float = 0.85) -> Dict[str, Any]:
        """Call AI Engine TTS endpoint to synthesize speech."""
        url = f"{settings.AI_ENGINE_URL}/tts/synthesize"
        payload = {"text": text, "language": language, "speed": speed}
        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                response = await client.post(url, json=payload)
                if response.status_code == 200:
                    return response.json()
        except Exception as exc:
            logger.warning("AI Engine TTS failed or unavailable: %s. Generating local fallback wave.", exc)

        # Fallback empty wave payload
        return {
            "audio_base64": "",
            "sample_rate": 16000,
            "text": text,
            "language": language,
            "engine": "fallback"
        }

    @staticmethod
    async def detect_intent(text: str, language: str = "ml") -> Dict[str, Any]:
        """Call AI Engine intent detection endpoint."""
        url = f"{settings.AI_ENGINE_URL}/intent/detect"
        payload = {"text": text, "language": language}
        try:
            async with httpx.AsyncClient(timeout=8.0) as client:
                response = await client.post(url, json=payload)
                if response.status_code == 200:
                    return response.json()
        except Exception as exc:
            logger.warning("AI Engine Intent failed or unavailable: %s. Using rule-based fallback.", exc)

        # Rule-based fallback
        clean_text = text.strip().lower()
        if any(w in clean_text for w in ["മരുന്ന്", "ഓർമ്മിപ്പിക്ക", "reminder", "medicine", "ഗുളിക"]):
            intent = "SET_REMINDER"
            response_text = "തീർച്ചയായും, ഞാൻ ഓർമ്മപ്പെടുത്തൽ സേവ് ചെയ്യാം."
        elif any(w in clean_text for w in ["അപകടം", "രക്ഷിക്കൂ", "സഹായം", "sos", "emergency"]):
            intent = "EMERGENCY_SOS"
            response_text = "ശ്രദ്ധിക്കൂ, അത്യാഹിത സന്ദേശം നിങ്ങളുടെ ബന്ധുക്കൾക്ക് അയക്കുന്നു."
        elif any(w in clean_text for w in ["വായിക്കുക", "വായിക്കൂ", "read", "document"]):
            intent = "READ_DOCUMENT"
            response_text = "ഡോക്യുമെന്റിലെ വിവരങ്ങൾ ഞാൻ വായിച്ചു കേൾപ്പിക്കാം."
        else:
            intent = "GENERAL_QUERY"
            response_text = "സഹായി നിങ്ങളെ എങ്ങനെയാണ് സഹായിക്കേണ്ടത്?"

        return {
            "intent": intent,
            "confidence": 0.8,
            "entities": {},
            "response_text": response_text
        }

    @staticmethod
    async def process_voice_interaction(
        text: Optional[str] = None,
        audio_bytes: Optional[bytes] = None,
        language: str = "ml"
    ) -> Dict[str, Any]:
        """Complete Voice Assistant pipeline: ASR -> Intent -> TTS."""
        transcribed_text = text or ""
        asr_confidence = 1.0

        if audio_bytes:
            asr_res = await AIService.transcribe_speech(audio_bytes, language=language)
            transcribed_text = asr_res.get("transcribed_text", "")
            asr_confidence = asr_res.get("confidence", 0.8)

        intent_res = await AIService.detect_intent(transcribed_text, language=language)
        response_text = intent_res.get("response_text", "സഹായി തയ്യാറാണ്.")

        tts_res = await AIService.synthesize_speech(response_text, language=language)

        return {
            "user_query": transcribed_text,
            "intent": intent_res.get("intent", "UNKNOWN"),
            "confidence": min(asr_confidence, intent_res.get("confidence", 1.0)),
            "entities": intent_res.get("entities", {}),
            "response_text": response_text,
            "audio_base64": tts_res.get("audio_base64", ""),
            "action_executed": intent_res.get("intent")
        }

    @staticmethod
    async def structure_document_data(raw_text: str, category: str = "general") -> Dict[str, Any]:
        """Convert unverified OCR text into structured schema via LLM or rule extraction."""
        import re

        fields: Dict[str, Any] = {}
        # Aadhaar extraction: 12 digits (with optional spaces)
        aadhaar_match = re.search(r"\b(\d{4}\s\d{4}\s\d{4}|\d{12})\b", raw_text)
        if aadhaar_match:
            fields["aadhaar_number"] = aadhaar_match.group(1).replace(" ", "")
            category = "identity_document"

        # PAN extraction: 5 letters, 4 digits, 1 letter
        pan_match = re.search(r"\b([A-Z]{5}\d{4}[A-Z])\b", raw_text)
        if pan_match:
            fields["pan_number"] = pan_match.group(1)
            category = "identity_document"

        # Date of birth extraction (DD/MM/YYYY or DD-MM-YYYY)
        dob_match = re.search(r"\b(\d{2}[/-]\d{2}[/-]\d{4})\b", raw_text)
        if dob_match:
            fields["date_of_birth"] = dob_match.group(1)

        # Phone extraction (10 digits starting with 6-9)
        phone_match = re.search(r"\b([6-9]\d{9})\b", raw_text)
        if phone_match:
            fields["phone_number"] = phone_match.group(1)

        # Name extraction heuristic
        name_match = re.search(r"(?:Name|പേര്|Name:)\s*([A-Za-z\s]{3,30}|[\u0D00-\u0D7F\s]{3,30})", raw_text)
        if name_match:
            fields["full_name"] = name_match.group(1).strip()
        elif "full_name" not in fields and len(raw_text.splitlines()) > 0:
            first_line = raw_text.splitlines()[0].strip()
            if 3 < len(first_line) < 40 and not any(char.isdigit() for char in first_line):
                fields["full_name"] = first_line

        # Medical prescription keywords
        if any(k in raw_text.lower() for k in ["tablet", "capsule", "mg", "മരുന്ന്", "ഡോക്ടർ", "dr."]):
            category = "medical_prescription"
            medicines = []
            for line in raw_text.splitlines():
                if any(m in line.lower() for m in ["tab", "cap", "mg", "syrup", "od", "bd", "tid"]):
                    medicines.append(line.strip())
            if medicines:
                fields["prescribed_medicines"] = medicines

        return {
            "document_type": category,
            "raw_snippet": raw_text[:200],
            "fields": fields
        }

    @staticmethod
    async def match_form_fields(screen_fields: List[str], profile_data: Dict[str, Any]) -> Dict[str, str]:
        """Semantic alignment between screen UI labels and verified memory."""
        mapping: Dict[str, str] = {}
        normalized_profile = {k.lower().replace("_", "").replace(" ", ""): str(v) for k, v in profile_data.items()}

        aliases = {
            "name": ["name", "fullname", "applicantname", "പേര്", "പൂർണ്ണനാമം"],
            "dob": ["dob", "dateofbirth", "birthdate", "ജനനതിയതി", "തിയതി"],
            "phone": ["phone", "phonenumber", "mobile", "mobilenumber", "contact", "ഫോൺ", "ഫോൺനമ്പർ"],
            "address": ["address", "residentialaddress", "വിലാസം"],
            "aadhaar": ["aadhaar", "aadhaarno", "aadhaarnumber", "ആധാർ", "ആധാർനമ്പർ"],
            "pan": ["pan", "panno", "pannumber", "പാൻ", "പാൻനമ്പർ"],
            "gender": ["gender", "sex", "ലിംഗം"],
            "age": ["age", "പ്രായം"]
        }

        for screen_field in screen_fields:
            clean_field = screen_field.lower().replace("_", "").replace(" ", "").replace(":", "")
            matched_value = None

            # 1. Direct match
            if clean_field in normalized_profile:
                matched_value = normalized_profile[clean_field]

            # 2. Alias match
            if not matched_value:
                for canonical, synonyms in aliases.items():
                    if any(syn in clean_field for syn in synonyms):
                        # look for canonical key in profile
                        for prof_key, prof_val in profile_data.items():
                            clean_prof_key = prof_key.lower().replace("_", "")
                            if any(syn in clean_prof_key for syn in synonyms):
                                matched_value = str(prof_val)
                                break
                    if matched_value:
                        break

            if matched_value:
                mapping[screen_field] = matched_value

        return mapping
