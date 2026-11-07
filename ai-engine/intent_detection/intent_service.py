"""
ai-engine/intent_detection/intent_service.py
--------------------------------------------
Intent classification and entity extraction for Malayalam & English voice queries.
"""

from __future__ import annotations

import re
from typing import Dict, Any


class IntentDetectionService:
    """Classifies user speech into actionable Sahaayi intents with slot filling."""

    # Malayalam keyword mappings
    REMINDER_KEYWORDS = ["ഓർമ്മിപ്പിക്കണം", "മരുന്ന്", "ഗുളിക", "സമയത്ത്", "ഓർമ്മ", "reminder", "medicine", "pill"]
    SOS_KEYWORDS = ["സഹായിക്കൂ", "രക്ഷിക്കൂ", "എനിക്ക് വയ്യ", "ഡോക്ടറെ വിളിക്കണം", "അടിയന്തിരം", "sos", "emergency", "help me"]
    READ_KEYWORDS = ["വായിക്കൂ", "വായിച്ചു തരൂ", "സ്ക്രീൻ", "രേഖ", "കത്ത്", "read", "document"]
    PROFILE_KEYWORDS = ["ആധാർ", "മേൽവിലാസം", "ബ്ലഡ് ഗ്രൂപ്പ്", "പേര്", "വിവരങ്ങൾ", "profile", "aadhaar", "address"]
    AUTOFILL_KEYWORDS = ["ഫോം", "പൂരിപ്പിക്കാൻ", "എഴുതാൻ", "autofill", "fill form"]

    @classmethod
    async def detect_intent(cls, user_utterance: str) -> Dict[str, Any]:
        """
        Analyze utterance and return intent with extracted entities and Malayalam response.
        """
        text = (user_utterance or "").strip().lower()
        if not text:
            return {
                "intent": "UNKNOWN",
                "confidence": 0.0,
                "entities": {},
                "response_ml": "ക്ഷമിക്കണം, എനിക്ക് ഒന്നും കേൾക്കാൻ കഴിഞ്ഞില്ല. വീണ്ടും പറയൂ.",
            }

        # 1. Emergency SOS
        if any(kw in text for kw in cls.SOS_KEYWORDS):
            return {
                "intent": "EMERGENCY_SOS",
                "confidence": 0.98,
                "entities": {"urgent": True},
                "response_ml": "അടിയന്തിര സഹായ സന്ദേശം നിങ്ങളുടെ പരിചാരകർക്ക് ഉടൻ അയക്കുന്നുണ്ട്. ഭയപ്പെടേണ്ടതില്ല.",
            }

        # 2. Medication / Appointment Reminder
        if any(kw in text for kw in cls.REMINDER_KEYWORDS):
            # Extract time if present
            time_entity = cls._extract_time(text)
            medicine_entity = cls._extract_medicine_name(text)
            return {
                "intent": "SET_REMINDER",
                "confidence": 0.95,
                "entities": {
                    "time": time_entity or "08:00",
                    "medicine_name": medicine_entity or "മരുന്ന്",
                    "type": "MEDICINE" if "മരുന്ന്" in text or "ഗുളിക" in text or "medicine" in text else "APPOINTMENT",
                },
                "response_ml": f"ശരി, {time_entity or 'നിശ്ചിത സമയത്ത്'} ഓർമ്മിപ്പിക്കാൻ ഞാൻ സേവ് ചെയ്യാം.",
            }

        # 3. Read Document / Screen
        if any(kw in text for kw in cls.READ_KEYWORDS):
            return {
                "intent": "READ_DOCUMENT",
                "confidence": 0.92,
                "entities": {},
                "response_ml": "തീർച്ചയായും, ഞാൻ ഇത് ഉച്ചത്തിൽ വായിക്കാം.",
            }

        # 4. Personal Memory / Profile Query
        if any(kw in text for kw in cls.PROFILE_KEYWORDS):
            return {
                "intent": "QUERY_PROFILE",
                "confidence": 0.90,
                "entities": {"field": "identity"},
                "response_ml": "നിങ്ങളുടെ വേരിഫൈ ചെയ്ത പ്രൊഫൈൽ വിവരങ്ങൾ ഞാൻ എടുത്തു തരാം.",
            }

        # 5. Smart Autofill
        if any(kw in text for kw in cls.AUTOFILL_KEYWORDS):
            return {
                "intent": "AUTOFILL_FORM",
                "confidence": 0.93,
                "entities": {},
                "response_ml": "ഫോമിലെ ഫീൽഡുകൾ പരിശോധിച്ചു പൂരിപ്പിക്കാൻ സഹായിക്കാം. ഒപ്പം നിങ്ങൾ ഉറപ്പുവരുത്തുക.",
            }

        # 6. Greetings / General Assistance
        if "നമസ്കാരം" in text or "ഹലോ" in text or "hello" in text or "ആരാണ്" in text:
            return {
                "intent": "GREETING",
                "confidence": 0.95,
                "entities": {},
                "response_ml": "നമസ്കാരം! ഞാൻ സഹായി ആണ്. നിങ്ങൾക്ക് എന്ത് സഹായമാണ് വേണ്ടത്?",
            }

        return {
            "intent": "GENERAL_ASSISTANCE",
            "confidence": 0.75,
            "entities": {"query": user_utterance},
            "response_ml": f"നിങ്ങൾ പറഞ്ഞത്: '{user_utterance}'. ഇതിൽ എങ്ങനെ സഹായിക്കണം എന്ന് പറയാമോ?",
        }

    @staticmethod
    def _extract_time(text: str) -> str | None:
        """Extract Malayalam/English time representation."""
        # Check Malayalam numbers: ഏഴു (7), എട്ടു (8), ഒൻപതു (9), etc.
        ml_numbers = {
            "ഒരു": "01:00", "രണ്ടു": "02:00", "മൂന്നു": "03:00", "നാലു": "04:00",
            "അഞ്ചു": "05:00", "ആറു": "06:00", "ഏഴു": "19:00", "എട്ടു": "20:00",
            "ഒൻപതു": "21:00", "പത്തു": "22:00",
        }
        for word, val in ml_numbers.items():
            if word in text:
                return val

        # Check numeric format: e.g. 7, 7:00, 8:30
        match = re.search(r"(\d{1,2})(?::(\d{2}))?\s*(am|pm|മണി)?", text)
        if match:
            hour = int(match.group(1))
            minute = match.group(2) or "00"
            is_pm = "വൈകിട്ട്" in text or "രാത്രി" in text or (match.group(3) and "pm" in match.group(3))
            if is_pm and hour < 12:
                hour += 12
            return f"{hour:02d}:{minute}"
        return None

    @staticmethod
    def _extract_medicine_name(text: str) -> str | None:
        """Extract medicine name if mentioned."""
        if "പ്രഷർ" in text or "bp" in text:
            return "പ്രഷറിന്റെ ഗുളിക (BP Tablet)"
        if "ഷുഗർ" in text or "insulin" in text:
            return "ഷുഗറിന്റെ മരുന്ന് (Insulin/Diabetic)"
        if "ഹാർട്ട്" in text or "heart" in text:
            return "ഹൃദ്രോഗ മരുന്ന്"
        return None
