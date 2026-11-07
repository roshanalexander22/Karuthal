from typing import Dict, Any

class DocumentExtractionService:
    @staticmethod
    async def extract_structured_entities(raw_ocr_text: str, document_type: str) -> Dict[str, Any]:
        return {
            "document_type": document_type,
            "entities": {
                "name": None,
                "dob": None,
                "id_number": None
            }
        }
