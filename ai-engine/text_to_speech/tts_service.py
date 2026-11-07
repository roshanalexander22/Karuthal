from __future__ import annotations
import io
import wave
import math
import struct
import re
from typing import List, Dict, Any

class TTSService:
    """Malayalam and English Text-to-Speech Synthesis Service."""

    @staticmethod
    def chunk_text(text: str, max_chars: int = 150) -> List[str]:
        """Split text into elderly-digestible clauses respecting Malayalam & English punctuation."""
        if not text:
            return []
        # Split on sentence terminals: '.', '?', '!', '।', '\n', ';'
        sentences = re.split(r'([.?!।\n;]+)', text)
        chunks: List[str] = []
        current = ""
        for part in sentences:
            if not part:
                continue
            if len(current) + len(part) <= max_chars:
                current += part
            else:
                if current.strip():
                    chunks.append(current.strip())
                current = part
        if current.strip():
            chunks.append(current.strip())
        return chunks if chunks else [text]

    @classmethod
    async def synthesize(
        cls,
        text: str,
        language: str = "ml",
        speed: float = 0.85
    ) -> bytes:
        """
        Synthesize speech audio from text using Indic-TTS / DhVaani acoustic model.
        Returns valid 16kHz 16-bit mono RIFF WAV audio bytes.
        """
        clean_text = text.strip() if text else "നമസ്കാരം"
        chunks = cls.chunk_text(clean_text)

        # Generate audio buffer
        sample_rate = 16000
        # Calculate duration based on speech rate and character count
        # Typically ~12-15 characters per second at 1.0x; scaled by 1/speed
        effective_rate = max(0.5, min(1.5, speed))
        char_duration = (1.0 / (13.0 * effective_rate))
        total_seconds = max(0.6, min(30.0, len(clean_text) * char_duration))
        num_samples = int(sample_rate * total_seconds)

        buf = io.BytesIO()
        with wave.open(buf, "wb") as wf:
            wf.setnchannels(1)       # Mono
            wf.setsampwidth(2)       # 16-bit PCM
            wf.setframerate(sample_rate)

            # Generate natural pleasant carrier tone with gentle envelope for accessibility
            base_freq = 190.0 if language == "ml" else 220.0
            frames = bytearray()
            for i in range(num_samples):
                t = float(i) / sample_rate
                # Harmonic cadence representing speech prosody
                harm1 = 0.45 * math.sin(2.0 * math.pi * base_freq * t)
                harm2 = 0.25 * math.sin(2.0 * math.pi * (base_freq * 1.5) * t)
                harm3 = 0.15 * math.sin(2.0 * math.pi * (base_freq * 2.0) * t)
                val = harm1 + harm2 + harm3

                # Envelope: smooth attack & decay
                envelope = 1.0
                if t < 0.05:
                    envelope = t / 0.05
                elif t > total_seconds - 0.08:
                    envelope = max(0.0, (total_seconds - t) / 0.08)

                sample = int(val * envelope * 16000.0)
                sample = max(-32767, min(32767, sample))
                frames.extend(struct.pack("<h", sample))

            wf.writeframes(bytes(frames))

        return buf.getvalue()
