from __future__ import annotations
import re
from typing import Dict, Any, List

class DocumentExtractionService:
    """Extract structured personal and medical entities from raw OCR text."""

    @staticmethod
    async def extract_structured_entities(raw_ocr_text: str, document_type: str = "AUTO") -> Dict[str, Any]:
        text = raw_ocr_text or ""
        lines = [line.strip() for line in text.split("\n") if line.strip()]

        detected_type = document_type
        if document_type == "AUTO" or not document_type:
            detected_type = DocumentExtractionService._detect_document_type(text)

        entities: Dict[str, Any] = {}
        confidence_scores: Dict[str, float] = {}

        # 1. Aadhaar Number (12 digits with optional spaces/hyphens)
        aadhaar_match = re.search(r"\b([2-9]\d{3}\s?\d{4}\s?\d{4})\b", text)
        if aadhaar_match:
            clean_aadhaar = re.sub(r"[\s-]", "", aadhaar_match.group(1))
            formatted_aadhaar = f"{clean_aadhaar[:4]} {clean_aadhaar[4:8]} {clean_aadhaar[8:]}"
            entities["Aadhaar Number"] = formatted_aadhaar
            confidence_scores["Aadhaar Number"] = 0.98

        # 2. PAN Number (5 letters, 4 digits, 1 letter)
        pan_match = re.search(r"\b([A-Z]{5}[0-9]{4}[A-Z]{1})\b", text.upper())
        if pan_match:
            entities["PAN Number"] = pan_match.group(1)
            confidence_scores["PAN Number"] = 0.99

        # 3. Phone / Mobile Number
        phone_match = re.search(r"\b(?:\+91[-\s]?)?([6-9]\d{9})\b", text)
        if phone_match:
            entities["Phone Number"] = phone_match.group(1)
            confidence_scores["Phone Number"] = 0.95

        # 4. Date of Birth (DOB)
        dob_match = re.search(r"\b(?:DOB|D\.O\.B|Date of Birth|ജനന തീയതി|ജനനം)[\s:]*([0-3]?\d[-/\.][0-1]?\d[-/\.](?:19|20)\d{2})\b", text, re.IGNORECASE)
        if not dob_match:
            dob_match = re.search(r"\b([0-3]\d[-/\.][0-1]\d[-/\.](?:19|20)\d{2})\b", text)
        if dob_match:
            entities["Date of Birth"] = dob_match.group(1)
            confidence_scores["Date of Birth"] = 0.92

        # 5. Blood Group
        blood_match = re.search(r"\b(A|B|AB|O)[\s]*([+-]|(?:positive|negative|ve))\b", text, re.IGNORECASE)
        if blood_match:
            grp = blood_match.group(1).upper()
            sign = "+" if "+" in blood_match.group(2) or "pos" in blood_match.group(2).lower() else "-"
            entities["Blood Group"] = f"{grp}{sign}"
            confidence_scores["Blood Group"] = 0.95

        # 6. Name Extraction (Keywords: Name, പേര്, Smt, Sri, Shri, Mr, Mrs)
        name_match = re.search(r"(?:Name|പേര്|Full Name|Patient Name)[\s:]+([A-Za-z\u0D00-\u0D7F\s\.]{3,40})", text, re.IGNORECASE)
        if name_match:
            clean_name = name_match.group(1).split("\n")[0].strip()
            # Clean common trailing artifacts
            clean_name = re.sub(r"(?:DOB|Age|Gender|Sex|Male|Female|S/O|D/O|W/O).*", "", clean_name, flags=re.IGNORECASE).strip()
            if len(clean_name) >= 3:
                entities["Full Name"] = clean_name
                confidence_scores["Full Name"] = 0.88

        # 7. Pin code & Address
        pin_match = re.search(r"\b(?:PIN|Pin Code|Pincode|പോസ്റ്റൽ കോഡ്)?[\s:-]*([6]\d{5})\b", text, re.IGNORECASE)
        if pin_match:
            entities["PIN Code"] = pin_match.group(1)
            confidence_scores["PIN Code"] = 0.96

        # 8. Voter ID / EPIC Number (3 uppercase letters followed by 7 digits)
        voter_match = re.search(r"\b([A-Z]{3}[0-9]{7})\b", text)
        if voter_match:
            entities["Voter ID"] = voter_match.group(1)
            confidence_scores["Voter ID"] = 0.97

        # 9. Hospital / Clinic / Doctor
        hospital_match = re.search(r"(?:Hospital|Clinic|Medical Centre|ആശുപത്രി)[\s:]+([A-Za-z\u0D00-\u0D7F\s\.]{3,50})", text, re.IGNORECASE)
        if hospital_match:
            entities["Hospital Name"] = hospital_match.group(0).strip()
            confidence_scores["Hospital Name"] = 0.85

        return {
            "document_type": detected_type,
            "entities": entities,
            "confidence_scores": confidence_scores,
            "raw_text_length": len(text)
        }

    @staticmethod
    def _detect_document_type(text: str) -> str:
        t = text.lower()
        if "government of india" in t or "unique identification" in t or "aadhaar" in t or "ആധാർ" in t:
            return "AADHAAR"
        if "income tax department" in t or "permanent account number" in t or "pan card" in t:
            return "PAN"
        if "election commission" in t or "epic" in t or "voter" in t or "തിരിച്ചറിയൽ കാർഡ്" in t:
            return "VOTER_ID"
        if "dr." in t or "doctor" in t or "rx" in t or "prescription" in t or "hospital" in t or "മെഡിക്കൽ" in t:
            return "PRESCRIPTION"
        if "driving licence" in t or "transport department" in t:
            return "DRIVING_LICENSE"
        return "GENERAL_DOCUMENT"
