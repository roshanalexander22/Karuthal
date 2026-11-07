from __future__ import annotations
import math
from typing import List, Dict, Any

class FallDetector:
    """3-Phase Accelerometer & Gyroscope Fall Detection Classifier."""

    FREE_FALL_THRESHOLD = 5.5   # m/s^2 (~0.55g)
    IMPACT_THRESHOLD = 24.0      # m/s^2 (~2.45g)
    INACTIVITY_THRESHOLD = 11.5 # m/s^2 (near 1g rest)

    @classmethod
    def evaluate_telemetry(cls, readings: List[Dict[str, float]]) -> Dict[str, Any]:
        """
        Analyze temporal sensor window:
        Phase 1: Free fall dip (< FREE_FALL_THRESHOLD)
        Phase 2: High impact peak (> IMPACT_THRESHOLD)
        Phase 3: Post-impact rest/inactivity
        """
        if not readings or len(readings) < 5:
            return {
                "is_fall_suspected": False,
                "confidence": 0.0,
                "impact_magnitude": 9.8,
                "stage": "INSUFFICIENT_DATA"
            }

        magnitudes = []
        for r in readings:
            x = r.get("x", 0.0)
            y = r.get("y", 0.0)
            z = r.get("z", 9.8)
            mag = math.sqrt(x*x + y*y + z*z)
            magnitudes.append(mag)

        peak_impact = max(magnitudes)
        min_accel = min(magnitudes)

        # Check for free-fall dip before peak impact
        has_free_fall = False
        has_impact = peak_impact >= cls.IMPACT_THRESHOLD
        
        peak_idx = magnitudes.index(peak_impact)
        for i in range(max(0, peak_idx - 15), peak_idx):
            if magnitudes[i] <= cls.FREE_FALL_THRESHOLD:
                has_free_fall = True
                break

        # Check post-impact inactivity
        is_inactive = False
        if has_impact and peak_idx < len(magnitudes) - 5:
            post_window = magnitudes[peak_idx + 2 : min(len(magnitudes), peak_idx + 15)]
            if post_window:
                avg_post = sum(post_window) / len(post_window)
                if abs(avg_post - 9.8) < 3.0:  # Resting near 1g
                    is_inactive = True

        # Fall classification score
        is_fall = False
        confidence = 0.0

        if has_free_fall and has_impact and is_inactive:
            is_fall = True
            confidence = 0.96
        elif has_free_fall and has_impact:
            is_fall = True
            confidence = 0.88
        elif has_impact:
            is_fall = True
            confidence = 0.72
        else:
            confidence = 0.15

        return {
            "is_fall_suspected": is_fall,
            "confidence": round(confidence, 2),
            "impact_magnitude": round(peak_impact, 2),
            "min_acceleration": round(min_accel, 2),
            "has_free_fall": has_free_fall,
            "has_impact": has_impact,
            "is_inactive": is_inactive
        }
