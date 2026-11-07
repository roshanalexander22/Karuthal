from typing import Dict, Any, List

class AIService:
    @staticmethod
    async def structure_document_data(raw_text: str, category: str) -> Dict[str, Any]:
        """Convert unverified OCR text into structured schema via LLM."""
        return {
            "document_type": category,
            "fields": {
                "raw_snippet": raw_text[:100]
            }
        }

    @staticmethod
    async def match_form_fields(screen_fields: List[str], profile_data: Dict[str, Any]) -> Dict[str, str]:
        """Semantic alignment between screen UI labels and verified memory."""
        return {}
