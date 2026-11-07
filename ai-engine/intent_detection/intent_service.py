from __future__ import annotations
import re
from typing import Dict, Any, List

class IntentDetectionService:
    """Classifies user voice utterances and coordinates conversational response generation."""

    @staticmethod
    async def detect_intent(user_utterance: str, language: str = "ml") -> Dict[str, Any]:
        text = (user_utterance or "").strip().lower()

        # 1. Emergency / SOS
        emergency_keywords = [
            "സഹായിക്കൂ", "സഹായം", "രക്ഷിക്കൂ", "അടിയന്തരം", "വീണു", "ഡോക്ടർ", "ആശുപത്രി",
            "നെഞ്ചുവേദന", "help", "emergency", "fell down", "doctor", "ambulance", "sos"
        ]
        if any(kw in text for kw in emergency_keywords):
            return {
                "intent": "EMERGENCY_SOS",
                "confidence": 0.99,
                "entities": {"urgency": "HIGH"},
                "response_text": "പരിഭ്രാന്തരാകേണ്ട, അടിയന്തര സഹായത്തിനായി ബന്ധപ്പെടുന്നുണ്ട്. സഹായം ഉടൻ എത്തും.",
                "action": "TRIGGER_EMERGENCY_SOS",
                "target_route": "/emergency"
            }

        # 2. Medicine / Appointment Reminders
        reminder_keywords = [
            "മരുന്ന്", "ഗുളിക", "ഓർമ്മിപ്പിക്കുക", "ഓർമ്മ", "ഡോക്ടറെ കാണാൻ", "സമയം",
            "medicine", "tablet", "pill", "reminder", "alarm", "appointment", "schedule"
        ]
        if any(kw in text for kw in reminder_keywords):
            # Try extracting time
            time_match = re.search(r"\b(\d{1,2}(?::\d{2})?\s*(?:am|pm|മണിക്ക്|രാവിലെ|വൈകുന്നേരം))\b", text)
            time_slot = time_match.group(1) if time_match else "8:00 AM"
            return {
                "intent": "SET_REMINDER",
                "confidence": 0.95,
                "entities": {"time": time_slot, "type": "MEDICINE"},
                "response_text": f"ശരി, മരുന്ന് കഴിക്കാനുള്ള റിമൈൻഡർ {time_slot} സമയത്തേക്ക് സജ്ജമാക്കാം.",
                "action": "OPEN_REMINDER_FORM",
                "target_route": "/reminders/new"
            }

        # 3. Read Document / OCR
        doc_keywords = [
            "വായിക്കൂ", "വായിക്കുക", "കടലാസ്", "റിപ്പോർട്ട്", "രേഖ", "ഡോക്യുമെന്റ്",
            "read", "document", "prescription", "paper", "scan"
        ]
        if any(kw in text for kw in doc_keywords):
            return {
                "intent": "READ_DOCUMENT",
                "confidence": 0.93,
                "entities": {},
                "response_text": "തീർച്ചയായും, താങ്കളുടെ ഡോക്യുമെന്റ് സ്കാൻ ചെയ്യുകയോ തുറക്കുകയോ ചെയ്യാം. ഞാൻ വായിച്ചു കേൾപ്പിക്കാം.",
                "action": "OPEN_DOCUMENT_READER",
                "target_route": "/documents"
            }

        # 4. View Profile / Memory Bank
        profile_keywords = [
            "ആധാർ", "പാൻ", "എന്റെ പേര്", "വിവരം", "അഡ്രസ്", "മേൽവിലാസം", "ഫോൺ",
            "aadhaar", "pan", "profile", "memory", "my name", "address", "phone"
        ]
        if any(kw in text for kw in profile_keywords):
            return {
                "intent": "VIEW_PROFILE",
                "confidence": 0.91,
                "entities": {},
                "response_text": "താങ്കളുടെ വ്യക്തിഗത വിവരങ്ങൾ മെമ്മറി ബാങ്കിൽ സുരക്ഷിതമായി സൂക്ഷിച്ചിട്ടുണ്ട്.",
                "action": "OPEN_PROFILE",
                "target_route": "/profile"
            }

        # 5. Transcription
        transcribe_keywords = [
            "റെക്കോർഡ്", "കുറിച്ചെടുക്കൂ", "സംഭാഷണം", "transcribe", "record", "notes"
        ]
        if any(kw in text for kw in transcribe_keywords):
            return {
                "intent": "TRANSCRIBE",
                "confidence": 0.90,
                "entities": {},
                "response_text": "ശബ്ദ സംഭാഷണം ടെക്സ്റ്റാക്കി മാറ്റുന്നതിനായി ട്രാൻസ്ക്രിപ്ഷൻ ആരംഭിക്കാം.",
                "action": "OPEN_TRANSCRIPTION",
                "target_route": "/transcription"
            }

        # 6. General Assistance / Greeting
        return {
            "intent": "GENERAL_ASSISTANCE",
            "confidence": 0.88,
            "entities": {},
            "response_text": "നമസ്കാരം! ഞാൻ താങ്കളെ സഹായിക്കാൻ സദാ സന്നദ്ധനാണ്. മരുന്ന് ഓർമ്മപ്പെടുത്തലോ ഡോക്യുമെന്റ് വായനയോ എന്താണ് വേണ്ടത്?",
            "action": "NONE",
            "target_route": None
        }
