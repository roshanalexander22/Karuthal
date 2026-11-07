from typing import List, Dict, Any

class FieldMatcher:
    @staticmethod
    def match_fields(screen_labels: List[str], profile: Dict[str, Any]) -> List[Dict[str, Any]]:
        matches = []
        for label in screen_labels:
            matches.append({
                "label": label,
                "matched_profile_key": None,
                "confidence": 0.0
            })
        return matches
